# Chapter 5 Authored Location Visual Bible

Updated: 2026-09-05

## Owner and Use

This file owns the six person-free location backgrounds introduced for the
authored Chapter 5 scene-context repair. It does not authorize text-driven
background guessing, generic routine-vignette remapping, or new story facts.
The event id owns the place; only a choice whose result prose physically moves
Minjun may switch to a result background.

| Background id | Canonical time and place | Authored use |
|---|---|---|
| `hospital_clinic_day` | Friday 09:20, modest Seoul family-medicine exam room | `arc_y5_burnout_check_reference` root and all results |
| `subway_station_stairs` | After work, urban Seoul station stairs and fare-gate approach | `rare_wallet_executive` root and the cash choice |
| `subway_station_lost_found` | Same station and time, staffed lost-property counter | `rare_wallet_executive` station-staff handoff result only |
| `hanjeongsik_restaurant_day` | Saturday 12:30, quiet Gangnam Korean set-menu restaurant | `chain_exec_meal_arrival`; `arc_jiyeon_year5_news` before the silent exit |
| `concert_hall_night` | Same-day night, fictional Seoul indoor concert venue | `yolo_spend_moment` full-price and cheap-seat attendance results only |
| `villa_renovation_day` | Saturday predawn, old Hwagok-dong low-rise villa interior | `chain_envelope_owner_return` work-site acceptance result only |

`hidden_gangnam_open_house` needs no new raster. Its root uses the existing
empty `gangnam_apartment`; its two results end at the dynamic current home and
the existing subway car respectively.

## Shared Surface and Crop Lock

- Gangnam Ink: desaturated contemporary Korean VN/manhwa realism, restrained
  ink contours and wash, matte paper grain, concrete gray and charcoal, quiet
  social-reality lighting. Photographic stock polish, glossy 3D, and generic
  anime saturation are rejection errors.
- Runtime delivery is exact 1280x800 opaque PNG. The 960x600 surface uses the
  same 16:10 frame without a new crop.
- The lower dialogue and choice zone must remain low-contrast. The normal
  right-side portrait region may cover secondary texture, never the location's
  one-second identity, route geometry, or decisive evidence.
- No named character, protagonist proxy, clear foreground face, readable
  writing, fake glyph, brand, logo, watermark, or UI is baked into these
  reusable backgrounds.
- Doors, aisles, stairs, windows, counters, furniture, tools, and service paths
  remain physically usable. Duplicated or malformed objects are rejection
  errors.

## Location Locks

### Morning clinic

- A consultation desk, patient chair, examination couch, privacy curtain,
  medicine storage, wall instruments, and a modest low-rise Seoul view establish
  an outpatient clinic rather than a ward or emergency room.
- Cool-neutral morning window light at 09:20 remains stronger than the ceiling
  fixtures. Night, dawn, sunset, inpatient beds, IV poles, and luxury-hospital
  language are forbidden.

### Station stairs and lost-property counter

- Both frames are one station: the same desaturated stone, stainless rail,
  restrained wayfinding colors, fluorescent temperature, and evening wear.
- The stairs frame reads as a fare-gate approach with continuous circulation,
  not a train car or shopping mall. The counter frame reads as a working station
  office/lost-property handoff, not a police interrogation room.
- No wallet is baked into either reusable frame. The choice and prose own the
  wallet; the location art must not pre-decide possession or handoff.

### Saturday Hanjeongsik restaurant

- A functional aisle, restrained lattice/paper-screen influence, matte timber,
  off-white ceramics, and one featured empty two-person table identify a modest
  Gangnam Korean set-menu restaurant at 12:30.
- Only a preliminary untouched banchan setting is allowed. No main course,
  leftovers, dirty plates, barbecue grill, exhaust hood, gukbap counter,
  company dinner, banquet, or completed-meal evidence may be present.
- Jiyeon's silent branch changes to `street` only after the prose says Minjun
  left alone. The congratulatory result stays in the restaurant.

### Fictional concert hall

- Stage, seating/standing tiers, sound and light rigging, and crowd-scale depth
  must identify an indoor performance venue immediately while preserving the
  player-overlay zones.
