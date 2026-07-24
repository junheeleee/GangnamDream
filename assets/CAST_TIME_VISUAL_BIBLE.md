# Gangnam Dream Cast Time Visual Bible

Updated: 2026-07-24  
Runtime contract: `content/meta/cast_visual_years.json` (`CAST_VISUAL_TIME_V1`)

This file owns visible time progression for recurring characters. Relationship
progression remains in `content/meta/cast_stages.json`; scene-specific clothes
and acting remain owned by their event or CG. These axes must never be collapsed
into one portrait filename or inferred from morality.

## Three Anchors

| Anchor | Turns | Chapters | Visible age |
|---|---:|---:|---|
| `y1` | 1-96 | 1-2 | Starting identity and first two years of survival |
| `y3` | 97-192 | 3-4 | Adaptation, accumulated fatigue, and a life taking shape |
| `y5` | 193-240 | 5 | The final-year consequence of work, health, and relationships |

Years two and four deliberately retain the preceding odd-year anchor. The game
needs a readable beginning, middle, and final state, not five nearly identical
AI portraits. The last anchor covers the approach to the age-38 ending.

## Independent Axes

1. **Time:** `GameState.turn` selects `y1`, `y3`, or `y5`.
2. **Relationship:** the cast stage selects neutral, warm, cold, sad, serious,
   or another authored expression.
3. **Context:** an explicit event may own hospital clothing, wedding clothing,
   seasonal clothing, a romance climax outfit, workwear, or a historical age.
4. **Morality:** Moral Tint grades the world and acting around the character. It
   must not silently swap a time portrait or turn facial aging into a moral score.

Resolution order is context lock first, then relationship expression, then time
anchor. A missing time asset falls back to its canonical portrait without
breaking old saves. No time stage is serialized; it is derived from the turn.

## Tier Policy

- **A-tier story anchors:** Minjun, Daeun, Jiyeon, Hyunsu, Jaehyuk, Sangchul,
  and Father receive `y1`, `y3`, and `y5` identity anchors.
- **B-tier scene actors:** use a first-appearance lock unless the same actor
  spans the full run and a later portrait carries a real dramatic need.
- **C-tier atmospheric extras:** never receive age variants. They remain
  low-contrast, scene-correct depth figures without becoming named-character
  substitutes.

## Global Aging Rules

- Two or four years are shown through grooming, posture, eye clarity, habitual
  tension, clothing maintenance, and social-class signal.
- Do not add conspicuous wrinkles, gray every head, hollow every cheek, or turn a
  five-year span into a twenty-year transformation.
- Hairline, face proportions, eye shape, nose, mouth, body type, and signature
  silhouette remain stable.
- A later portrait must be recognizable at a one-second glance beside its `y1`
  source and still differ at normal Steam Deck size.
- Expressions remain emotionally truthful. `y5` does not mean sad; it means the
  same emotion performed by someone who has lived through the route.
- Source portraits are transparent 1024x1536 RGBA PNGs. No room, prop, text,
  logo, cast shadow, or location light is baked into them.

## Character Contracts

### Kim Minjun

- Anchor ages: `y1` 33-34, `y3` 35-36, `y5` 37-38.
- Identity locks: lean face, narrow tired eyes, short uneven black fringe, slim
  shoulders, no glasses, no luxury-heir polish.
- Time signal: early guarded collapse becomes practiced endurance. Employment
  may improve grooming and fit, but the face never becomes a different handsome
  office lead.
- Runtime families: unemployed, part-time, office, and corporate.

### Kim Daeun

- Anchor ages: `y1` 33-34, `y3` 35-36, `y5` 37-38.
- Identity locks: short black bob, left-temple clip, soft adult face, ordinary
  warmth, practical navy-and-beige class signal.
- Time signal: steadier posture, a more settled gaze, and route-lived confidence
  or fatigue. Never influencer glamour, teenage roundness, or long hair.
