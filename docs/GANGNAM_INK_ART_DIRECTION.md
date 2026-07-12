# Gangnam Ink Art Direction

Updated: 2026-07-12

## Purpose

`Gangnam Ink` is the final surface language for Gangnam Dream. It exists because the game is built from many generated and hand-authored layers, and raw asset quality alone will not make it feel premium. Every image, UI surface, transition, and ending screen should feel like it passed through the same moral film stock.

Character ownership, title composition, the glass/reflection symbol, and merchandise-scale recognition are defined in `docs/IP_VISUAL_IDENTITY.md`. Gangnam Ink unifies those subjects; it does not replace them with desaturation.

The visual question is not "Is this image pretty?" The question is "Does this screen show what chasing Gangnam is doing to Minjun?"

## Core Metaphor

- Start state: neutral concrete gray. Minjun has not become anything yet.
- White route: sharper air, clearer text, calmer spacing, pale light, less visual noise.
- Black route: ink stain, crushed contrast, darker edge burn, stable controls, money remains unnaturally legible.
- Gray route: desaturated, documentary, tired, unresolved.

Exposure is a readability constant, not the moral axis. Gray and Black must preserve the authored architecture, face, gaze, and gesture. Black degrades attention and surface integrity; White restores color and human detail. Neither route is communicated by laying a nearly opaque black or white rectangle over the work.

The filter is not decoration. It is the visible form of `MORAL_TINT`.

## Palette

| Role | Color | Use |
|---|---|---|
| Concrete base | `#0d0d10` | Root background and default panel darkness |
| Charcoal panel | `#111216` | Main UI blocks |
| Raised graphite | `#181a20` | Focused or selected surfaces |
| Cold border | `#30343a` | Default structural lines |
| Paper text | `#e6e8ec` | Main text |
| Faded text | `#9aa1a8` | Secondary text |
| Dead text | `#5f656b` | Muted or unavailable text |
| White clarity | `#f3f7ff` | Moral recovery, not generic success |
| Black ink | `#020303` | Moral collapse, surface burn |
| Black money | `#ffd45a` / `#e4c376` | Deep/Light Black cash, assets, and goal only |
| Emergency red | `#ff4f5e` | Actual danger only: health, bankruptcy, game-over risk |

Gold, green, and saturated blue are no longer brand colors. They can remain as narrow semantic signals for casino chips, market gain/loss, or risk, but they must never become the general UI mood.

## Image Rules

- All production backgrounds should tolerate strong desaturation. If the image only works because of bright color, it is not a Gangnam Dream image.
- Every flagship scene should preserve an owned face, gesture, prop, or material from `IP_VISUAL_IDENTITY.md`. A consistent filter over generic people is still generic art.
- Reusable backgrounds should look like places, not CG illustrations with implied protagonists.
- Character portraits stay transparent and separate from backgrounds. Main cast should not be baked into reusable scene images.
- CGs may include main cast, but only for unique story moments and must obey canon continuity.
- Seoul landmarks are used as story signals, not tourist wallpaper.
- Private canon spaces such as the goshiwon, family home, and hospital must keep layout continuity before mood.
- Functional architecture comes before atmosphere. Streets, bus stops, car interiors, casino tables, card/chip layouts, bedrooms, and offices must make physical sense before they are accepted. If the player asks "where is the road?" or "why is this glass/door/chip there?", the asset fails even if the palette is correct.
- Do not convert the whole game to pixel art. Gangnam Dream needs faces, class signals, and Seoul spaces to remain readable. Use subtle ink-print screening, grain, and light tonal stepping as a unifying film stock instead.
- Pixel/dither language is allowed only as a controlled accent: casino machines, money fixation, memory collapse, or Black-route disorientation. It should never make the whole UI look like a cheap filter.

### VN Climax Layer

Gangnam Dream is not a full monochrome game. Reusable locations and the interface use the restrained documentary surface so the moral drift can accumulate without becoming a color theme. One-off emotional CGs are a separate readability layer:

