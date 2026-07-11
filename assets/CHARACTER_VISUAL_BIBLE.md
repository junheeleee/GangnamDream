# Gangnam Dream Character Visual Bible

Updated: 2026-07-03

This file is the visual canon for recurring characters. It overrides older one-off prompt notes when there is a conflict. Recurring character portraits must be generated as transparent-background PNGs and then composited over location backgrounds in Godot.

## Global Rules

- Major recurring characters must not be baked into rooms, cars, streets, cafes, offices, or other locations.
- Portrait identity must stay stable across expressions: same age, face structure, hair, body type, styling tier, and social class signal.
- CGs may include characters and backgrounds only when they depict one specific scene.
- Consistency beats isolated image beauty. A beautiful image that contradicts the story is a failed asset.
- International readability matters: each major character must be distinguishable at a one-second glance by silhouette, age band, hair shape, outfit color, social-class signal, and posture. Do not rely only on subtle facial differences.

## Cast Readability Locks

- Kim Minjun: black worn sweatshirt, short messy black hair, no glasses, lean debt-fatigue posture.
- Kang Hyunsu: chubby but likable 26-27-year-old exam-prep neighbor, round wire-frame glasses, soft round face, messy medium black hair, faded olive-gray zip hoodie, muted burgundy striped shirt, awkward warm half-smile.
- Choi Jaehyuk: sharp hair, dark suit, confident/charming smile or shadowed pressure, polished success signal.
- Im Sangchul: 52-year-old broker, salt-and-pepper hair, practical suit jacket, weathered mentor expression.
- Father: 63-year-old factory worker, worn work jacket, heavier guilt/warmth, older working-class signal.
- Kim Daeun: ordinary convenience-store survival warmth, beige cardigan/navy work shirt, soft tired eyes.
- Han Jiyeon: long black hair, cream/black tailored suit, old-money jewelry, dangerous high-status aura.
- Lee Minseo: 38-year-old self-made Gangnam arrival mentor, short neat dark hair, charcoal practical blazer, calm tired eyes.

## Kim Minjun

**Role:** Player protagonist. A 33-year-old unemployed Korean man starting from 500,000 KRW, a Sinchon goshiwon, and six years of debt fatigue.

**Age:** 33 at start, 33-38 during the core loop. He should not look like a college student or a 40s/50s man in core portraits.

**Visual Core:** Lean, tired, quiet, restrained Korean man. Short messy black hair, worn eyes, slight hollow cheeks, guarded posture. He is not glamorous; the appeal is recognition and endurance.

**Class Signal:** Clothing changes with life state, but the face/age/body must not drift.
- Unemployed/default: plain worn black sweatshirt, debt-fatigue posture.
- Part-time/survival work: inexpensive dark casual zip jacket or shift outerwear, practical and slightly worn.
- Ordinary office: budget white shirt, loose dark tie, simple cardigan or cheap navy blazer, first-job awkwardness.
- Big-company/corporate: clean navy or charcoal suit, restrained tie, cautious confidence, still not luxury-heir styling.

No luxury watch, no designer styling, no polished Gangnam success look in early/core expressions.

**Current Asset Status:** `main_character_neutral_goshiwon.png`, `main_character_tired.png`, `main_character_determined.png`, `main_character_happy.png`, and `main_character_shocked.png` were regenerated on 2026-06-12 as transparent portraits. `main_character_unemployed.png`, `main_character_part_time.png`, `main_character_office.png`, and `main_character_corporate.png` were added on 2026-06-12 for runtime outfit switching. The `neutral_goshiwon` filename is legacy only; do not add a room background back into that portrait.

**Runtime Outfit Rules:** `ImageRegistry.get_player_context_portrait()` is the source of truth. Survival jobs (`job_01`, `job_02`) use part-time workwear; ordinary low/mid-tier office/education/tech jobs use office wear; `job_08`, finance, sales, and tier 3+ jobs use corporate suit. Stress/critical/milestone states still override with tired/shocked/happy emotional portraits.

**CG Outfit Rule:** Personal dates, hospital visits, family scenes, and off-duty romance beats use the worn black crewneck locked by `player_romance_casual`, regardless of Minjun's current job. Office/corporate clothing appears in a CG only when the scene text explicitly places him at work, arriving directly from work, or performing public success. Every future CG job must name the matching Minjun portrait reference.