- Runtime families: normal, smile, and sad.

### Han Jiyeon

- Anchor ages: `y1` 31-32, `y3` 33-34, `y5` 35-36.
- Identity locks: long black waves, sharp eyes, tailored cream/black wardrobe,
  restrained old-money jewelry, dangerous composure.
- Time signal: ornament becomes more deliberate and the gaze less performative.
  She never becomes a middle-aged matron or a generic soft heroine.
- Runtime families: normal, warm, and cold.

### Kang Hyunsu

- Anchor ages: `y1` 27-28, `y3` 29-30, `y5` 31-32.
- Identity locks: broad soft face, round wire glasses, stocky build, messy black
  hair, faded olive/burgundy color block, awkward warmth.
- Time signal: better self-possession and an adult routine, without slimming him
  into Minjun or aging him into a middle-aged office worker.
- Runtime family: normal. Accounting and civil-service outcome uniforms remain
  authored context portraits.

### Choi Jaehyuk

- Anchor ages: `y1` 34-35, `y3` 36-37, `y5` 38-39.
- Identity locks: sharp swept hair, narrow polished face, dark suit, controlled
  charisma, success-class posture.
- Time signal: the smile tightens and controlled exhaustion appears. He must not
  drift toward Sangchul's age, hair, or weathered broker silhouette.
- Runtime families: public charm and shadow.

### Im Sangchul

- Anchor ages: `y1` 52-53, `y3` 54-55, `y5` 56-57.
- Identity locks: salt-and-pepper hair, weathered broker face, practical suit,
  mature working-class polish.
- Time signal: exposure and debt settle into the eyes and shoulders. No sudden
  frailty, theatrical villain aging, or Jaehyuk-like glossy styling.
- Runtime families: normal and serious.

### Father

- Anchor ages: `y1` 63-64, `y3` 65-66, `y5` 67-68.
- Identity locks: lean long face, stable hairline, deep-set tired eyes, stooped
  working-life shoulders, old burgundy polo and gray-brown home cardigan.
- Time signal: subtle aging in ordinary home appearances only.
- `father_past`, workwear, weak/home-weak, hospital gown, death, and wedding
  contexts are fixed. Illness and historical time may never be synthesized from
  the ordinary home aging axis.

## Fixed Context Locks

The runtime must never automatically replace:

- Minjun's heatwave, monsoon, cold-snap, Moral threshold, crisis, wedding, or
  romance-climax portraits.
- Daeun and Jiyeon's sea, fireworks, cherry blossom, Namsan, amusement park,
  proposal, wedding-night, first-snow, and other authored route outfits.
- Hyunsu's accounting and civil-service outcome uniforms.
- Father's 2020 flashback, workwear, weak states, hospital gown, or death state.

If a new event needs a time-aware version of a fixed portrait, it must declare a
new explicit asset and contract. Do not add it to the automatic mapping casually.

## Runtime Contract

- `ImageRegistry.get_portrait_for_turn(id, turn)` is the public resolver.
- `ImageRegistry.get_visual_time_stage(turn)` owns all boundary math.
- `GameState.turn` is the only time input, preserving existing save compatibility.
- Missing contract, missing ID, or missing file falls back to the canonical
  portrait. A time variant may never produce a blank actor.
- Korean, English, and Japanese use the same visual resolver.

## QA Gate

- `CastVisualTimeCheck.tscn` proves all stage boundaries, file existence,
  relationship-stage independence, player job families, and fixed context locks.
- `ScreenshotQA --qa=year-identity --lang=ko/en` renders all seven A-tier actors
  at `y1`, `y3`, and `y5`.
- Required visual review: 1280x800 Korean and 960x600 English, complete face
  inside the portrait rail, no clipped hair/chin, and visible but restrained
  progression.
- Every newly activated portrait must enter `ART_AI_AUDIT`,
  `art_resolution_baseline.json`, and the mod replacement manifest.