- No real artist likeness, fan mark, sponsor, band name, readable stage text,
  ticket brand, or foreground performer is allowed. The image cannot imply the
  exact seat or purchase before the chosen result establishes attendance.

### Hwagok-dong villa renovation

- An old small-room/hallway shell, aluminum window, cold predawn exterior,
  peeling wallpaper, uneven plaster, lifted flooring, protection paper,
  translucent plastic, one step ladder, wallpaper rolls, material sacks, one
  portable work light, one closed toolbox, broom, and dustpan establish a
  low-budget interior job in progress.
- It is not a demolition ruin, finished remodel, luxury apartment, horror set,
  or generic warehouse. No worker or owner is baked in.
- The work-site result is shown only after Minjun accepts the Saturday job; the
  refusal result remains at the convenience store.

## Runtime and Audio Contract

- `hospital_clinic_day` -> hospital ambience.
- `subway_station_stairs`, `subway_station_lost_found` -> subway ambience.
- `hanjeongsik_restaurant_day` -> quiet cafe/meal ambience.
- `concert_hall_night` -> the existing fictional-amusement performance profile;
  it adds no licensed music or artist identity.
- `villa_renovation_day` -> restrained street/work-site ambience.
- Result changes settle only after StoryMode has applied the chosen result. A
  non-moving result inherits its root texture and ambience.

## Production Record and Quality Boundary

The six release rasters are built-in OpenAI ImageGen outputs normalized to
1280x800. All were inspected at source resolution and again in live StoryMode.
The source outputs are below the pipeline's preferred 2560x1600 intermediate
master, so they are honest `PASS-B` runtime candidates, not A-grade release
masters. A future master upgrade may replace pixels while preserving every
contract in this file.

The real StoryMode background-context runner exercised KO/EN, every choice,
settled intro/result texture, and ambience for all seven authored events: 32
cases, 122 intro pages, and 100 result pages at both sizes. The hardened
1280x800 evidence is
`/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-background-context-rcwze_6q`
(`stdout.log` SHA-256 `3fe05097094b7827ee20143cdbe5548d8fce825c74ae0320525283ae0622b7f5`;
runner receipt `58cce932050dc24593277e5b0389d45483c740f827b6fdd7e112457e78a169f7`).
The 960x600 evidence is
`/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-background-context-jd4esjtq`
(`stdout.log` SHA-256 `9437eb19018cfc1eb10da7417f974187f3c387b1f0cf9112cfeb4c6b6d25a0ad`;
runner receipt `37ddea15b1f7be6fa94ce9d89ef6830987a36eeb9ff02fbb6a2d449e23479124`).
The deterministic 6x2 crop matrix is part of the 39-shot sheet at
`/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` (SHA-256
`a940f667ba79e9521c8442c74fb646f9e101de53bbc6020264269e41e86ec65f`).
These are regression and crop proofs only; they deliberately leave the human
play gate open.

| Release path | Source SHA-256 | Source disposition | Release SHA-256 |
|---|---|---|---|
| `assets/backgrounds/hospital_clinic_day.png` | `f0842e8bb0bc5e5483ff04108b19f3c7b458165e852bddc3ae9b85acfbf6f10b` | accepted after time-of-day edit and deterministic 16:10 normalization | `250f9aee9639144c73cc2c04ac2d7bbd0326a1cb49cc687417c3d864cc3fe439` |
| `assets/backgrounds/subway_station_stairs.png` | `e1b8bc03b8d5fd3c6f9795243a94b64c38953b89c06858d2dced5d1e8cf49b7c` | accepted after one surface-style correction | `ba8585a9abf4cbc33e99cddff399b9f48d8d7e8885216e8a9f6f2816688a3c31` |
| `assets/backgrounds/subway_station_lost_found.png` | `87e0a3bb1c9a34122700860f4c5bf0db7e20c6975d72eb069c1859d726223366` | accepted first pass | `eaca16aa8259459c06bd72d2e06589d11347827c3bf9a9754fa76620d900fee8` |
| `assets/backgrounds/hanjeongsik_restaurant_day.png` | `ff9b14d73c56b55d5068a1d29971d6639e3b1c77690b9661a37b59708e334802` | accepted after one surface-style correction and deterministic 16:10 normalization | `d10ef79ed31870e8d40fe607ed53cd35d722cc037633887b6396bd1d542e061e` |
| `assets/backgrounds/concert_hall_night.png` | `edb488b71f24f0dde29a163cd281b655125342d98d795e2b89d37e18949a468b` | accepted first pass | `880d4b341eed7361e67675f5dd1f7ea6716c49afe9c525d2f12c370e78f8b702` |
| `assets/backgrounds/villa_renovation_day.png` | `8bd50a83dc5c4401f37f3a415d168d9a2375a6bf82f104e509e426e787c05e4a` | accepted after rejecting a photographic first pass and correcting only the rendering surface | `9286b4d25aeeeb1410067875101c828815d08d8f5e1c353eff4cf908dc60563b` |

