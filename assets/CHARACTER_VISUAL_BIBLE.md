# Gangnam Dream Character Visual Bible

Updated: 2026-07-24

This file is the visual canon for recurring characters. It overrides older one-off prompt notes when there is a conflict. Recurring character portraits must be generated as transparent-background PNGs and then composited over location backgrounds in Godot.

## Global Rules

- Major recurring characters must not be baked into rooms, cars, streets, cafes, offices, or other locations.
- Portrait identity must stay stable across expressions: same age, face structure, hair, body type, styling tier, and social class signal.
- CGs may include characters and backgrounds only when they depict one specific scene.
- Consistency beats isolated image beauty. A beautiful image that contradicts the story is a failed asset.
- International readability matters: each major character must be distinguishable at a one-second glance by silhouette, age band, hair shape, outfit color, social-class signal, and posture. Do not rely only on subtle facial differences.
- `assets/cast_detail_manifest.json` (`CAST_DETAIL_CONTRACT_V1`) owns the A/B/C render hierarchy. This bible owns identity inside that hierarchy.
- A-tier story anchors retain full facial acting, gaze, outfit continuity, and restrained color. Hyunsu is A-tier because his long-running relationship and route memory matter, even when he appears among wedding guests.
- B-tier scene actors retain a distinct silhouette, age/class signal, and simplified readable face. They are not interchangeable gray bodies.
- Only C-tier atmospheric extras may be rendered without facial features. Use two or three low-contrast value planes, varied scene-correct posture, and depth separation; never use a pure-black cardboard silhouette or cloned crowd.
- A named speaker, a person whose gaze carries the scene, or anyone affected by a player choice cannot be demoted to C-tier to hide generation defects.
- `assets/CAST_TIME_VISUAL_BIBLE.md` and `content/meta/cast_visual_years.json`
  own the independent `y1`/`y3`/`y5` time axis. Relationship expression,
  event-specific clothing, and Moral Tint remain separate axes.
- Chapters 1-2 use `y1`, chapters 3-4 use `y3`, and chapter 5 uses `y5`.
  A missing later portrait must fall back to the canonical source rather than
  blanking the actor or inventing a context change.
- Five years must read through grooming, posture, fatigue, confidence, and
  wardrobe maintenance, not exaggerated wrinkles or sudden middle age.
- Do not use the same hunched frontal bust pose as shorthand for hardship across
  the cast. Emotion belongs first in gaze, jaw, hands, weight distribution, and
  breathing. Posture remains a character silhouette and changes only as much as
  the scene acting requires.

## Cast Readability Locks

- Kim Minjun: black worn sweatshirt, short messy black hair, no glasses, lean debt-fatigue posture.
- Kang Hyunsu: chubby but likable 26-27-year-old exam-prep neighbor, round wire-frame glasses, soft round face, messy medium black hair, faded olive-gray zip hoodie, muted burgundy striped shirt, awkward warm half-smile.
- Choi Jaehyuk: sharp hair, dark suit, confident/charming smile or shadowed pressure, polished success signal.
- Im Sangchul: 52-year-old broker, salt-and-pepper hair, practical suit jacket, weathered mentor expression.
- Cafe Folder Owner: lean 39-year-old investor, angular face, swept-back black hair, teal open collar, charcoal micro-check suit, blank black folio, skeptical screen-left gaze.
- Manager Kim: stocky 45-year-old broker, round-square face, close side part, cheek mole, taupe blazer, oxblood knit, blank black phone, practiced sales smile.
- Father: 63-year-old factory worker with one stable lean face; work jacket only outside/at work, old burgundy polo and gray-brown zip knit at home, blue-gray patient gown in hospital.
- Kim Daeun: ordinary convenience-store survival warmth, beige cardigan/navy work shirt, soft tired eyes.
- Han Jiyeon: long black hair, cream/black tailored suit, old-money jewelry, dangerous high-status aura.
- Lee Minseo: 38-year-old self-made Gangnam arrival mentor, short neat dark hair, charcoal practical blazer, calm tired eyes.

## Posture Readability Locks

- Kim Minjun: guarded and lean, with a slight downward head angle, but his spine
  remains readable. A tired Minjun relaxes his shoulders without folding his
  chest; a determined Minjun squares them. Every emotion must not reuse one
  defeated slump.
