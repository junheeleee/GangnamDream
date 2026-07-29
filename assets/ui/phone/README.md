# Phone shell asset provenance

These unbranded handset overlays are generated UI materials. They are not
registered story illustrations and therefore do not belong in `ImageRegistry`.
Each PNG keeps the physical shell opaque while the exterior and display opening
are transparent so `CoreLoopPlanner` can render live UI beneath it.

| Runtime asset | Tier | Generated source | Processing |
|---|---|---|---|
| `phone_frame_starter.png` | 2017 hand-me-down budget phone | `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/call_OnKDiiGqoQCjKjy5q2oPD1Ox.png` | Built-in ImageGen, `#ff00ff` chroma removal and despill, safe crop, 1705×756 RGBA |
| `phone_frame_refurbished.png` | refurbished premium phone | `/Users/junheelee/.codex/generated_images/019fae08-cfb7-7073-b918-f55e32759797/call_qRdgoHMb0y1CIqOpbNRrCwAL.png` | Built-in ImageGen, `#ff00ff` chroma removal, safe crop, 1613×700 RGBA |
| `phone_frame_flagship.png` | current-generation flagship | `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/call_Q5AeZUpaYR8DOASuE4inzUmK.png` | Built-in ImageGen, `#ff00ff` chroma removal and spill neutralization, safe crop, aspect correction, 1512×720 RGBA |

The starter has 858,221 fully transparent, 12,383 partially transparent, and
418,376 opaque pixels; the starter and refurbished assets have zero residual
magenta pixels and fully transparent corner pixels. The flagship has 985,278 fully transparent,
30,590 partially transparent, and 72,772 opaque pixels; all four corner alpha
values are zero.

## Exact prompts

### Starter

```text
Use case: product-mockup
Asset type: Gangnam Dream in-game diegetic smartphone shell overlay, STARTER / OLD HAND-ME-DOWN device tier, second production pass
Primary request: Create one unmistakably outdated, inexpensive, visibly used but functional Korean-market Android-style budget smartphone from roughly 2017, viewed perfectly straight-on from the front and already rotated clockwise into landscape orientation. It must read as an old hand-me-down phone in 2026, never as a current flagship, while leaving enough display width for a game UI.
Scene/backdrop: The entire area outside the physical phone AND the entire display opening inside the bezel must be one perfectly flat solid #ff00ff chroma-key color for later transparency removal. No floor plane.
Subject: A single unbranded old budget smartphone physical shell only. Clearly visible thick black plastic LEFT and RIGHT short-side bezels in landscape and moderately thick top/bottom bezels. On the LEFT short bezel only, include one narrow old-fashioned earpiece slit, one small circular front camera, and two tiny sensor dots. The RIGHT short bezel must be completely plain. No physical home button and no printed or illuminated navigation symbols. Chunky rounded matte-to-semi-gloss dark charcoal polycarbonate frame, modest manufacturing seams, several subtle edge scuffs and softened corners, but no cracks and no protective case.
Proportion requirement: Overall outside phone silhouette approximately 2.20:1 width-to-height. Empty display opening approximately 2.00:1 width-to-height. Each LEFT and RIGHT bezel should occupy roughly 7–8% of total width, and top/bottom bezel roughly 4–5% of total height. Do not create a square or 16:10 display opening.
Style/medium: Photorealistic restrained product render for a serious Korean social-reality game, believable used electronics rather than parody.
Composition/framing: Orthographic exact front elevation, centered and perfectly level, complete device visible with even generous padding, no perspective, no three-quarter angle, no tilt.
Lighting/mood: Very restrained neutral studio edge highlight on the solid plastic shell only; no cast shadow, contact shadow, glow, reflection, or gradient in the background or display opening.
Color palette: Worn black and dark charcoal plastic only. Never use magenta in the physical phone.
Materials/textures: Inexpensive polycarbonate, older thicker front glass, light realistic edge wear only on the shell.
Constraints: Physical bezel/frame/shell only. The full rectangular screen opening must remain completely empty perfectly flat #ff00ff. The full outside background must remain completely flat #ff00ff. Crisp isolated silhouette, exactly one device. No logo, brand, UI, icons, symbols, text, wallpaper, status bar, buttons on the front face, hands, stand, cable, rear camera, accessories, watermark.
Avoid: contemporary edge-to-edge display, thin uniform bezel, hole-punch camera, notch, pill cutout, curved display, foldable phone, titanium or premium metal, physical home button, capacitive key markings, modern gesture bar, rugged bumper case, gaming-phone decorations, excessive damage, broken glass, futuristic concept art, perspective distortion, shadows, gradients or lighting variation in either chroma-key region.
```

### Refurbished