The source paths, in table order, are:
`$CODEX_HOME/generated_images/01a06d8d-d9a8-7431-b5c7-b86dd09804ae/hospital_clinic_day_final_1536x960.png`,
`$CODEX_HOME/generated_images/01a06d7d-9272-7a60-9404-8b7d08794965/exec-418d4526-9778-435f-a68d-dad6f00dda74.png`,
`$CODEX_HOME/generated_images/01a06d7d-9272-7a60-9404-8b7d08794965/exec-1a85fb95-bb84-4ba3-902f-1d258f597eee.png`,
`$CODEX_HOME/generated_images/01a06d8d-d9a8-7431-b5c7-b86dd09804ae/hanjeongsik_day_final_1536x960.png`,
`$CODEX_HOME/generated_images/01a06cd9-3f6e-7ba1-bbe7-8511127d8b9b/exec-ef6428c8-80a2-4375-9e6c-99583115716e.png`, and
`$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-cc4c19e2-51b7-40a1-bd07-82b4699aabdd.png`.

The rejected station-stairs first source was too close to glossy architectural
CG:
`$CODEX_HOME/generated_images/01a06d7d-9272-7a60-9404-8b7d08794965/exec-8d0da35c-5716-41f5-ae25-84aee38b8bfc.png`.
The first Hanjeongsik source at
`$CODEX_HOME/generated_images/01a06d8d-d9a8-7431-b5c7-b86dd09804ae/exec-e36c608f-f736-41d9-b905-0c3859ccb1fd.png`
was rejected for a near-photographic surface; the accepted style-corrected raw
source is `exec-6da9d3ea-832c-479c-9e1a-6dd130d65ee4.png` in the same directory.
The rejected villa source at
`$CODEX_HOME/generated_images/01a06cd9-3f6e-7ba1-bbe7-8511127d8b9b/exec-5c03743a-b493-4c48-b8a8-f23325121b4c.png`
preserved useful geometry but looked like interior photography. None of the
rejected sources is registered or copied into the product.

## Exact Prompt Ledger

The exact accepted-generation and corrective prompts follow. References to
“Image 1” describe the source image supplied to that edit; they are provenance,
not runtime dependencies.

### `hospital_clinic_day`

```text
Use case: lighting-weather
Asset type: reusable visual-novel background, production candidate
Primary request: Edit Image 1 into a person-free Seoul neighborhood family-medicine outpatient examination room at Friday 9:20 AM. Change the nighttime exterior and night-balanced lighting to believable clear late-morning daylight only.
Input images: Image 1 is the edit target and structural continuity reference.
Scene/backdrop: modest contemporary Korean neighborhood clinic consultation-and-exam room, not a hospital ward; retain the same coherent doctor desk, patient chair, examination couch, privacy curtain, medicine cabinet, wall diagnostic instruments, door/wall/window relationships, camera height, wide framing, and functional circulation.
Style/medium: Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, quiet Seoul social-reality mood.
Composition/framing: exact 16:10 landscape composition intended for 1280x800 UI and preferably delivered at 2560x1600 or higher; keep the lower dialogue/choice zone visually quiet and preserve open readable space for a right-side portrait overlay; functional architecture must read within one second.
Lighting/mood: soft cool-neutral Friday morning daylight enters through the window at 9:20 AM, pale blue daytime sky and ordinary low-rise Seoul neighborhood buildings outside, realistic mild shadows; ceiling lights may remain on but must not overpower daylight.
Text: none.
Constraints: change only time of day, exterior daylight, and the corresponding room illumination; aggressively preserve room geometry, furniture count and placement, camera perspective, medical function, restrained palette, reusable person-free staging, and uncluttered foreground.
Avoid: people, doctors, patients, silhouettes, nighttime, sunset, dawn, inpatient beds, IV poles, ward layout, emergency room, operating room, luxury hospital, legible charts or labels, fake writing, signage, logos, brands, watermarks, UI, clocks showing another time, distorted furniture, duplicated equipment, glossy stock-photo rendering.
```