- Kim Daeun: modest and careful, yet upright enough to read as an adult who
  works long shifts. Shyness may narrow her gestures, not cave in her torso.
- Han Jiyeon: level chin, open upper chest, and controlled asymmetry. Her danger
  comes from stillness and eye contact, never from the same rounded shoulders as
  Minjun or Hyunsu.
- Kang Hyunsu: soft rounded build and relaxed weight, with an approachable
  slouch only in study/rest contexts. His neck and chest do not collapse.
- Choi Jaehyuk: polished upright posture and deliberate shoulder line, even
  when exhausted. Pressure tightens his stillness rather than bending him into
  Minjun.
- Im Sangchul: grounded, practiced adult posture with a slight conversational
  lean. He is not a second Jaehyuk and not an elderly stoop.
- Father: a mild working-life stoop belongs to his age and history. It becomes
  heavier only in explicit weak/hospital states and must not spread to younger
  cast portraits.

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

**Current Asset Status:** `main_character_neutral_goshiwon.png`, `main_character_determined.png`, `main_character_happy.png`, and `main_character_shocked.png` were regenerated on 2026-06-12 as transparent portraits. `main_character_tired.png` was replaced on 2026-07-25 with the same black-crewneck identity, clearly open downcast eyes, and a relaxed but non-collapsed posture; redness, sickly half-closed eyelids, and the universal defeated slump are prohibited. `main_character_unemployed.png`, `main_character_part_time.png`, `main_character_office.png`, and `main_character_corporate.png` were added on 2026-06-12 for runtime outfit switching. Each job family now owns explicit `_y3` and `_y5` transparent anchors; the `y1` source remains the canonical base. The `neutral_goshiwon` filename is legacy for the transparent file only; do not bake a room into that portrait. Moral-threshold vignettes compose the separate canonical goshiwon background behind it at runtime.

**Runtime Outfit Rules:** `ImageRegistry.get_player_context_portrait()` is the source of truth. Survival jobs (`job_01`, `job_02`) use part-time workwear; ordinary low/mid-tier office/education/tech jobs use office wear; `job_08`, finance, sales, and tier 3+ jobs use corporate suit. Stress/critical/milestone states still override with tired/shocked/happy emotional portraits.

**Climate Outfit Locks:** Explicit weather events override generic tired/job clothing. `player_monsoon` uses a wet charcoal rain shell over muted navy; `player_heatwave` uses a washed short-sleeve charcoal tee and pale cooling towel; `player_cold_snap` uses a dark olive-charcoal padded parka and knit scarf. These variants preserve Minjun's exact 33-year-old face and class signal and may not leak into unrelated indoor events.

**Moral Threshold Acting Lock:** Every hidden band-crossing vignette returns to the same starting goshiwon, black crewneck, camera, and comparable room exposure. Light Black uses the tired/downcast portrait, Deep Black the hardened direct gaze, Gray the neutral starting face, and both White stages the same restrained small smile; stronger White is distinguished by recovered color and room ambience, not a larger grin. `ImageRegistry.get_player_moral_portrait()` is the runtime source of truth. Do not substitute current job clothing, a new room, a villain snarl, a saintly glow, or a different face.

**CG Outfit Rule:** Personal dates, hospital visits, family scenes, and off-duty romance beats use the worn black crewneck locked by `player_romance_casual`, regardless of Minjun's current job. Office/corporate clothing appears in a CG only when the scene text explicitly places him at work, arriving directly from work, or performing public success. Every future CG job must name the matching Minjun portrait reference.

**Commitment Formalwear Rule:** Daeun's proposal keeps the off-duty black crewneck because it happens across a cafe table, not at work. Both Daeun wedding variants use the same clean charcoal suit and dark tie; Jiyeon's wedding-scale negotiation uses an inexpensive but properly fitted charcoal suit. These formal looks belong only to the explicit ceremony/planning scenes and never infer a corporate job tier.

**CG Acting Rule:** `main_character_unemployed.png` locks Minjun's face, hair, age, and class signal only. Its defeated neutral expression is never an expression reference for a good scene. Every CG must declare scene-specific acting: reassurance, reciprocal eye contact, laughter, surprise, anger, or grief as the prose requires. A date, kindness, or success scene that leaves him chronically hollow fails identity QA even when the facial geometry matches.