```text
Use case: product-mockup
Asset type: Gangnam Dream in-game diegetic smartphone shell overlay, REFURBISHED device tier
Primary request: Create one believable 2-to-3-year-old upper-tier Korean-market smartphone that has been professionally refurbished, viewed perfectly straight-on from the front and already rotated into landscape orientation. It should clearly feel better built and slimmer than a 2025 budget phone, but not brand-new and not futuristic.
Scene/backdrop: The entire area outside the physical phone AND the entire display opening inside the bezel must be one perfectly flat solid #ff00ff chroma-key color for removal. No floor plane.
Subject: A single unbranded modern smartphone physical shell only. Very thin perfectly symmetrical black front bezels; restrained dark silver anodized aluminum outer rail; flat front glass; tiny circular black hole-punch camera at the exact center of the LEFT short edge of the display area, because the portrait-top phone has been rotated clockwise into landscape. Professionally refurbished condition with only subtle hairline wear on two corners and a faintly softened anodized edge, no dents or cracks. Discreet premium side buttons only.
Style/medium: Realistic controlled product render, understated Korean social-reality game prop, not glossy luxury advertising.
Composition/framing: Orthographic front elevation, exact modern landscape 20:9 smartphone proportions rotated sideways, centered, level, full device visible with generous even padding, no perspective and no three-quarter angle.
Lighting/mood: Very restrained neutral studio edge light on the solid shell only; no cast shadow, no contact shadow, no reflection on the background or inside the display opening.
Color palette: Dark silver aluminum and black only; do not use magenta anywhere in the phone.
Materials/textures: Refined anodized aluminum, precisely fitted flat glass, believable light refurbishment wear.
Constraints: Physical frame/shell only. Screen opening must remain completely empty flat #ff00ff. Outside must remain completely flat #ff00ff. Crisp isolated silhouette. One device only. No logos, no brand, no UI, no icons, no text, no wallpaper, no status bar, no hand, no stand, no cable, no background objects, no watermark.
Avoid: brand-new showroom perfection, titanium, gold trim, curved waterfall display, foldable phone, thick bezel, long earpiece slit, physical home button, rugged bumper, protective case, vintage phone, gaming-phone decorations, camera notch, pill-shaped cutout, multiple cutouts, cracked glass, heavy damage, perspective distortion, shadows, gradients or lighting variation in the chroma-key regions.
```

### Current-generation flagship

```text
Use case: product-mockup
Asset type: Gangnam Dream in-game diegetic smartphone shell overlay, CURRENT-GENERATION FLAGSHIP device tier
Primary request: Create one unmistakably current 2026 Korean-market flagship smartphone viewed perfectly straight-on from the front, already rotated clockwise into landscape orientation. It must read immediately as a newly released premium phone, elegant and minimal, not budget, refurbished, rugged, vintage, or futuristic concept art.
Scene/backdrop: The entire area outside the physical phone AND the entire display opening inside the bezel must be one perfectly flat solid #ff00ff chroma-key color for later transparency removal. No floor plane.
Subject: A single unbranded flagship smartphone physical shell only. Extremely thin, perfectly uniform and symmetrical black screen bezel; very high screen-to-body ratio; precise flat dark graphite titanium-like side rail with subtly satin finish; flat front glass nearly flush with the frame; refined rounded corners with a modern moderate radius; one exceptionally small circular black hole-punch camera at the exact center of the LEFT short edge of the display opening because the portrait-top phone has been rotated clockwise into landscape; tiny tight side-button cut lines only. No case or bumper. The frame should be visibly slimmer and more precise than a 2-to-3-year-old premium refurbished phone.
Style/medium: Photorealistic restrained premium product render for a serious Korean social-reality game, contemporary industrial design, understated rather than flashy.
Composition/framing: Orthographic exact front elevation, modern 20:9 smartphone proportions rotated sideways, centered and perfectly level, complete device visible with even generous padding, no perspective, no three-quarter angle, no tilt.
Lighting/mood: Very subtle neutral studio edge highlight on the solid metal rail only; no cast shadow, contact shadow, glow, reflection, or gradient in the backdrop or display opening.
Color palette: Deep graphite, black, and a restrained cool titanium edge only. Never use magenta in the physical phone.
Materials/textures: Premium satin titanium-like metal, precision-machined seams, pristine new condition, flawless flat glass edge.
Constraints: Physical bezel/frame/shell only. The full screen opening must remain completely empty perfectly flat #ff00ff. The full outside background must remain completely flat #ff00ff. Crisp isolated silhouette, exactly one device. No logo, brand, UI, icons, text, wallpaper, status bar, hands, stand, cable, camera bump, rear cameras, accessories, watermark.
Avoid: thick bezel, old earpiece slit, home button, notch, pill-shaped cutout, multiple cutouts, curved waterfall display, foldable phone, rugged bumper, protective case, gaming-phone decorations, visible wear, scratches, dents, plastic seams, gold trim, bulky corners, sci-fi transparent hardware, perspective distortion, shadows, gradients or lighting variation in either chroma-key region.
```