### `subway_station_stairs`

Initial generation:

```text
Use case: stylized-concept.
Asset type: reusable full-screen visual-novel background, 16:10 landscape master.

Primary request: Create a people-free interior connecting space in a contemporary urban Seoul subway station after the evening rush. The place must unmistakably show a broad public stair flight, its landing, and a clearly visible row of subway fare gates connected by a physically plausible walking route. This is inside the paid/unpaid station concourse, not a train carriage, not a platform, and not an exterior entrance.

Scene and continuity design: establish one fictional Seoul station family for a later matching lost-and-found office. Use charcoal ceramic wall tiles, cool gray terrazzo flooring, brushed stainless-steel handrails and fare-gate housings, rectangular cool-white fluorescent ceiling fixtures, and one restrained muted burnt-orange architectural accent strip with no symbols or writing. Slight wet-weather grime and ordinary wear are welcome. Evening artificial light, quiet after commuters have cleared, sober and maintained but not luxurious.

Composition: eye-level to slightly elevated wide establishing shot. The stairs and fare gates must remain legible in the middle and upper portions of the frame. Keep the lower roughly 35 percent as relatively open, low-detail floor/foreground for dialogue and choice UI. Functional circulation, plausible handrails, plausible gate orientation, and one accessible wider gate. No foreground protagonist, no crowd, no staff.

Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood. Clean inked architectural contours with restrained painterly shading; readable Japanese visual-novel scene staging without generic anime gloss.

Hard constraints: no readable text, letters, numbers, station name, line name, route map, brand, logo, advertising copy, watermark, UI, wallet, event-specific prop, or identifiable person. Any wayfinding surfaces must be blank abstract color fields only. Do not depict a train, train interior, platform edge, outdoor street, shopping mall, bank, government lobby, sci-fi gate, neon cyberpunk lighting, or fisheye distortion.
```

Accepted surface correction:

```text
Edit this single subway-station background with one narrow change only: preserve the exact camera, 16:10 composition, architecture, stair geometry, fare-gate count and placement, empty foreground, charcoal tile, gray terrazzo, stainless steel, muted burnt-orange accent, lighting layout, and complete absence of people and text.

Change only the rendering treatment so it reads unmistakably as Gangnam Ink rather than a polished architectural visualization: add confident but restrained hand-inked architectural contour lines, subtle dry-brush and ink-wash value variation, matte paper grain, slightly simplified reflected highlights, and lightly uneven painted edges. Keep the desaturated Korean social-reality visual-novel/manhwa realism, sober fluorescent evening mood, and functional spatial clarity. Do not make it cartoony, generic anime, watercolor-fuzzy, photoreal DSLR, glossy 3D, cyberpunk, or high-saturation.

Do not add or remove objects. No text, letters, numbers, station/line name, route map, brand, logo, advertising copy, watermark, UI, wallet, event prop, person, train, platform, or exterior.
```

### `subway_station_lost_found`