**Negative Prompt / Prohibited:** goshiwon room inside portrait, phone prop, visible hands holding phone, large window, skyline, luxury styling, old-man epilogue look, teenage look, photoreal DSLR portrait, changing face between outfit variants.

## Kim Youngsu (Father)

**Role:** Minjun's 63-year-old father, a retired-or-near-retirement Changwon factory worker whose silence, illness, and deferred Seoul dream anchor the family route. He is not a generic elderly patient or a permanently uniformed worker.

**Visual Core:** Lean Korean man in his early 60s, short salt-and-pepper hair, long narrow face, tired deep-set eyes, weathered skin, restrained mouth, and slightly stooped working-life shoulders. The face, hairline, age, and body remain identical across every wardrobe and health state.

**Context Wardrobe Locks:**
- `father_normal` / `father_proud`: worn navy factory/work jacket over a dark checked work shirt. Use only for work, outdoor arrival, or explicitly work-linked memories.
- `father_past`: the same face and work clothes at age 57, six years before the 2026 present. Hair is darker, forehead and eye wrinkles are shallower, and his gaze is lowered by the debt humiliation. Use only for the 2020 guarantor-debt flashback; never substitute it for the present-day 63-year-old Father.
- `father_home`: faded muted burgundy polo under an old warm gray-brown zip-front knit cardigan, loose fit, stretched ribbing, and mild pilling. Use for Changwon-home meetings, memories, and ordinary calls whose remote portrait shows him at home.
- `father_home_weak`: the exact same home clothes and identity with lowered gaze, heavier eyelids, and illness fatigue. Use for the late pre-ending call from Changwon home; illness changes acting, not clothes.
- `father_hospitalized`: faded pale blue-gray Korean hospital wrap gown. Use whenever Father is physically present as an admitted patient or emerges from inpatient testing.
- `father_weak`: worn work-jacket crisis variant retained only for non-home, non-ward travel or outdoor contexts that explicitly require those clothes.

**Location Contract:** A `changwon_home` scene may never show the work jacket when Father's remote or present portrait is visible. A `changwon_hospital` inpatient scene may never show workwear or homewear. Phone scenes keep the local room as the full background and place Father in the remote inset; the portrait does not imply he is standing inside Minjun's room.

**Negative Prompt / Prohibited:** fashionable minimalist cardigan, luxury knitwear, permanent work uniform inside the family home, work jacket over a hospital gown, patient gown outside hospital, generic 75+ grandfather, current 63-year-old face reused in the six-years-earlier debt flashback, face drift between age or health states, broad commercial smile, baked room or ward background.

## Kang Hyunsu

**Role:** Goshiwon neighbor and fourth-year civil-service-exam student. He is Minjun's stalled younger peer mirror, not another protagonist skin.

**Age:** 26-27. The first intro event describes him as around 26 and he calls Minjun "hyung"; do not age him into a middle-aged friend.

**Visual Core:** Chubby/stocky but youthful and likable Korean man. Round wire-frame glasses, soft round face, slightly messy medium black hair, gentle tired eyes, clean-shaven or only extremely faint stubble, slouched exam-taker shoulders, awkward warm half-smile.

**Class Signal:** Faded olive-gray zip hoodie over a muted burgundy striped shirt. Cheap, worn, study-room survival clothes, but clean enough to be lovable. This color block is intentional to separate him from Minjun's black sweatshirt.

**Current Asset Status:** `npc_close_friend.png` regenerated again on 2026-06-12 as a transparent portrait after the first readability redesign made him too middle-aged and low-appeal for a visual novel cast. Current version targets a friendly chubby late-20s exam-prep junior. Later accounting/civil-service portraits preserve that exact face under work clothes. The Daeun wedding reaction uses the same broad soft face, full cheeks, low gentle eye shape, medium wavy hair, and thin round glasses under a navy guest suit and muted burgundy tie; a merely stocky generic man with glasses is not Hyunsu.

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
- First snow: muted cranberry quilted winter coat over charcoal layers, oatmeal knit scarf, dark trousers; December only.
- First kiss: navy work polo and beige cardigan after the convenience-store closing shift.

