# Romance T0 CG Production Jobs

Updated: 2026-07-17

## Purpose

This sheet is the production contract for the eight T0 romance CGs in `docs/CODEX_QUEUE.md`.
The scene text, character identity, and runtime crop are all hard constraints. A beautiful image that changes a face, age, class signal, relationship state, or physical layout is rejected.

Do not wire a `cg` key into event JSON until the final file has passed the intake gates below.

## Shared Prompt Order

Every generation prompt must begin in this exact order.

### STYLE_SUMMARY

`Serious full-anime Korean manhwa visual-novel illustration with clean controlled linework, softly painterly cel rendering, restrained facial modeling, matte rather than glossy surfaces, and high environmental detail. The palette is predominantly desaturated charcoal, concrete gray, muted navy, weathered beige, and cold Seoul blue, with warm practical light used only as a localized emotional accent. Lighting is cinematic but grounded: soft window or street light, reflected city light, rain or atmospheric haze when story-appropriate, readable silhouettes, and no photographic depth-of-field gimmicks. The atmosphere is adult, socially realistic, intimate, and slightly weary rather than cute, heroic, or fashion-editorial.`

### Master Style Guide

`Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.`

### Global Composition Lock

- Output: 1280x800 PNG, 16:10 landscape.
- Keep all eyes, mouths, joined hands, and scene-defining objects above `y=530` whenever possible. The bottom 270 pixels are a dialogue-box safety zone.
- Do not place a face in the far-left 18 percent when a protagonist portrait may be composited over the scene.
- No text, captions, signs, logos, watermarks, UI, brand marks, or generated card-like borders.
- Background people may appear only as distant anonymous silhouettes. No clear secondary face.
- Hands, car geometry, doors, seats, shoreline, road edges, and character gaze direction must be physically coherent.
- Preserve the heroine's exact face from the listed portrait references. Outfit changes do not permit recasting.
- Minjun may be shown from behind, in profile, as a cropped shoulder/hand, or with his locked face. Do not invent a more glamorous male lead.
- Render one clear story beat, not a montage of several moments.
- CGs are emotional full-color surfaces at Gray. They must not be generated as black-and-white art. Moral tint is applied in runtime so the same shot can become clear, gray, or ink-stained without three separate paintings.

## Intake Gates

1. **Identity:** side-by-side review at face crop with the heroine portrait references.
2. **Canon:** age, hair, class signal, outfit, location, season, time, relationship state.
3. **Anatomy and physics:** hands, limbs, vehicle interior, shoreline, props, perspective.
4. **Runtime crop:** 1280x800 StoryMode screenshot with dialogue panel and optional portrait.
5. **Gangnam Ink:** moral-neutral shader at default state; bright/dark cherry variants are runtime grading, not separate paintings.
6. **International readability:** Daeun and Jiyeon remain distinguishable without names or dialogue.
7. **Technical:** exact size, RGB/RGBA PNG, no accidental alpha holes, no duplicate CG ownership.

## File And Key Map

| Job | Event ID | CG key | Final path | Status |
|---|---|---|---|---|
| R0-01 | `arc_season_sea_daeun_decision` | `cg_romance_sea_daeun` | `assets/cg/romance/sea_daeun.png` | approved/wired |
| R0-02 | `arc_season_sea_jiyeon_decision` | `cg_romance_sea_jiyeon` | `assets/cg/romance/sea_jiyeon.png` | approved/wired |
| R0-03 | `arc_season_fireworks_daeun_decision` | `cg_romance_fireworks_daeun` | `assets/cg/romance/fireworks_daeun.png` | approved/wired |
| R0-04 | `arc_season_fireworks_jiyeon_decision` | `cg_romance_fireworks_jiyeon` | `assets/cg/romance/fireworks_jiyeon.png` | approved/wired |
| R0-05 | `arc_season_cherry_daeun` | `cg_romance_cherry_daeun` | `assets/cg/romance/cherry_daeun.png` | approved/wired |
| R0-06 | `arc_season_cherry_jiyeon` | `cg_romance_cherry_jiyeon` | `assets/cg/romance/cherry_jiyeon.png` | approved/wired |
| R0-07 | `arc_daeun_first_kiss` | `cg_romance_first_kiss_daeun` | `assets/cg/romance/first_kiss_daeun.png` | approved/wired |
| R0-08 | `arc_jiyeon_first_kiss` | `cg_romance_first_kiss_jiyeon` | `assets/cg/romance/first_kiss_jiyeon.png` | approved/wired |

## R0-01 Daeun At The East Sea

**Identity references:**
- `assets/characters/npc_romantic_interest.png`
- `assets/characters/npc_daeun_smile.png`