- Romance, father, Sangchul truth, and ending CGs keep restrained but visible color at neutral Gray.
- White choices clear the air and recover color; they do not add a generic golden glow.
- Black choices remove color from the CG through ink spread and crushed edges, with money and metal remaining selectively legible.
- The scene should still read as a visual-novel climax at a glance: a face, a gesture, a relationship, and a single physical place have priority over the filter.
- Use Japanese visual-novel grammar as a staging reference, not as a full identity swap: readable face crops, clear eye-lines, deliberate holds, silhouette contrast, and emotionally timed CG reveals. Keep Korean adult faces, Seoul spaces, and Gangnam Ink material language.

The target is **Korean social-reality VN with Japanese scene readability**, not generic anime key art and not photoreal AI photography. If a generated image looks like a stock photo or a polished mobile-game illustration, reject it even when the composition is attractive.

## UI Rules

- UI is quiet, matte, and readable. No glossy mobile-game panels.
- The player should feel the interface hardening or clearing as moral choices accumulate.
- Button feedback should be tactile but restrained: slight luminance pulse, pressed compression, border clarity, short SFX.
- Warning red is reserved for true danger. Routine negative outcomes use gray, dimming, or text weight.
- Money may be visually seductive only when the player is morally Black. Otherwise it is just information.
- Narrative result cards preserve every consequence but alter attention order. Black reveals economic/status outcomes first and human consequences later; White reveals people/body/mind first and economic cost later; Gray remains balanced. The delayed category stays readable and can never be removed merely because the four-slot card is full.
- StartMenu is a character poster with a single command rail. Save management and run statistics are second-layer utilities, not the launch composition.
- Choice presentation uses one lower safe-area dock. When choices open, the dialogue panel folds away so the image is never covered by both systems at once.
- Recurring AP categories and high-frequency subactions use object-focused scene strips rather than generic clip-art pictograms. They are small world fragments that occupy meaningful card width, not symbols trapped in square icon frames: work=resume/ID, money=market phone, self-development=books/body, rest=goshiwon window/blanket, people=two seats/cups, gambling=physical table props. Career, money, study, social/routine/date, and each gambling venue own explicit atlas regions.
- A dedicated AP illustration may only be reused when the action is semantically identical. Never repeat one money image for investing, side work, and saving merely because all three affect cash; keep the distinct symbol fallback until each submenu action owns art.

## Transition Rules

- Event-to-event transitions should feel like a page, receipt, or memory sliding under glass rather than a website route change.
- Black transitions: short dim, edge burn, dry ledger contact, stable UI geometry.
- White transitions: brief clarity lift, quieter edge, cleaner text.
- Neutral transitions: fast matte crossfade with subtle paper grain.

## Asset Generation Prompt Prefix

Use this prefix before future image prompts after canon-specific constraints:

`Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.`

For Black-route variants add:

`Moral Black variant: darker edge burn, ink-stained shadows, crushed but readable contrast, cold gray highlights, money/metal may catch faint unnatural light, no brown rust or warm sepia.`

For White-route variants add:

`Moral White variant: clearer air, pale cool-white highlights, softened grain, calmer composition, readable silhouettes, no heavenly glow or fantasy effects.`

## Current Engine Implementation

- `assets/shaders/background_grade.gdshader` desaturates all event backgrounds and adds subtle paper grain, ink bleed, pale fade, and edge burn.
- `assets/shaders/background_grade.gdshader` also adds a restrained print-screen texture and very light tonal stepping. Black makes the printed surface rougher; White clears it back down.
- `assets/shaders/moral_surface.gdshader` adds Black ink corrosion, screen scarring, and White clarity without brown rust.
- `scenes/MainGame.gd` drives those parameters from `GameState.moral_tint_norm()` so the same background changes with the player.

## QA Checklist

- Does the space physically work: road/sidewalk/curb direction, bus stop bench/glass/boarding side, doors, windows, tables, cards, chips, and UI-safe center alignment?
- Black state should read as ink/concrete, not brown, green, or sepia.
- White state should read as clear and pale, not beige, gold, or fantasy holy light.
- Gray state should feel premium and intentional, not merely low saturation.
- Gray and Black must retain readable architecture, eye-lines, and hand actions; darkness alone never passes the moral check.
- Choice screens must leave at least the upper half of the scene unobstructed at 1280×800.
- Text must remain readable at 1280x800 and on Steam Deck.
- Casino, investment, and UI semantic colors may appear, but they must not overpower the moral surface.