**Namsan Outfit Lock:** Muted moss-green short duffle coat over an ivory ribbed knit and dark straight jeans. The practical fabric and modest silhouette must remain distinct from Jiyeon's tailored sapphire coat. `npc_daeun_namsan.png` and `namsan_lock_daeun_v1.png` own the same outfit and short-hair identity.

**Amusement Park Outfit Lock:** Muted slate-blue cotton chore jacket over an ivory crewneck knit, dark straight jeans, and a charcoal canvas crossbody strap. It is a mild-weather outfit and may appear only in March-May or September-November. `npc_daeun_amusement.png` and `amusement_lost_child_daeun_v1.png` own the same outfit and child-directed gaze.

**Hometown Summer Outfit Lock:** Pale sage lightweight cotton overshirt with sleeves rolled below the elbows over an ivory T-shirt, dark navy trousers, and a charcoal shoulder strap. `npc_daeun_hometown_worried.png`, `npc_daeun_hometown_warm.png`, and `hometown_night_bus_daeun_v1.png` own one continuous outfit across the train, mother's table, and return bus. The trip begins only in June-August; full continuity lives in `assets/HOMETOWN_VISUAL_BIBLE.md`.

**First Night Outfit Lock:** Muted dusty-mauve soft-knit wrap cardigan over a cream square-neck cotton top with charcoal lounge trousers. `npc_daeun_wedding_night.png` and `wedding_morning_daeun_v1.png` own the same indoor-all-season outfit. The morning CG preserves her short hair, left-temple clip, wedding ring, and physically coherent pan/spatula action; full continuity lives in `assets/FIRST_MORNING_VISUAL_BIBLE.md`.

**Breakup Outfit Lock:** `breakup_daeun_v1.png` retains the same dusty-mauve cardigan, cream home top, charcoal trousers, short hair, and left-temple clip. She is physically in the adjacent room before the reveal, so `arc_daeun_final_choice` must not show a floating convenience-store portrait. The CG alone owns the single red seal and blank separation agreement; full continuity lives in `assets/BREAKUP_VISUAL_BIBLE.md`.

**Proposal Outfit Lock:** Deep muted berry-red fine-knit date dress with a modest square neckline under a soft charcoal cropped cardigan. `npc_daeun_proposal.png` and `proposal_daeun_v1.png` preserve the same short hair, left-temple clip, adult proportions, and screen-left eye line. The portrait is the unaware pre-choice state; the accepted CG alone owns the hand-over-mouth reaction and open ring box.

**Wedding Day Outfit Lock:** The small wedding uses a simple ivory A-line dress, short veil, small greenery bouquet, and natural makeup. The full package uses a refined ivory A-line gown, restrained beaded bodice, longer veil, larger bouquet, and professional makeup without changing Daeun's face or age. Minjun enters first and waits at the altar; the small/full couple-wide and couple-close assets identify only Minjun and Daeun, preserving their mutual gaze while all background people remain faceless silhouettes. Parent continuity lives in separate reaction shots: Daeun's mother sits naturally in the screen-left bride-side front-row aisle seat, wears one muted dusty-rose jeogori, ivory collar, and deep muted raspberry chima contemporary honju hanbok, and looks toward the doors her daughter will enter through. Minjun's father occupies the screen-right groom-side front-row aisle seat in a dark charcoal honju suit and also looks toward the unseen bride; `father_passed` leaves that chair entirely empty, while `hyunsu_reconnected` places Hyunsu alone one full row behind. No single frame may combine the couple, both parents, Hyunsu, and the empty-chair branch again. Full continuity lives in `assets/COMMITMENT_VISUAL_BIBLE.md`.