**Scene:** A windy summer day at a modest East Sea beach. The first shallow wave has just reached Daeun's ankles. She laughs openly, larger and less guarded than in any portrait, because this is her first sea in five years.

**Composition:** Medium-wide eye-level shot from Minjun's viewpoint. Daeun is in the upper-right/center third, turned three-quarters toward camera, short hair and cover-up moving in the sea wind. Show wet sand, a physically readable shoreline, and a receding wave. Her face and open laugh are the focal point. Minjun is absent or only a small cropped forearm reaching from the lower side; do not split focus.

**Outfit:** Affordable muted coral-rose wrap swim dress with an open pale sky-blue cover-up. Bare feet. Same short hair and left hair clip. No luxury accessories.

**Emotional key:** Childlike release in an unmistakably 33-year-old adult face; joy with a trace of tears in the eyes, not pin-up posing.

**Avoid:** bikini-model pose, tropical-resort luxury, long hair, idol face, transparent wet-clothes fetish styling, sunset postcard colors, impossible wave direction, busy crowd, text.

## R0-02 Jiyeon At Haeundae

**Identity references:**
- `assets/characters/npc_mentor.png`
- `assets/characters/npc_jiyeon_warm.png`

**Scene:** Under a Haeundae parasol after confidently guiding Minjun around Busan, Jiyeon admits she cannot swim. Her status composure cracks for half a second.

**Composition:** Medium-wide eye-level shot. Jiyeon sits on a beach mat under a restrained parasol, knees drawn slightly close, sea visible and physically connected to the sand behind her. Sunglasses are lowered or held in one hand so her sharp eyes are visible. She looks toward Minjun just off camera. Keep the face upper-right/center.

**Outfit:** Deep emerald asymmetric high-neck swim dress with an open smoke-gray cover-up and restrained silver jewelry, no logos. Long black wavy hair remains her defining silhouette.

**Emotional key:** Beautiful and high-status, but privately embarrassed and vulnerable. Never cute-childish and never helpless.

**Avoid:** swimming action, glamorous resort advertising, smiling influencer, bikini pin-up, short hair, middle-aged face, luxury brand marks, crowds with clear faces.

## R0-03 Daeun At The Fireworks Festival

**Identity references:**
- `assets/characters/npc_romantic_interest.png`
- `assets/characters/npc_daeun_smile.png`

**Scene:** Yeouido riverbank at night. Fireworks color Daeun's side profile while she watches the sky; Minjun is watching her instead.

**Composition:** Intimate medium profile shot. Daeun occupies the upper-right third, looking up and away. Minjun's dark shoulder/profile is a soft foreground edge on the left, gaze clearly directed at her. Fireworks are reflected color accents, not the dominant subject. Anonymous crowd silhouettes sit low and distant.

**Outfit:** Simple knee-length muted blue-gray or dusty rose dress, light adult makeup, carefully set short hair with the same small clip. No uniform.

**Emotional key:** She senses his gaze one beat late; sincere shyness without hiding. Firework light moves across a recognizable adult face.

**Avoid:** ball gown, idol concert, teenage prom, long hair, fantasy fireworks filling the frame, direct kiss, clear crowd faces, text or festival logos.

## R0-04 Jiyeon At The Fireworks Festival

**Identity references:**
- `assets/characters/npc_mentor.png`
- `assets/characters/npc_jiyeon_warm.png`

**Scene:** Yeouido riverbank at night. Jiyeon has escaped her corporate gaze in a hoodie and sneakers, takes Minjun's hand first, and watches the fireworks with an unguarded side profile.

**Composition:** Medium two-shot biased toward Jiyeon's upper-right profile. Joined hands are visible around the middle of the frame, not under the dialogue safety zone. Minjun remains partially cropped or in restrained profile. Long hair escapes the lowered hood. Firework light softly changes her face; river and distant Seoul lights establish place.

**Outfit:** High-quality but unbranded charcoal hoodie, clean dark sneakers, minimal makeup, tiny familiar earrings. The casual outfit must still fit a 31-year-old wealthy woman.

**Emotional key:** Freedom from observation and the rare warm expression beneath her usual status armor.

**Avoid:** college-student recast, oversized streetwear caricature, baseball cap, short hair, flashy designer logos, direct camera pose, exaggerated rainbow palette.

## R0-05 Daeun Under Cherry Blossoms

**Identity references:**
- `assets/characters/npc_romantic_interest.png`
- `assets/characters/npc_daeun_smile.png`

**Scene:** April on a Hangang cherry-blossom path. Daeun stops under the trees; one petal rests on her shoulder while more petals fall like quiet snow.