```text
Use case: stylized-concept.
Asset type: reusable full-screen visual-novel background, 16:10 landscape master.

Primary request: Create a people-free small subway station staff office and lost-and-found reception counter inside the same fictional contemporary urban Seoul station as a companion background to a stairs-and-fare-gates concourse. It must unmistakably read as an operational station office for receiving lost property, not a bank, government service hall, police station, hotel desk, shop, or generic corporate office.

Functional layout: view from the public concourse toward a compact glazed station-staff booth. Include a sturdy waist-high service counter, a wide glass partition with a small practical pass-through opening, a staff-only side door behind the glass, and visible utilitarian lost-property shelving/cubbies inside. The shelves may hold a restrained assortment of generic closed umbrellas, plain cardboard archive boxes, neutral cloth bags, and one or two unbranded small objects, but absolutely no wallet. Include a modest empty work surface and ordinary station intercom/control hardware with no readable markings. A sliver of the tiled subway concourse and the edge of a fare-gate lane may be visible at one side to anchor the location, but the glass service window and lost-property shelves are the main subject.

Same-station continuity design: charcoal ceramic wall tiles, cool gray terrazzo flooring, brushed stainless-steel counter trim and door hardware, rectangular cool-white fluorescent ceiling fixtures, and the identical restrained muted burnt-orange architectural accent strip with no symbols or writing. Slight ordinary wear, quiet after-work evening artificial light, sober and maintained but not luxurious.

Composition: eye-level wide establishing shot, functional perspective, 16:10 landscape. Keep the service window, staff-only door, and lost-property shelves clearly readable in the middle and upper portions. Keep the lower roughly 35 percent relatively open and low-detail for visual-novel dialogue and choice UI. No foreground protagonist, no staff, no customers, no crowd.

Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood. Confident restrained hand-inked architectural contour lines, subtle dry-brush texture, simplified highlights, readable Japanese visual-novel scene staging without generic anime gloss.

Hard constraints: no readable text, letters, numbers, signs, forms, tickets, station name, line name, route map, timetable, brand, logo, advertisement, government seal, watermark, or UI. No wallet, cash, credit card, receipt, event-specific prop, person, portrait, or character silhouette. No teller windows, queue-number machine, velvet rope, bank trays, civic-service placards, police insignia, luxury finishes, train interior, platform edge, outdoor street, neon cyberpunk lighting, fisheye distortion, or photographic depth-of-field blur.
```

### `hanjeongsik_restaurant_day`

Initial generation:

```text
Use case: stylized-concept
Asset type: reusable visual-novel background, production candidate
Primary request: Create a person-free, quiet Gangnam Hanjeongsik restaurant dining room at Saturday 12:30 PM, unmistakably a refined but not extravagant Korean set-menu restaurant in daytime.
Scene/backdrop: contemporary Seoul Gangnam neighborhood Hanjeongsik interior with coherent Korean dining architecture, warm wood and muted stone/plaster, subtle traditional lattice or paper-screen influence without turning into a palace set, ordinary daylight visible through neutral windows, a functional aisle and service circulation, no private-home appearance.
Subject: an empty foreground table arranged for two diners, with two chairs or floor-compatible seats and a restrained preliminary spread of small neutral banchan dishes and tableware; the table is ready for conversation and the meal has not already ended.
Style/medium: Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, quiet Seoul social-reality mood.
Composition/framing: exact 16:10 landscape composition intended for 1280x800 UI and preferably delivered at 2560x1600 or higher; eye-level wide interior; make the two-person table and restaurant identity readable within one second; keep the lower dialogue/choice zone visually quiet and avoid important details in the normal right-side portrait overlay area; preserve generous unobstructed midground.
Lighting/mood: soft neutral noon daylight at 12:30 PM, calm Saturday lunch atmosphere, readable interior midtones, no sunset or dramatic nightlife glow.
Color palette: restrained charcoal, concrete gray, faded warm timber, off-white ceramics, muted natural greens and browns only in small food accents.
Materials/textures: matte wood grain, quiet plaster or stone, ceramic dishes, paper-screen or lattice details used sparingly, believable table and chair construction.
Text: none.
Constraints: reusable place background; no foreground or recurring characters; no readable menus, signs, labels, brands, logos, watermarks, or UI; coherent table scale, seating, aisles, doors and windows; exactly one clearly featured foreground two-person table; modest preliminary side dishes are allowed but no main course and no evidence of a completed meal.
Avoid: people, faces, silhouettes in the foreground, nighttime, dusk, neon, city-light skyline, Korean barbecue grills, exhaust hoods, raw meat, pork belly, gukbap, soup-diner counters, corporate company dinner, banquet hall, wedding venue, luxury palace restaurant, Japanese sushi-bar cues, Chinese banquet cues, a private home dining room, empty dirty plates, leftovers, crumpled napkins, stacked finished dishes, legible Korean or English text, fake glyphs, brands, logos, glossy stock-photo rendering, distorted furniture, duplicated bowls or cutlery.
```