**Current Asset Status:** `assets/characters/npc_romantic_interest.png`, `assets/characters/npc_daeun_smile.png`, and `assets/characters/npc_daeun_sad.png` are the identity references. T0 scene outfits are locked by `npc_daeun_sea_v2.png`, `npc_daeun_fireworks.png`, `npc_daeun_cherry.png`, and December-only `npc_daeun_first_snow.png`; first kiss reuses `npc_daeun_smile.png` because its work outfit already matches the CG exactly. T1 Namsan uses `npc_daeun_namsan.png` paired with `assets/cg/romance/namsan_lock_daeun_v1.png`. T1 Amusement Park uses `npc_daeun_amusement.png` paired with `assets/cg/romance/amusement_lost_child_daeun_v1.png`. T1 Hometown uses `npc_daeun_hometown_worried.png` and `npc_daeun_hometown_warm.png` paired with `assets/cg/romance/hometown_night_bus_daeun_v1.png`. T1 First Morning uses `npc_daeun_wedding_night.png` paired with `assets/cg/romance/wedding_morning_daeun_v1.png`. T1 Commitment uses `npc_daeun_proposal.png` paired with `proposal_daeun_v1.png`, followed by one mother reaction, four groom-side state reactions, two small/full couple-wide assets, and two matching small/full couple-close assets. T2 rupture uses the full-scene `assets/cg/romance/breakup_daeun_v1.png` and deliberately hides her pre-reveal portrait. The East Sea paired CG is `assets/cg/romance/sea_daeun_v3.png`; first-snow continuity is owned by `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

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

**First Snow Outfit Lock:** Deep charcoal tailored cashmere coat over a dark garnet turtleneck, black trousers, and restrained geometric earrings. `npc_jiyeon_first_snow.png`, `jiyeon_sedan_first_snow_interior.png`, and `first_snow_jiyeon_v1.png` share the December-only left-hand-drive sedan contract in `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

**Narrow Room Outfit Lock:** At Minjun's door she wears a travel-creased charcoal long coat open over a deep muted oxblood fine-knit top. Inside, the coat is removed and the same oxblood top is paired with charcoal trousers. Makeup is nearly absent, hair is slightly disordered, and her gaze loses its normal status composure without changing her identity. The long-coat prelude starts only in January-April or October-December and waits outside those months.

**First Night Outfit Lock:** Deep midnight-blue matte-silk wrap lounge blouse with muted burgundy piping and black tailored lounge trousers. `npc_jiyeon_wedding_night.png` and `wedding_morning_jiyeon_v1.png` own the same indoor-all-season outfit. The morning CG removes makeup, disorders but does not shorten her long hair, and allows direct gaze only because the camera is Minjun's explicit POV; full continuity lives in `assets/FIRST_MORNING_VISUAL_BIBLE.md`.

**Namsan Outfit Lock:** Deep sapphire-blue tailored belted wool coat over a charcoal-black silk mock-neck and slim black trousers, with restrained geometric gold earrings. Her crossed-arm silhouette and blue tailoring must read distinctly from Daeun's soft moss duffle coat. `npc_jiyeon_namsan.png` and `namsan_lock_jiyeon_v1.png` own the same outfit.

**Amusement Park Outfit Lock:** Deep wine-red tailored suede cropped jacket over a charcoal-black silk mock-neck and fitted black trousers, with restrained geometric gold earrings. It is a mild-weather outfit and may appear only in March-May or September-November. `npc_jiyeon_amusement.png` and `amusement_photo_strip_jiyeon_v1.png` own the same outfit across all four booth frames.

**Wedding Negotiation Outfit Lock:** Tailored ivory planning suit over a black silk inner layer, long black waves, and restrained geometric earrings. `wedding_gap_jiyeon_v1.png` is a pre-decision class negotiation with Jiyeon's father, not a bridal portrait or completed wedding. Jiyeon watches her father with controlled tension while Minjun looks toward the sparse groom-side cards; full continuity lives in `assets/COMMITMENT_VISUAL_BIBLE.md`.

**Breakup Outfit Lock:** `breakup_jiyeon_v1.png` uses the same ivory tailored outer layer, black inner layer and trousers, geometric earrings, structured black handbag, and waist-length waves. She exits through a real apartment door into an indoor corridor without turning back; no suitcase, bridal styling, street behind the door, or lens gaze. Full continuity lives in `assets/BREAKUP_VISUAL_BIBLE.md`.

**Vehicle Canon:** First-contact scene uses an unbranded black S-Class-level luxury sedan, matching `assets/cg/jiyeon_crash_day_v3.png`. The left-hand-drive interior reference is `assets/cg/romance/first_kiss_jiyeon.png`. Full exterior/interior locks live in `assets/VEHICLE_VISUAL_BIBLE.md`. Do not describe it as a white BMW or change the model family between scenes.

