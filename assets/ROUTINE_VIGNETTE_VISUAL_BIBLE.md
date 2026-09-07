# Routine Vignette Visual Bible

Updated: 2026-09-05

## Owner and rule

This file owns the location contract for the random `SAVE` and `REST`
vignettes rendered by `MainGame`. The selected vignette row owns its stable
background id. Prose keywords are a legacy fallback for other actions and must
not override these rows: a rejected convenience-store lunch is not the place
where home cooking happened.

Contextual ids resolve only when the action settles. The concrete id is then
stored in the weekly receipt so a later echo does not rewrite the past after a
move, marriage, divorce, save, or locale change.

| Pool | Row | Place id | Canonical reading |
|---|---:|---|---|
| SAVE | 0 | `current_home_cooking` | Cooking at the current home, never the declined convenience store |
| SAVE | 1 | `current_housing` | Subscription cleanup at the current home |
| SAVE | 2 | `street_day` | The one-hour walk |
| SAVE | 3 | `convenience_night` | The convenience-store americano |
| SAVE | 4 | `current_home_cooking` | Fridge, eggs, and kimchi at the current home |
| REST | 0 | `hangang_riverside` | Han River walk |
| REST | 1–3, 6, 9 | `current_housing` | Sleep, screen rest, worry, dream, and failed rest at home |
| REST | 4 | `pojangmacha` | Drinking alone at a neighborhood tent bar |
| REST | 5 | `park_bench_day` | Sitting on an urban park bench in daytime |
| REST | 7 | `jjimjilbang` | Bathhouse rest |
| REST | 8 | `street_day` | Finding a crumpled bill on the street |

`current_home_cooking` resolves to `goshiwon_shared_kitchen` only while the
economic home is a goshiwon. A completed Daeun marriage uses
`daeun_newlywed_home`; divorce returns to the economic home. One-room, villa,
apartment, and legacy Gangnam homes use their existing concrete home backdrop.
No housing cost, ownership, relationship, or story fact is implied by this
presentation resolver.

## `park_bench_day`

- Ordinary Seoul neighborhood pocket park in soft daytime, with one clearly
  empty wood-and-metal bench, connected paving, planting edges, drainage and
  entrances, restrained lampposts, and ordinary low/mid-rise buildings.
- The lower 35–40 percent is a dark, low-detail UI-safe paved foreground. The
  bench and park identity remain readable above the dialogue dock and left of
  the portrait zone at both 1280x800 and 960x600.
- Only tiny, distant, faceless C-tier passersby are allowed to support the line
  that everyone is hurrying somewhere. No foreground or identifiable person,
  protagonist proxy, bag, wallet, phone, food, drink, date evidence, readable
  text, fake glyph, sign, logo, brand, watermark, or UI may be baked in.
- It must not read as a Han River park, mountain trail, apartment courtyard,
  bus stop, playground, amusement park, tourist landmark, or luxury garden.
- Surface is `Gangnam Ink`: desaturated Korean VN/manhwa realism, restrained
  hand-inked contours and wash, matte paper grain, concrete gray and charcoal,
  muted green, and no photographic or glossy architectural-render finish.
- The accepted raster is a B+/`PASS-B` runtime candidate, not an A-grade
  release master. Its leafy canopy is exact for the observed W216 June scene;
  a future all-season art pass must preserve this place contract rather than
  pretending the current sub-master is season-neutral.

## Runtime and audio contract

- `park_bench_day` uses the existing `street` ambience profile and outdoor/far
  direction profile. It adds no licensed music, speech, named crowd, water,
  playground, or event-specific sound.
- The selected concrete background id drives both texture and ambience. Reverse
  lookup from a shared file path must not replace that id.
- KO and EN use the same row and place. Translation may change only displayed
  prose, never the gameplay background key.
- The separate W220 authored choice is not a routine row. Its result/root
  concrete location is frozen in the story weekly receipt and survives
  save/load and later housing changes before the MainGame echo.

## Production record