Accepted surface correction:

```text
Use case: style-transfer
Asset type: reusable visual-novel background, final candidate
Primary request: Change only the rendering surface of Image 1 from near-photographic interior photography to unmistakable Gangnam Ink Korean visual-novel/manhwa realism. Keep the same quiet Saturday 12:30 PM Hanjeongsik restaurant, exact architecture, functional aisle, furniture, empty two-person foreground table, restrained untouched preliminary banchan setting, daylight direction, camera viewpoint, and composition.
Input images: Image 1 is the edit target; preserve its spatial layout and dining-state continuity.
Style/medium: desaturated contemporary Korean manhwa background illustration, deliberate clean ink contours on architecture and furniture, subtle ink-wash tonal blocks, matte paper grain, lightly simplified ceramic and wood textures, restrained cinematic depth, concrete gray and charcoal palette; premium visual-novel painted background, not a photograph and not anime character art.
Composition/framing: preserve the wide eye-level layout and UI-safe quiet lower/right zones; compose for an exact 16:10 landscape game canvas without letterboxing, borders, or cropping important table/aisle cues.
Lighting/mood: preserve soft neutral noon daylight and calm Saturday lunch atmosphere.
Text: none.
Constraints: change only the visual rendering style; preserve every structural relationship and do not add or remove people, food courses, furniture, signage, decoration, or narrative evidence; keep the meal clearly not yet finished.
Avoid: photoreal DSLR look, stock-photo polish, people, faces, foreground silhouettes, night, dusk, neon, barbecue grills, exhaust hoods, meat, gukbap counter, company dinner, banquet hall, private home, dirty or finished dishes, leftovers, readable text, fake glyphs, brands, logos, watermarks, UI, warped chairs, duplicated bowls or cutlery, glossy mobile-game colors.
```

### `concert_hall_night`

```text
Use case: stylized-concept
Asset type: reusable full-screen visual-novel location background for Gangnam Dream, landscape composed for a 16:10 1280x800 UI-safe crop
Primary request: a contemporary indoor concert hall in Seoul at night, architecturally clear and reusable for multiple ticket outcomes without implying a specific real concert or the player's exact seat class
Scene/backdrop: a believable medium-to-large Korean concert auditorium viewed at adult eye level from a neutral rear-center circulation aisle; a generic stage, overhead lighting truss, layered audience seating, side aisles, railings, acoustic wall panels, and ceiling structure must read clearly as an indoor concert venue
Subject: the venue architecture, illuminated generic stage, and audience bowl; only anonymous distant C-tier audience silhouettes are allowed, varied seated or standing postures in two or three low-contrast value planes, no readable faces and no foreground person; any tiny figures on stage must remain completely anonymous featureless silhouettes
Style/medium: Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic illustration, no glossy mobile-game colors, no photoreal DSLR look
Composition/framing: exact 16:10 landscape intent; stage and lighting readable in the upper half; no camera placement that establishes VIP, floor, balcony, numbered seat, or ticket tier; keep the lower 35 percent comparatively dark, low-detail, and free of essential information for the dialogue panel; keep the right-side portrait zone visually quiet; preserve a useful center-safe crop at both 1280x800 and 960x600
Lighting/mood: night performance atmosphere, dim house lights, restrained cool white and muted blue-violet stage light with small neutral highlights, lively but not triumphant or climactic
Color palette: low-saturation charcoal, concrete gray, cool navy, muted blue-violet accents; no saturated rainbow spectacle, no gold glamour
Materials/textures: matte acoustic panels, worn seat fabric, black metal rails, subtle concrete and painted steel, faint ink-print screening
Constraints: functional reusable location, recognizable within one second as a Seoul indoor concert hall; no named or recognizable singer, idol, celebrity, band, or real performance; no brands, logos, emblems, watermarks, readable stage copy, lettering, numbers, signs, banners, posters, phone screens, UI, or subtitles; do not pre-confirm a sold-out show, premium seat, cheap seat, ticket success, encore, confetti, or a specific narrative outcome
Avoid: foreground protagonist, close-up audience, cloned black cardboard silhouettes, celebrity likeness, glossy anime key art, stock-photo realism, tourist spectacle, stadium exterior, nightclub, cinema, theater play, empty rehearsal room, legible fake text
```

