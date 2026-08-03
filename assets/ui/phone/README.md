# Phone shell asset provenance

These unbranded handset overlays are generated UI materials. They are not
registered story illustrations and therefore do not belong in `ImageRegistry`.
Each PNG keeps the physical shell opaque while the exterior and display opening
are transparent.

| Asset | Current use | Generated source | Processing |
|---|---|---|---|
| `phone_frame_starter.png` | Retained provenance only; no device tier or runtime purchase | `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/call_hMa0Rt1lA4eA5Y2UdldELHXK.png` | Built-in ImageGen edit, `#ff00ff` chroma removal and despill, 1672×940 RGBA |
| `phone_frame_refurbished.png` | Retained provenance only; no device tier or runtime purchase | `/Users/junheelee/.codex/generated_images/019fae08-cfb7-7073-b918-f55e32759797/call_qRdgoHMb0y1CIqOpbNRrCwAL.png` | Built-in ImageGen, `#ff00ff` chroma removal, safe crop, 1613×700 RGBA |
| `phone_frame_flagship.png` | Single fixed contact-phone shell, rotated back to portrait | `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/call_Q5AeZUpaYR8DOASuE4inzUmK.png` | Built-in ImageGen, `#ff00ff` chroma removal and spill neutralization, safe crop, aspect correction, 1512×720 RGBA |

## Current runtime contract

`CommunicationPhone.gd` uses only the flagship shell as one fixed portrait
contact drawer. It has no home launcher, device store, tier, purchase, favorite,
bank, investment, leisure, or games surface. The drawer opens directly to
Messages or Contacts; the wide monthly planner and MainGame own every non-contact
system. The older two shells remain only so the generated-asset provenance and
past release inventory stay auditable; their presence does not advertise a
playable device choice.

The starter has 1,001,100 fully transparent, 10,754 partially transparent, and
559,826 opaque pixels. Its four corner alpha values are zero. The rectangular
display opening is transparent from x=289..1382 and y=130..809. The flagship
has 985,278 fully transparent, 30,590 partially transparent, and 72,772 opaque
pixels; all four corner alpha values are zero.

## Source prompts and replacement contracts

The current starter replaced the 2017 shell after a human NO-GO that it still
read as a current phone. The prior tracked starter was supplied to built-in
ImageGen as the edit target with this exact prompt:

```text
Use case: precise-object-edit
Asset type: transparent physical phone shell overlay for a Godot game UI
Input image 1: edit target and exact composition reference
Primary request: redesign only the physical handset as an unmistakably old 2013–2015 low-end Android hand-me-down phone, shown straight-on in landscape orientation. Keep a clean rectangular 16:9 screen opening in the center for game UI compositing.
Subject: chunky dark navy-black glossy polycarbonate body; very thick left and right short-side bezels and clearly thick top/bottom bezels; slightly bulbous rounded plastic edges; visible cheap molded seams; worn silver-painted trim with rubbed corners and small everyday scuffs. On the LEFT short bezel, include a long horizontal earpiece slit (rotated with the phone), a small circular front camera, and two sensor dots. On the RIGHT short bezel, include one unmistakable raised oval physical HOME button plus two faint old capacitive MENU and BACK symbols. The three physical controls must read clearly even when the asset is reduced to about 850 pixels wide.
Scene/backdrop: the entire outside background and the entire screen opening must be perfectly flat solid #ff00ff chroma key.
Composition/framing: exactly one whole phone, centered, orthographic front view, landscape, no perspective tilt, generous even padding, wide 16:9-ish handset silhouette.
Style/medium: photorealistic isolated product material, ordinary used budget phone, deliberately dated rather than sleek or premium.
Materials/textures: thick glossy cheap plastic, slightly yellowed/rubbed trim, subtle fingerprints and edge wear, no cracks.
Constraints: change the shell design while preserving a simple centered empty rectangular screen opening; both outside and screen opening are uniform #ff00ff with no shadows, gradients, texture, reflections, or lighting variation; crisp isolated silhouette; no #ff00ff on the device; no logo or brand; no UI, icons, wallpaper, status bar, text, hands, case, stand, cable, rear camera, accessories, watermark.
Avoid: modern edge-to-edge display, thin uniform bezel, metal or titanium rails, hole-punch/notch, gesture bar, symmetrical premium silhouette, rounded modern app screen, protective case.
```

### Historical starter runtime contract (retired)

- The retired shell was required to retain worn polycarbonate, thick asymmetric bezels,
  an earpiece, camera/sensors, a physical oval Home key, and printed Menu/Back
  symbols. It should read as a used 2013–2015 low-cost Android handset before
  the player reads any text.
- The retired 1094×680 glass opening was filled by a black mat. Its live LCD was inset by
  32 source pixels at the top and bottom, producing an approximately 16:9
  display instead of stretching the UI across the whole older glass opening.
- Starter-only rendering used a 5px screen corner, muted blue-gray LCD base,
  light haze, no photographic wallpaper, and 56px app tiles with 8px corners.
  Refurbished and flagship rendering retain their existing modern treatment.
- The shell contains the three navigation controls. Retired runtime buttons
  over Menu/Home/Back have empty text and transparent states; they are only
  pointer hit areas aligned to those physical controls.
- The retired status bar used the live game date, `LTE`, and battery percentage. It
  must not restore the generic `09:41` product-marketing time.

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