**Negative Prompt / Prohibited:** goshiwon room inside portrait, phone prop, visible hands holding phone, large window, skyline, luxury styling, old-man epilogue look, teenage look, photoreal DSLR portrait, changing face between outfit variants.

## Kang Hyunsu

**Role:** Goshiwon neighbor and fourth-year civil-service-exam student. He is Minjun's stalled younger peer mirror, not another protagonist skin.

**Age:** 26-27. The first intro event describes him as around 26 and he calls Minjun "hyung"; do not age him into a middle-aged friend.

**Visual Core:** Chubby/stocky but youthful and likable Korean man. Round wire-frame glasses, soft round face, slightly messy medium black hair, gentle tired eyes, clean-shaven or only extremely faint stubble, slouched exam-taker shoulders, awkward warm half-smile.

**Class Signal:** Faded olive-gray zip hoodie over a muted burgundy striped shirt. Cheap, worn, study-room survival clothes, but clean enough to be lovable. This color block is intentional to separate him from Minjun's black sweatshirt.

**Current Asset Status:** `npc_close_friend.png` regenerated again on 2026-06-12 as a transparent portrait after the first readability redesign made him too middle-aged and low-appeal for a visual novel cast. Current version targets a friendly chubby late-20s exam-prep junior.

**Negative Prompt / Prohibited:** plain black sweatshirt, same short messy hair silhouette as Minjun, no-glasses version, polished office styling, handsome rival styling, middle-aged 36+ look, unappealing slob caricature, goshiwon background.

## Kim Daeun

**Role:** Convenience-store night worker / ordinary survival heroine / romance route B. She represents the warmth and dignity that remain outside Gangnam's fast ladder. She is not a younger-coworker fantasy or a generic cheerful shop clerk.

**Age:** 33 at the start, the same age as Minjun. She should read as an adult woman who has endured several unsettled years in Seoul, never as a teenager, college student, or woman in her early 20s.

**Visual Core:** Soft but clearly adult Korean woman with a slim ordinary build, short layered dark-brown hair ending around the jaw and nape, wispy parted bangs, one small dark hair clip over her left temple, warm brown eyes, and a gently tired face. Her beauty is approachable and specific rather than glamorous. Keep the same almond eye shape, narrow nose bridge, soft jaw, and small composed mouth across every expression and CG.

**Class Signal:** Beige knit cardigan over a navy convenience-store work polo for her default portrait. Clothes are clean, repeatedly worn, and practical. No visible store logo. Her off-duty wardrobe uses modest solid-color pieces with ordinary fabrics and almost no jewelry. Even in a dress or swimsuit she should look like Daeun dressing up, not like a wealthy influencer or a different heroine.

**Body Language:** Slightly closed shoulders from night work, hands kept close to the body when shy, direct eye contact once she chooses honesty. Her embarrassment is explicit and sincere: she may blush or admit that she is nervous, but she does not perform Jiyeon's sharp recovery or status composure.

**Emotional Range:**
- `daeun_normal`: quiet warmth, tired but attentive eyes, restrained mouth.
- `daeun_smile`: genuine open smile that reaches the eyes, still recognizable as the same tired adult.
- `daeun_sad`: hurt and disappointed rather than helpless, gaze lowered only slightly.
- Future special portraits: preserve the same face, short hair, hair clip, age, and modest styling even when the outfit changes.

**Seasonal Outfit Locks:**
- Cherry blossom: muted light cardigan or simple spring jacket over a modest dress/skirt; no luxury bag.
- East Sea: muted coral-rose wrap-front swim dress with a pale sky-blue cotton cover-up. It is an affordable special outfit, warm and memorable without influencer or bikini-model styling.
- Fireworks: simple softly colored knee-length dress, light makeup, hair carefully set but still short with the same clip.
- First kiss: navy work polo and beige cardigan after the convenience-store closing shift.

**Namsan Outfit Lock:** Muted moss-green short duffle coat over an ivory ribbed knit and dark straight jeans. The practical fabric and modest silhouette must remain distinct from Jiyeon's tailored sapphire coat. `npc_daeun_namsan.png` and `namsan_lock_daeun_v1.png` own the same outfit and short-hair identity.