The background was generated with built-in OpenAI ImageGen and inspected at
the 1586x992 opaque RGB source resolution. One pixel was removed from every
edge to obtain an exact 1584x990 16:10 frame, then it was downsampled to the
1280x800 runtime PNG. The source is below the preferred 2560x1600 intermediate
master threshold.

| File | SHA-256 | Disposition |
|---|---|---|
| ImageGen source `exec-044fff4d-ac93-4d2f-9ed4-966526e08fee.png` | `e405ce52acef7ceaa4f4286a404ca1501da794bf27b090119e26ec01f52825d9` | Accepted first pass; preserved outside the product tree |
| Exact 1584x990 center crop | `483c58f90b45325e023f38e2113fd3c4ef39bd8db7eb1bc13820fb10a31d0541` | Deterministic normalization intermediate |
| `assets/backgrounds/park_bench_day.png` | `0b817aece624a22dc53fd2c5ed919dcc406fc5aa91b6a18ad7986fd69146687d` | Accepted 1280x800 opaque B+/`PASS-B` runtime candidate |

Source path:
`$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-044fff4d-ac93-4d2f-9ed4-966526e08fee.png`.

## Exact accepted prompt

```text
Use case: stylized-concept
Asset type: reusable full-screen visual-novel location background for Gangnam Dream, landscape 16:10 production candidate
Primary request: Create an ordinary daytime Seoul neighborhood park where one person could sit quietly and watch other people hurry somewhere, but do not show any identifiable or foreground person. The image must read immediately as a public city park with a prominent empty bench, not as the Han River, a mountain park, an apartment courtyard, or a tourist landmark.
Scene/backdrop: modest contemporary Korean urban pocket park in a mixed residential and office neighborhood; mature plane trees, worn paved walking paths that split and continue toward the city, low restrained planting beds, two or three dark metal-and-wood public benches, simple lampposts, glimpses of ordinary mid-rise Seoul buildings beyond the trees. Any distant people may appear only as tiny, faceless, non-identifiable motion silhouettes that establish everyday weekday movement.
Subject: one clearly readable empty bench in the middle distance, with branching paths and the urban neighborhood establishing the location; no narrative prop or character.
Style/medium: Gangnam Ink visual language—desaturated contemporary Korean visual-novel/manhwa realism, confident restrained hand-inked architectural and foliage contours, subtle dry-brush and ink-wash value blocks, matte paper grain, slightly simplified highlights, concrete gray and charcoal palette with muted late-summer greens; premium painted VN background, quiet Seoul social-reality mood. Not photoreal DSLR, not glossy architectural 3D, not generic anime.
Composition/framing: exact 16:10 landscape intent for 1280x800 and 960x600. Eye-level wide establishing shot. Keep the empty bench and path identity in the middle/upper frame. Keep the lower roughly 35 percent comparatively dark, calm, and low-detail for dialogue and choice UI. Keep the right-side portrait zone calm; no essential location cue may depend on the lower UI zone or the far-right edge. Physically plausible paths, bench legs, paving, trees, and circulation.
Lighting/mood: overcast-to-soft daylight around early afternoon, restrained natural shadows, ordinary weekday stillness with the suggestion of other lives moving past; reflective but not romanticized or gloomy.
Text: none.
Constraints: no named character, no protagonist proxy, no clear face, no foreground person, no readable writing, fake glyph, park name, map, sign, advertisement, logo, brand, watermark, UI, phone, wallet, cash, food, event-specific prop, river, bridge, N Seoul Tower, mountain skyline, playground, exercise equipment, picnic staging, festival, cherry blossoms, autumn foliage, snow, rain, night, sunset, luxury landscaping, warped paths, duplicated benches, malformed furniture, glossy stock-photo rendering.
Avoid: identifiable people; tourists posing; close-up bodies; crowds; landmarks; waterfront; neon; high saturation; photoreal photography; fisheye; shallow depth-of-field blur.
```

The real MainGame/StoryMode regression runner and its evidence are recorded in
the owning ORDER after the post-fix 1280x800 and 960x600 passes. Those checks
prove routing, crop, texture, and ambience contracts only; they do not close the
Chapter 5 normal-speed human play gates.