**Composition:** Calm medium shot with Daeun in the upper-right/center and the path receding logically behind her. She looks up, then slightly back toward Minjun. Leave enough tonal range for runtime White and Black moral grading.

**Outfit:** Muted pale-blue dress or blouse/skirt with a light beige cardigan, ordinary shoes, same short hair and left clip.

**Emotional key:** An afternoon without a uniform or register. Gentle wonder, not tourist excitement.

**Avoid:** saturated pink fantasy tunnel, school uniform, long hair, wedding styling, selfie pose, landmark postcard, heavy lens blur.

## R0-06 Jiyeon Under Cherry Blossoms

**Identity references:**
- `assets/characters/npc_mentor.png`
- `assets/characters/npc_jiyeon_warm.png`

**Scene:** April on the Hangang path she selected from bloom data. Jiyeon slows despite herself; one petal rests in her long hair.

**Composition:** Calm medium shot from slightly behind Minjun's viewpoint. Jiyeon turns her upper body back toward camera, upper-right/center, long hair creating a distinct silhouette. The path and river-side planting remain structurally plausible. Preserve neutral tonal headroom for runtime moral variants.

**Outfit:** Cream tailored spring jacket over a black fine-knit top, practical low heels or clean flats, minimal gold jewelry. Elegant but not at an office meeting.

**Emotional key:** Data-driven control yielding briefly to genuine pleasure. A faint warm smile, not an influencer pose.

**Avoid:** short hair, business presentation stance, pink fashion editorial, selfie phone, visible luxury logos, fantasy petals obscuring the face.

## R0-07 Daeun First Kiss

**Identity references:**
- `assets/characters/npc_romantic_interest.png`
- `assets/characters/npc_daeun_smile.png`
- `assets/characters/main_character_neutral_goshiwon.png`

**Scene:** Before dawn outside the closed convenience store. Two warm canned coffees and visible breath occupy the small space between Daeun and Minjun just before their first kiss. The event offers a choice, so the CG freezes the mutual eye contact immediately before contact rather than forcing the kiss outcome.

**Composition:** Intimate chest-up two-shot, faces in the upper center with a narrow but visible distance between them. Daeun tilts her chin up; Minjun has stepped half a pace closer. Each holds one plain unbranded can low enough not to cover the face. Convenience-store light is a localized warm accent against a cold empty alley.

**Outfit:** Daeun's navy work polo and beige cardigan; Minjun's worn black sweatshirt. Same locked faces and ages.

**Emotional key:** Mutual consent, adult nervousness, exhaustion, warmth, and silence. Their breath and coffee steam overlap without hiding their eyes.

**Avoid:** lips already touching, explicit sensuality, youthful school-romance look, phone props, readable store signs, bright daytime, extra people, malformed fingers or duplicated cans.

## R0-08 Jiyeon First Kiss

**Identity references:**
- `assets/characters/npc_jiyeon_warm.png`
- `assets/characters/npc_mentor.png`
- `assets/characters/main_character_neutral_goshiwon.png`

**Scene:** Inside Jiyeon's stopped luxury sedan at night, engine and radio off. Dashboard light and blurred Gangnam street light cross her side profile as her composure wavers for half a second. Freeze the moment immediately before contact so both event choices remain valid.

**Composition:** Coherent left-hand-drive Korean car interior. Jiyeon is in the left driver seat and Minjun in the right front passenger seat. Camera is near the center/rear console at eye height. Their faces occupy the upper middle with a small distance; Jiyeon's hand is near the steering wheel without gripping it awkwardly. Windshield and side-window city light establish night without readable brands.

**Outfit:** Jiyeon in a cream tailored jacket over black, minimal gold jewelry; Minjun in restrained dark casual wear. Same locked faces and ages.

**Emotional key:** Dangerous confidence briefly giving way to private uncertainty. Her ear may be subtly warm, but do not caricature blushing.

**Avoid:** right-hand-drive layout, Jiyeon in passenger seat, car moving, hands on impossible controls, visible vehicle logo, white BMW, direct kiss, erotic framing, short hair, middle-aged face.

## Runtime Wiring After Approval

For each approved file:

1. Add the key to `ImageRegistry.CG`.
2. Add `cg` to the Korean event source only.
   If the illustrated beat occurs after earlier location/time paragraphs, add `cg_reveal_paragraph` with the zero-based paragraph index so the CG does not contradict the opening text.
3. Import in Godot and run `tools/CGRuntimeCheck.gd`.
4. Capture the exact event in Korean and English at 1280x800.
5. Verify neutral, White, and Black grading on both cherry-blossom CGs.
6. Add the accepted CG to the recall gallery only after its event is seen.