**Current Asset Status:** `assets/characters/npc_romantic_interest.png`, `assets/characters/npc_daeun_smile.png`, and `assets/characters/npc_daeun_sad.png` are the identity references. T0 scene outfits are locked by `npc_daeun_sea_v2.png`, `npc_daeun_fireworks.png`, and `npc_daeun_cherry.png`; first kiss reuses `npc_daeun_smile.png` because its work outfit already matches the CG exactly. T1 Namsan uses `npc_daeun_namsan.png` paired with `assets/cg/romance/namsan_lock_daeun_v1.png`. The East Sea paired CG is `assets/cg/romance/sea_daeun_v3.png`.

**Negative Prompt / Prohibited:** 20s college-student styling, teenager, long hair, Han Jiyeon-like glamour, luxury jewelry, influencer makeup, idol stage styling, childish proportions, generic convenience-store logo, background baked into a reusable portrait, photoreal DSLR portrait, changing face or hair length between outfits.

## Han Jiyeon

**Role:** Wealthy Gangnam investor / dangerous heroine / romance route A. She is not a middle-aged mentor. She represents the door into Gangnam: seductive, useful, sincere in places, and never fully safe.

**Age:** 31. She should look early 30s, never 40s or middle-aged.

**Visual Core:** Beautiful, dangerous, alluring Korean woman. Long black or very dark brown hair, preferably soft waves or rain-damp loose hair in first-contact material. Sharp intelligent eyes, composed mouth, elegant posture. Her expression should feel like she is reading the room and deciding what everyone is worth.

**Class Signal:** 압구정/강남 old-money energy, not flashy influencer. Tailored cream, black, or deep charcoal suits; silk blouse; minimal but expensive jewelry; designer watch or subtle bag if visible. No casual college look.

**Emotional Range:**
- `jiyeon_normal`: composed, observant, faintly unreadable.
- `jiyeon_warm`: rare genuine softness, still elegant and controlled.
- `jiyeon_cold`: beautiful but distant, status pressure visible in the eyes.
- `jiyeon_surprised`: composure cracked because Minjun did something she did not expect.

**Seasonal Outfit Lock:** Haeundae uses a deep emerald asymmetric high-neck swim dress, an open smoke-gray cover-up, and restrained brushed-silver jewelry. It must not repeat her default cream jacket and black inner palette.

**Narrow Room Outfit Lock:** At Minjun's door she wears a travel-creased charcoal long coat open over a deep muted oxblood fine-knit top. Inside, the coat is removed and the same oxblood top is paired with charcoal trousers. Makeup is nearly absent, hair is slightly disordered, and her gaze loses its normal status composure without changing her identity.

**Namsan Outfit Lock:** Deep sapphire-blue tailored belted wool coat over a charcoal-black silk mock-neck and slim black trousers, with restrained geometric gold earrings. Her crossed-arm silhouette and blue tailoring must read distinctly from Daeun's soft moss duffle coat. `npc_jiyeon_namsan.png` and `namsan_lock_jiyeon_v1.png` own the same outfit.

**Vehicle Canon:** First-contact scene uses an unbranded black S-Class-level luxury sedan, matching `assets/cg/jiyeon_crash_day_v3.png`. The left-hand-drive interior reference is `assets/cg/romance/first_kiss_jiyeon.png`. Full exterior/interior locks live in `assets/VEHICLE_VISUAL_BIBLE.md`. Do not describe it as a white BMW or change the model family between scenes.

**Current Asset Status:** `assets/characters/npc_mentor.png`, `assets/characters/npc_jiyeon_warm.png`, and `assets/characters/npc_jiyeon_cold.png` are identity references. T0 scene outfits are locked by `npc_jiyeon_sea_v2.png`, `npc_jiyeon_fireworks.png`, and `npc_jiyeon_cherry.png`; first kiss reuses `npc_jiyeon_warm.png` because its cream jacket and black inner already match the CG. T1 Namsan uses `npc_jiyeon_namsan.png` paired with `assets/cg/romance/namsan_lock_jiyeon_v1.png`. T1 Narrow Room uses `npc_jiyeon_narrow_door.png` before entry and `npc_jiyeon_narrow_room.png` after the coat comes off, paired with `assets/cg/romance/narrow_room_jiyeon_v1.png`. The Haeundae paired CG is `assets/cg/romance/sea_jiyeon_v2.png`; first contact is `assets/cg/jiyeon_crash_day_v3.png`.

