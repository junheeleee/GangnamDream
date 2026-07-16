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

### Narrative Detail Hierarchy

`assets/cast_detail_manifest.json` (`CAST_DETAIL_CONTRACT_V1`) is the machine-readable rule. Detail follows narrative agency, not a person's social worth.

- **A / Story anchor:** Minjun and the relationship-changing cast keep authored faces, eye-lines, outfits, full acting, and restrained color. Moral Black may corrode the frame but cannot erase their gaze or gesture.
- **B / Scene actor:** recurring supporting cast and one-scene people who carry an action keep a distinct age, silhouette, posture, and simplified readable face. They use a narrower Gangnam Ink palette so they support rather than compete with A-tier actors.
- **C / Atmospheric extra:** anonymous commuters, patrons, guests, and crowds use two or three low-contrast value planes with scene-correct clothing and posture. They have no readable facial features, but they are not pure-black cutouts or cloned bodies.
- Reusable backgrounds may embed only C-tier extras. A- and B-tier characters remain separate portraits or scene-specific CG actors.
- Any person with dialogue, a choice-bearing action, a relationship state, or a required gaze target is A/B and must appear in `cg_acting_manifest.json` when baked into a CG.
- Public locations should not be emptied merely to avoid AI artifacts. Population remains visible through C-tier depth silhouettes while the authored actors own the eye-lines and color contrast.

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
- Recurring AP categories and high-frequency subactions use stills from the actual world they open: the interview room, goshiwon, convenience store, library, gym, Han River, racetrack, Hold'em room, and Jeongseon Casino. A prop-only still life is still a pictogram at card scale, even when it is a PNG.
- Main AP cards treat the still as a full-height destination frame, not an icon inside a bordered square. Compact modals use a wide scene strip. SVG pictograms are reserved for AP cost, lock, focus, navigation, and genuine missing-art fallbacks.
- A scene may only be reused when the action fantasy is semantically the same, such as the broad Self-Dev category and Reading. Never repeat one money image for investing, gig work, and saving merely because all three affect cash.
- AP stills use a dedicated Moral material: Gray preserves color and midtone separation for one-second recognition, Black corrodes and desaturates the same scene, and White clears it. Moral treatment may not make a navigational image unreadable.

### Text and surface material

- Body prose and explanatory copy stay optically flat: `0px` shadow, `0px` outline. Readability comes from the local matte panel, not a glow around every glyph.
- Scene titles, names, key money, choice titles, and visible state changes receive one crisp `1px` ink contact. It has no blur or outline, so Korean and English keep the same letter shape at 720p and 4K.
- Choice and pressure-card surfaces sit at `1px` at rest, rise to at most `2px` on hover/focus, then collapse their shadow and move content exactly `1px` for `55ms` when confirmed. Disabled surfaces remain flat.
- `Reduce Motion` removes scale travel while retaining border, luminance, and pressed-state feedback. Material response must never be the only indication of focus.
- Pretendard remains the release font for body and current display use. The 720p, 1280x800, and 4K renders are sharp in Korean and English, so a paid display face is not a demo blocker. Reconsider one only after blind brand-recall testing proves that the title hierarchy, rather than key art or layout, is the weak link.

## Transition Rules

- Event-to-event transitions should feel like a page, receipt, or memory sliding under glass rather than a website route change.
- Black transitions: short dim, edge burn, dry ledger contact, stable UI geometry.
- White transitions: brief clarity lift, quieter edge, cleaner text.
- Neutral transitions: fast matte crossfade with subtle paper grain.

## Living Scene Motion Grammar

Gangnam Dream should not read as a slideshow, but motion must come from the physical scene rather than a decorative overlay preset.

- **Real-time by default:** rain, first snow, memory haze, restrained city-light change, fireworks residue, 1-2% background push/drift, and 0.2-0.4% in-person portrait breathing are layered in Godot. They stay branch-safe, resolution-independent, and do not restart narrative audio.
- **Semantic ownership:** weather comes only from event/background/tag contracts, memory haze only from a memory channel or explicit direction, and fireworks only from a festival event. Prose keywords never infer an effect. A generic interior remains still except for restrained camera depth.
- **Layer order:** grading and optional 0-2px blur affect the background only; atmosphere sits above the background and below every portrait, badge, choice, and dialogue surface. The lower dialogue area and the normal right-side face area are shader safe zones.
- **Moral behavior:** Black removes living air and slows movement while leaving a faint mechanical afterimage. White restores depth and ordinary air; it does not increase exposure or add a holy glow. The hidden system remains unlabelled.
- **Accessibility:** `reduce_motion` stops camera and portrait travel and reduces particle speed/intensity. The persistent setting is already consumed by StoryMode; the player-facing control and full input/resolution matrix belong to ORDER-16.
- **Performance:** the background grade uses one texture sample when blur is zero and a bounded nine-tap kernel only at an authored focus beat. The atmosphere surface is hidden for neutral scenes with no Black afterimage.

Pre-rendered video is reserved for a short, skippable set of opening, chapter-boss punctuation, and flagship ending candidates. It must have a static/reduced-motion fallback, external localized subtitles, owned audio stems, and a recorded license/source. General events, weather, and relationship branches never become MP4 footage merely to look expensive; that would increase size, compression artifacts, and continuity debt while removing Moral Tint responsiveness.

## Cross-Modal Era Lock

The image and sound must feel made by the same 2026 Seoul production. Gangnam Ink is contemporary illustration, so its default soundtrack cannot use chiptune, 8-bit oscillators, arcade lasers, retro menu bleeps, or exaggerated mobile-game reward sounds.

| Visual material | Matching sound material |
|---|---|
| Matte paper grain and concrete | Close, dry physical contact; restrained room reflections |
| Contemporary Seoul architecture | Current traffic, HVAC, appliances, transit, and indistinct real-world population |
| Clear A-tier face and eye-line | Human ambience with readable air and mid/high-frequency detail |
| Black ink corrosion | Subtraction: people recede, machinery and silence remain; no obvious horror sting |
| White clarity | Human detail and acoustic air return; no heavenly choir or gold-glow chord |
| Emergency red | A short, serious transient only for actual danger |

Diegetic casino or arcade cabinets may sound electronic when the visible machine justifies it, but those sounds stay inside that machine and never become the global UI language. Semantic audio keys are stable replacement slots: a timing-safe generated master may prove the interaction, but any synthetic-sounding launch asset must be replaced with a licensed or commissioned recording in the same slot.

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
- `scenes/ui/LivingSceneLayer.gd` and `assets/shaders/living_scene_fx.gdshader` add semantic rain, snow, memory, city-light, and fireworks profiles below actors and UI.
- `assets/shaders/background_grade.gdshader` owns the bounded background-only focus blur; portraits keep `blur_px = 0`.
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
