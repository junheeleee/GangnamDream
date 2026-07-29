# Phone shell asset provenance

These unbranded handset overlays are generated UI materials. They are not
registered story illustrations and therefore do not belong in `ImageRegistry`.
Each PNG keeps the physical shell opaque while the exterior and display opening
are transparent so `CoreLoopPlanner` can render live UI beneath it.

| Runtime asset | Tier | Generated source | Processing |
|---|---|---|---|
| `phone_frame_starter.png` | old budget phone | `/Users/junheelee/.codex/generated_images/019fae08-cfb7-7073-b918-f55e32759797/call_ECilDHWs9jngvGwPJDUJTLcd.png` | Built-in ImageGen, `#ff00ff` chroma removal, safe crop, 1530×662 RGBA |
| `phone_frame_refurbished.png` | refurbished premium phone | `/Users/junheelee/.codex/generated_images/019fae08-cfb7-7073-b918-f55e32759797/call_qRdgoHMb0y1CIqOpbNRrCwAL.png` | Built-in ImageGen, `#ff00ff` chroma removal, safe crop, 1613×700 RGBA |
| `phone_frame_flagship.png` | current-generation flagship | `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/call_Q5AeZUpaYR8DOASuE4inzUmK.png` | Built-in ImageGen, `#ff00ff` chroma removal and spill neutralization, safe crop, aspect correction, 1512×720 RGBA |

The starter and refurbished assets have zero residual magenta pixels and fully
transparent corner pixels. The flagship has 985,278 fully transparent,
30,590 partially transparent, and 72,772 opaque pixels; all four corner alpha
values are zero.

## Exact prompts

### Starter

```text
Use case: product-mockup
Asset type: Gangnam Dream in-game diegetic smartphone shell overlay, STARTER device tier
Primary request: Create one believable 2025 Korean-market budget smartphone viewed perfectly straight-on from the front, already rotated into landscape orientation. It must look current and inexpensive, not old-fashioned and not premium.
Scene/backdrop: The entire area outside the physical phone AND the entire display opening inside the bezel must be one perfectly flat solid #ff00ff chroma-key color for removal. No floor plane.
Subject: A single unbranded modern smartphone physical shell only. Thin but slightly wider perfectly symmetrical black front bezels than a flagship; matte charcoal polycarbonate outer frame with restrained molded seams and very subtle everyday scuffing; flat front glass; one tiny circular black hole-punch camera at the exact center of the LEFT short edge of the display area, because the portrait-top phone has been rotated clockwise into landscape. Discreet modern side buttons only.
Style/medium: Realistic controlled product render, understated Korean social-reality game prop, not glossy advertising.
Composition/framing: Orthographic front elevation, exact landscape 20:9 smartphone proportions rotated sideways, centered, level, full device visible with generous even padding, no perspective and no three-quarter angle.
Lighting/mood: Very restrained neutral studio edge light on the solid shell only; no cast shadow, no contact shadow, no reflection on the background or inside the display opening.
Color palette: Matte charcoal and black only; do not use magenta anywhere in the phone.
Materials/textures: Affordable matte polycarbonate, flat glass edge, modest manufacturing tolerances, believable 2025 budget hardware.
Constraints: Physical frame/shell only. Screen opening must remain completely empty flat #ff00ff. Outside must remain completely flat #ff00ff. Crisp isolated silhouette. One device only. No logos, no brand, no UI, no icons, no text, no wallpaper, no status bar, no hand, no stand, no cable, no background objects, no watermark.
Avoid: premium titanium, polished luxury metal, curved display, foldable phone, thick old bezel, long earpiece slit, physical home button, rugged bumper, raised protective case, vintage phone, gaming-phone decorations, camera notch, pill-shaped cutout, multiple cutouts, perspective distortion, shadows, gradients or lighting variation in the chroma-key regions.
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