**Negative Prompt / Prohibited:** middle-aged mentor, short bob as default identity, office background, cafe background, smiling auntie, professor, generic businesswoman, white BMW, photoreal DSLR portrait.

## Recurring Minor NPCs

These characters are not main routes, but they have stable IDs and can recur. They must use transparent portraits, not baked room/office/racetrack backgrounds.

### Lee Minseo

**Role:** Self-made Gangnam apartment owner and late-game mirror. She is a living proof that Minjun's goal can be reached, but also the person who asks what remains after arrival.

**Age:** 38. She should read as mature late-30s, not a college student and not an old-money heiress.

**Visual Core:** Korean woman with short neat dark hair, calm but tired eyes, composed mouth, and a practical speaker/mentor posture. Her face should carry success plus aftertaste, not seduction.

**Class Signal:** Charcoal-gray tailored blazer over an ivory knit/blouse. Understated professional Seoul polish, self-made and practical. Minimal small earrings are acceptable; no luxury jewelry aura, no designer-logo styling.

**Current Asset Status:** `npc_minseo.png` added on 2026-07-03 as a transparent 512x768 portrait for `arc_minseo_01_meet`, `arc_minseo_02_real`, `arc_minseo_03_arrival`, and `arc_minseo_03b_not_arrived`.

**Negative Prompt / Prohibited:** long old-money heroine hair, Han Jiyeon-like dangerous glamour, Kim Daeun-like convenience-store softness, teenager look, 50s mentor look, cafe/office/skyline background baked into the portrait, green fringe, visible logos.

### Goshiwon Owner

**Role:** 58-year-old Sinchon goshiwon operator. She pressures rent when needed but is not a cartoon villain; she has seen enough Seoul failures to recognize real trouble.

**Visual Core:** Weathered Korean woman, short slightly permed dark hair with gray strands, practical watchful eyes, stern mouth with hidden warmth.

**Class Signal:** Dark quilted vest over brown patterned blouse/cardigan, small keyring, urban boarding-house operator practicality. Distinct from Mother: sharper, less soft, more landlord/operator energy.

**Current Asset Status:** `npc_goshiwon_owner.png` regenerated on 2026-06-12 as a transparent 512x768 portrait.

### Office Team Lead

**Role:** 47-year-old corporate middle manager used in workplace pressure events. He represents office hierarchy, vague evaluation, and unpaid overtime pressure, not mentorship.

**Visual Core:** Korean man, slightly stocky office build, stern tired eyes, receding or side-parted short black hair, rectangular glasses, clean-shaven.

**Class Signal:** Wrinkled white shirt, loose dark tie, ordinary office slacks, arms-crossed judgment. Distinct from Im Sangchul: cramped salaried authority, no broker charisma or mentor warmth.

**Current Asset Status:** `npc_team_lead.png` regenerated on 2026-06-12 as a transparent 512x768 portrait.

### Park Seongjun

**Role:** 34-year-old high-school friend and third-year 9th-grade civil servant. He is a stable-but-stale peer mirror, not a finance contact.

**Visual Core:** Korean man, tidier and more settled than Minjun, slightly fuller face, neat short black hair, no glasses, gentle tired expression with a restrained bitter smile.

**Class Signal:** Muted brown cardigan or gray civil-service jacket, checked shirt, ID lanyard, bureaucratic modesty. Distinct from Team Lead: no glasses, no white shirt, no tie, no arms-crossed authority pose. Distinct from Hyunsu: slimmer, older, tidier, employed; not exam-prep hoodie.

**Current Asset Status:** `npc_seongjun.png` regenerated on 2026-06-12 as a transparent 512x768 portrait, then revised again the same day to reduce similarity with `npc_team_lead.png`.

### Racetrack Tip Seller

**Role:** 45-50-year-old small-time racetrack information seller. He sells temptation and half-truths, but should remain grounded rather than cartoon-criminal.

**Visual Core:** Thin angular Korean man, slight stubble, narrow clever eyes, weathered smile, furtive posture.

**Class Signal:** Black baseball cap, dark worn windbreaker, cheap scarf/collar, folded racing-form papers. Distinct silhouette: cap plus papers.

**Current Asset Status:** `npc_tip_seller.png` regenerated on 2026-06-12 as a transparent 512x768 portrait.