**Current Asset Status:** `assets/characters/npc_mentor.png`, `assets/characters/npc_jiyeon_warm.png`, and `assets/characters/npc_jiyeon_cold.png` are identity references. T0 scene outfits are locked by `npc_jiyeon_sea_v2.png`, `npc_jiyeon_fireworks.png`, `npc_jiyeon_cherry.png`, and December-only `npc_jiyeon_first_snow.png`; first kiss reuses `npc_jiyeon_warm.png` because its cream jacket and black inner already match the CG. T1 Namsan uses `npc_jiyeon_namsan.png` paired with `assets/cg/romance/namsan_lock_jiyeon_v1.png`. T1 Amusement Park uses `npc_jiyeon_amusement.png` paired with `assets/cg/romance/amusement_photo_strip_jiyeon_v1.png`. T1 Narrow Room uses `npc_jiyeon_narrow_door.png` before entry and `npc_jiyeon_narrow_room.png` after the coat comes off, paired with `assets/cg/romance/narrow_room_jiyeon_v1.png`. T1 First Morning uses `npc_jiyeon_wedding_night.png` paired with `assets/cg/romance/wedding_morning_jiyeon_v1.png`. T1 Commitment uses the full-scene `assets/cg/romance/wedding_gap_jiyeon_v1.png` and deliberately has no reusable bridal portrait because the authored scene stops before the outcome. T2 rupture pairs `npc_jiyeon_cold.png` with `assets/cg/romance/breakup_jiyeon_v1.png` only after the release result reaches the doorway action. The Haeundae paired CG is `assets/cg/romance/sea_jiyeon_v2.png`; first contact is `assets/cg/jiyeon_crash_day_v3.png`; first-snow car staging is owned by `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

**Negative Prompt / Prohibited:** middle-aged mentor, short bob as default identity, office background, cafe background, smiling auntie, professor, generic businesswoman, white BMW, photoreal DSLR portrait.

## Recurring Minor NPCs

These characters are not main routes, but they have stable IDs and can recur. They must use transparent portraits, not baked room/office/racetrack backgrounds.

### Cafe Folder Owner

**Role:** The unnamed man whose document folder Minjun sees in the Gangnam cafe. He tests bluffing, recognizes honest desperation, and can become a clean network contact. He is not the phone number written in the folder.

**Visual Core:** Lean 39-year-old Korean man with an angular face, narrow monolid eyes, swept-back black hair, and a restrained skeptical half-smile. His body and gaze turn screen-left toward Minjun.

**Class Signal:** Tailored charcoal micro-check suit over a muted deep-teal open-collar knit polo, no tie, with a blank matte-black document folio. Self-made property-investor polish without Sangchul's age, Jaehyuk's seduction, or Team Lead's salaried authority.

**Current Asset Status:** `npc_cafe_investor.png` is the transparent 512x768 source for `cafe_investor`. It owns the initial cafe chain, honest/humiliated callbacks, and explicit later mentor messages. `cafe_peek_01` reveals it only when the man returns in paragraph 1.

**Negative Prompt / Prohibited:** Manager Kim's broad body or taupe/oxblood palette, rectangular office glasses, salt-and-pepper mentor hair, young all-black Jaehyuk styling, readable folio text, cafe background baked into the portrait.

### Manager Kim

**Role:** The separate broker whose number is written inside the cafe folder. He does not remember Minjun on the stolen-number route, inflates the entry pass with a service-fee markup, and can return with later high-risk or no-commission offers.

**Visual Core:** Stocky 45-year-old Korean man with a broad round-square face, close side-parted black hair, thick eyebrows, small assessing eyes, and a cheek mole. His practiced sales smile is plausible rather than cartoon-villainous.

**Class Signal:** Warm taupe textured blazer over a muted oxblood knit and pale collar, holding a blank black smartphone. He reads as a grounded Seoul property middleman, not corporate management or old-money finance.

**Current Asset Status:** `npc_cafe_broker_kim.png` is the transparent 512x768 source for `cafe_broker_kim`. It owns the stolen-number call, markup negotiation, and every callback that explicitly names Manager Kim.

**Negative Prompt / Prohibited:** the folder owner's lean teal/charcoal silhouette, Team Lead glasses/white shirt/loose tie, Sangchul salt-and-pepper charisma, gangster stereotype, readable phone UI, background baked into the portrait.

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