### `villa_renovation_day`

Initial generation:

```text
Use case: stylized-concept
Asset type: reusable full-screen visual-novel location background for Gangnam Dream, landscape composed for a 16:10 1280x800 UI-safe crop
Primary request: the interior of an old small low-rise multi-family villa apartment in Hwagok-dong, Seoul, during an in-progress interior repair job at Saturday predawn
Scene/backdrop: a modest aging Korean villa unit seen at adult eye level from the doorway into a small room and short hall; old aluminum-framed window with faint cold predawn blue outside, low ceiling, worn trim, dated wall surfaces, compact realistic floor plan
Subject: an active but temporarily unattended repair site; partially peeled wallpaper exposing uneven plaster, a section of lifted old flooring, floor-protection paper and translucent plastic taped down, one practical step ladder, closed generic toolbox, wallpaper rolls, modest material bundles, scraper, broom, dustpan, and cleanup bags arranged so the work sequence is physically understandable
Style/medium: Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic illustration, no glossy mobile-game colors, no photoreal DSLR look
Composition/framing: exact 16:10 landscape intent; functional room geometry and doorway/window relationship clearly readable; keep the lower 35 percent comparatively dark and low-detail beneath the dialogue panel, with no essential prop hidden there; place equipment mainly along the side walls and leave the right-side portrait zone calm; preserve a useful center-safe crop at both 1280x800 and 960x600
Lighting/mood: Saturday predawn, cool blue ambient light through the small window mixed with one restrained neutral portable work light; tired working-class realism, quiet before labor resumes, not horror and not cozy domestic completion
Color palette: low-saturation cool gray, faded beige, dusty blue, charcoal, small muted utility-orange accents only if needed
Materials/textures: torn paper fibers, uneven old plaster, scuffed vinyl flooring, taped kraft protection paper, cloudy plastic sheeting, worn wood trim, ordinary steel ladder and tools
Constraints: no people or human silhouettes; no foreground protagonist; no readable safety instructions, labels, packaging copy, address, brands, logos, emblems, watermarks, UI, signage, calendars, or phone screens; unmistakably a small old Korean villa interior being repaired, not a new apartment and not a completed remodel
Avoid: luxury apartment, high-rise, spacious loft, demolition site, collapsed ruin, exposed structural rebar, heavy excavator equipment, bare new-build shell, finished pristine interior, staged home decor, moving scene, disaster aftermath, horror lighting, fake readable text, duplicated or malformed tools
```

Accepted surface correction:

```text
Use case: style-transfer. Asset type: reusable full-screen visual-novel background, final candidate. Change only the rendering surface of Image 1 from near-photographic interior photography to unmistakable Gangnam Ink Korean visual-novel/manhwa realism. Aggressively preserve the exact 16:10-intent camera, small old Hwagok-dong low-rise villa room and hallway geometry, aluminum window and cold Saturday predawn exterior, partially peeled wallpaper, uneven plaster, lifted old flooring, floor-protection paper, taped translucent plastic, single step ladder, wallpaper rolls, material sacks, portable work light, closed black toolbox, broom and dustpan, and every object count and placement. Style: desaturated contemporary Korean manhwa background illustration, confident restrained hand-inked architectural contours, subtle dry-brush and ink-wash tonal blocks, matte paper grain, slightly simplified reflected highlights and material textures, concrete gray and charcoal palette, quiet working-class Seoul social-reality mood, premium visual-novel painted background. Preserve the cool predawn window light mixed with one neutral portable work light. Keep the lower dialogue zone and right portrait zone composition unchanged. Text: none. Constraints: change only visual rendering style; add or remove no objects or narrative evidence; no people, silhouettes, readable writing, brands, logos, watermarks, UI. Avoid photoreal DSLR look, stock-photo polish, glossy 3D, generic anime, watercolor blur, horror, luxury apartment, demolition ruin, completed remodel, saturated colors, warped architecture, duplicated or malformed tools.
```
