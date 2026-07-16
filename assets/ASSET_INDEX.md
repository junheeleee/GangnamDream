# Gangnam Dream Asset Index

Generated on 2026-05-22 for Claude/Godot integration.
Updated on 2026-06-09 for full anime / Korean manhwa VN art direction.
Updated on 2026-06-12 for core-cast transparent portraits, missing backgrounds, cast readability, and family-home regeneration.
Updated on 2026-06-13 for P2 public venue ambient-silhouette backgrounds and Steam key art pass.
Updated on 2026-06-15 for Jeongseon Casino interior/entrance/exterior backgrounds, dedicated gym background, and Seoul landmark backgrounds.
Updated on 2026-06-19 for daytime office interview background separation and BGM/portrait presentation QA.
Updated on 2026-06-20 for dedicated P1 ending CGs and Slot/Roulette/BigWheel chip-button wiring.
Updated on 2026-07-01 for dedicated Korean-culture background pass: hagwon street, Suneung test hall, community center, jjimjilbang, cherry blossom path, saju cafe, and reserve-duty gate.
Updated on 2026-07-01 for workplace/climate surface pass: company dinner restaurant, heatwave city, Seoul street ambience, civil-defense siren, and monsoon rain cue.
Updated on 2026-07-01 for digital/holiday/climate/library surface pass: fine dust sky, Chuseok highway traffic, open chat screen, matching ambience loops, and library-room ambience.
Updated on 2026-07-11 for Daeun's summer hometown train, maternal dining room, paired travel portraits, and delayed night-bus CG.
Updated on 2026-07-03 for Lee Minseo transparent portrait and post-Claude story background alignment.
Updated on 2026-07-11 for paired Namsan observation-deck and love-lock romance assets.
Updated on 2026-07-11 for heroine-specific newlywed homes, same-outfit first-night portraits, and paragraph-delayed first-morning CGs.
Updated on 2026-07-11 for paired first-snow route art and Minjun's explicit monsoon, heatwave, and cold-snap portraits.
Updated on 2026-07-12 for AP in-world scene-still routing; the earlier prop-only action atlases are no longer runtime canon.
Updated on 2026-07-12 for Hyunsu's Seoul terminal result and route-dependent accounting/civil-service portrait stages.
Updated on 2026-07-12 for the separate cafe folder-owner and Manager Kim portrait identities across first meeting and callbacks.
Updated on 2026-07-12 for the player-facing wallet bus-stop bench, winter bungeoppang cart, and canonical Changwon Seollal bow CG.
Updated on 2026-07-12 for Daeun's choice-gated proposal and small/full wedding variants plus Jiyeon's pre-decision wedding-scale negotiation CG.
Updated on 2026-07-12 for eight final-life P0 ending CGs, physically correct Jiyeon mirror geometry, and ending-preview Moral legibility.
Updated on 2026-07-13 for the `late_call` P1 ending CG, final Jiyeon mirror-pose correction, and separate KTX-interior/station semantic IDs.
Updated on 2026-07-13 for the `lonely_rich` P1 dining-table CG and its strict separation from `empty_house`.

## Use These Assets

## Production Asset Architecture

- Recurring character portraits must be transparent-background PNGs and should not contain real rooms, streets, offices, or other location backgrounds.
- Location backgrounds must be reusable environment images.
- Private/canon-sensitive backgrounds should be person-free. Public venues may include small dark faceless ambient silhouettes when emptiness would feel unnatural, but no clear face, no foreground protagonist-like person, and no named-character proxy.
- Story CGs may combine characters and backgrounds only when the whole image represents a specific one-off scene.
- Core recurring-cast transparent portrait pass is complete for Kim Minjun, Han Jiyeon, Kim Daeun, Choi Jaehyuk, Im Sangchul, Father, Mother, and Kang Hyunsu. Minor NPCs may still be placeholders.
- General investment scenes use `assets/backgrounds/investment_phone.png`; multi-monitor rooms are reserved for scalping/pro-trading scenes.

### Character
- `assets/characters/main_character_neutral_goshiwon.png`
  - Main protagonist neutral transparent portrait, full anime / Korean manhwa VN style.
  - Use in event UI portrait area.
  - Legacy filename includes `goshiwon`, but the current asset is background-free.

- `assets/characters/main_character_tired.png`
  - Main protagonist exhausted transparent portrait, same anime identity.
  - Use for failure, debt, burnout, health, and crisis events.

- `assets/characters/main_character_determined.png`
  - Main protagonist focused/determined transparent portrait, same anime identity.
  - Use for recovery, promotion, study, investment resolve, and comeback events.

- `assets/characters/main_character_happy.png`
  - Main protagonist modest happy transparent portrait, same anime identity.
  - Use for windfalls, good news, relationship wins, and rare opportunity events.

- `assets/characters/main_character_shocked.png`
  - Main protagonist shocked/anxious transparent portrait, same anime identity.
  - Use for critical events, hidden events, and major loss/windfall moments.

- `assets/characters/main_character_unemployed.png`
  - Kim Minjun default unemployed outfit variant, transparent portrait.
  - Runtime use: no job and no upward-mobility visual milestone.

- `assets/characters/main_character_part_time.png`
  - Kim Minjun part-time/survival work outfit variant, transparent portrait.
  - Runtime use: survival jobs such as convenience-store night shift and delivery rider.

- `assets/characters/main_character_office.png`
  - Kim Minjun ordinary office-worker outfit variant, transparent portrait.
  - Runtime use: low/mid-tier ordinary office, education, and tech jobs.

- `assets/characters/main_character_corporate.png`
  - Kim Minjun big-company/corporate suit outfit variant, transparent portrait.
  - Runtime use: large corporation, finance, sales, tier 3+ jobs, and upward-mobility no-job states.

- `assets/characters/main_character_monsoon.png`
  - Kim Minjun monsoon portrait: wet charcoal rain shell over muted navy, damp hair and shoulders, restrained rain fatigue.
- `assets/characters/main_character_heatwave.png`
  - Kim Minjun heatwave portrait: washed short-sleeve charcoal tee, pale cooling towel, sweat-damp hair and heat-flushed skin.
- `assets/characters/main_character_cold_snap.png`
  - Kim Minjun cold-snap portrait: dark olive-charcoal padded parka, knit scarf, cold-tense shoulders and face.
  - All three are transparent 512x768 weather-event portraits; they do not replace job/context portraits outside their explicit climate events.

- `assets/characters/main_character_30s.png`
  - Legacy mid-game Kim Minjun portrait with baked room background.
  - Do not use as the default runtime status portrait; prefer `main_character_corporate.png` or future transparent success variants.

- `assets/characters/main_character_50s.png`
  - Older Kim Minjun portrait with bittersweet success mood.
  - Use for late-game, epilogue, and long-horizon ending contexts.

- `assets/characters/npc_romantic_interest.png`
  - Kim Daeun normal transparent portrait, ordinary convenience-store survival romance route.

- `assets/characters/npc_daeun_smile.png`
  - Kim Daeun warm/smiling transparent expression variant for trust, romance, and emotional recovery beats.

- `assets/characters/npc_daeun_sad.png`
  - Kim Daeun sad transparent expression variant for conflict, disappointment, and relationship crisis beats.

- `assets/characters/npc_daeun_sea_v2.png`
  - East Sea T0 outfit portrait: coral-rose wrap swim dress and pale sky-blue cover-up, matched to `sea_daeun_v3.png`.
  - Gaze lock: right-anchored portrait looks screen-left into Minjun/dialogue space rather than at the lens.

- `assets/characters/npc_daeun_fireworks.png`
  - Fireworks T0 outfit portrait: muted blue-gray wrap dress, matched to `fireworks_daeun.png`.

- `assets/characters/npc_daeun_cherry.png`
  - Cherry T0 outfit portrait: pale-blue belted shirt dress and beige cardigan, matched to `cherry_daeun.png`.

- `assets/characters/npc_daeun_namsan.png`
  - Namsan T1 outfit portrait: moss-green short duffle coat over ivory ribbed knit, matched to `namsan_lock_daeun_v1.png`.
  - Gaze lock: right-anchored portrait looks screen-left toward Minjun, with the same short hair and left-temple clip as Daeun's identity reference.

- `assets/characters/npc_daeun_amusement.png`
  - Amusement-park T1 portrait: slate-blue chore jacket, ivory knit, dark jeans, and canvas crossbody strap, matched to `amusement_lost_child_daeun_v1.png`.
  - Mild-weather only (March-May, September-November); child-directed gaze, both hands naturally pocketed.

- `assets/characters/npc_daeun_hometown_worried.png`
  - Hometown T1 train portrait: pale-sage summer overshirt over ivory T-shirt, navy trousers, charcoal shoulder strap, worried screen-left gaze.
- `assets/characters/npc_daeun_hometown_warm.png`
  - Hometown T1 dinner portrait: same exact summer outfit and identity, with a small embarrassed closed-mouth smile.
  - Both are transparent 512x768 assets and are owned by `assets/HOMETOWN_VISUAL_BIBLE.md`.

- `assets/characters/npc_daeun_wedding_night.png`
  - First-night T1 portrait: dusty-mauve wrap cardigan, cream cotton top, charcoal lounge trousers, short hair and left-temple clip.
  - Same indoor outfit continues into `wedding_morning_daeun_v1.png`; owned by `assets/FIRST_MORNING_VISUAL_BIBLE.md`.

- `assets/characters/npc_daeun_first_snow.png`
  - December T0 portrait: muted cranberry quilted coat, oatmeal scarf, charcoal layers, and the same short hair/left-temple clip.
  - Paired with `first_snow_daeun_v1.png`; owned by `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

- `assets/characters/npc_daeun_proposal.png`
  - T1 proposal prelude portrait: muted berry-red fine-knit dress, charcoal cropped cardigan, short hair and left-temple clip, with an unaware screen-left smile.
  - Transparent 512x768. It appears before the commitment choice; the accepted reaction belongs only to `proposal_daeun_v1.png`.

- `assets/characters/npc_boss.png`
  - Im Sangcheol normal transparent portrait, 52-year-old self-made broker/mentor.

- `assets/characters/npc_sangchul_serious.png`
  - Im Sangcheol serious transparent expression variant for warnings, high-stakes information, and morally tense choices.

- `assets/characters/npc_cafe_investor.png`
  - The unnamed cafe folder owner's transparent portrait: lean 39-year-old Korean man, angular face, teal open-collar knit, charcoal micro-check suit, and blank black document folio.
  - Runtime use: `cafe_investor` / `Man at the Cafe` for the initial cafe test, honest/humiliated routes, and clean-investment callbacks. He is not Manager Kim, the office Team Lead, Sangchul, or Jaehyuk.

- `assets/characters/npc_cafe_broker_kim.png`
  - Manager Kim's transparent portrait: stocky 45-year-old Korean broker, round-square face and cheek mole, taupe blazer, oxblood knit, and blank black smartphone.
  - Runtime use: `cafe_broker_kim` / `Manager Kim` for the stolen-number route, markup negotiation, and his explicit later calls. He never owns the cafe folder in the initial scene.

- `assets/characters/npc_close_friend.png`
  - Kang Hyunsu transparent portrait, redesigned as a likable 26-27-year-old chubby exam-prep junior.
  - Distinctive lock: round glasses, soft round face, stockier body, olive-gray hoodie, muted burgundy striped shirt, awkward warm half-smile.

- `assets/characters/npc_hyunsu_accounting.png`
  - Kang Hyunsu settled accounting-route portrait: same round glasses, face, stocky build, hair, and restrained smile in a navy suit, pale shirt, burgundy tie, and blank business card.
  - Runtime use: `hyunsu_accounting` for the reunion and later callbacks when `hyunsu_pivoted` is the known route.

- `assets/characters/npc_hyunsu_civil_service.png`
  - Kang Hyunsu civil-service route portrait: same identity in a practical charcoal jacket, pale shirt, and blank clipped badge.
  - Runtime use: `hyunsu_civil_service` when `hyunsu_passed` is known. Do not add readable government names or reuse Park Seongjun's lanyard silhouette.

- `assets/characters/npc_mentor.png`
  - Han Jiyeon normal transparent portrait.
  - Production status: approved for first in-game QA. 31-year-old wealthy Gangnam heroine, long black hair, cream jacket, black inner top.

- `assets/characters/npc_jiyeon_warm.png`
  - Han Jiyeon warm transparent expression variant for private trust, romance, and emotionally open scenes.
  - Production status: approved for first in-game QA. Same identity/outfit as `npc_mentor.png`.

- `assets/characters/npc_jiyeon_cold.png`
  - Han Jiyeon cold transparent expression variant for negotiation, status pressure, and calculating investor scenes.
  - Production status: approved for first in-game QA. Same identity/outfit as `npc_mentor.png`.

- `assets/characters/npc_jiyeon_sea_v2.png`
  - Haeundae T0 outfit portrait: deep emerald asymmetric swim dress, smoke-gray cover-up, and silver jewelry, matched to `sea_jiyeon_v2.png`.
  - Gaze lock: right-anchored portrait looks screen-left toward Minjun/dialogue space rather than at the lens.

- `assets/characters/npc_jiyeon_fireworks.png`
  - Fireworks T0 outfit portrait: unbranded deep-charcoal hooded windbreaker, matched to `fireworks_jiyeon.png`.

- `assets/characters/npc_jiyeon_cherry.png`
  - Cherry T0 outfit portrait: warm-cream spring jacket over black, matched to `cherry_jiyeon.png`.

- `assets/characters/npc_jiyeon_namsan.png`
  - Namsan T1 outfit portrait: deep sapphire tailored belted coat over charcoal-black, matched to `namsan_lock_jiyeon_v1.png`.
  - Gaze lock: lowered screen-left gaze studies a scene object rather than addressing the lens.

- `assets/characters/npc_jiyeon_amusement.png`
  - Amusement-park T1 portrait: wine-red tailored suede jacket over charcoal-black, matched across all four frames of `amusement_photo_strip_jiyeon_v1.png`.
  - Mild-weather only (March-May, September-November); challenging eye line toward Minjun, both hands pocketed.

- `assets/characters/npc_jiyeon_narrow_door.png`
  - T1 Narrow Room prelude portrait: travel-creased charcoal coat worn open over a muted oxblood top, nearly bare face, exhausted screen-left gaze.

- `assets/characters/npc_jiyeon_narrow_room.png`
  - T1 Narrow Room interior portrait: coat removed, muted oxblood fine-knit top, relaxed shoulders and vulnerable screen-left gaze, matched to `narrow_room_jiyeon_v1.png`.

- `assets/characters/npc_jiyeon_wedding_night.png`
  - First-night T1 portrait: midnight-blue matte-silk lounge blouse with muted burgundy piping and black tailored lounge trousers.
  - Same indoor outfit continues into `wedding_morning_jiyeon_v1.png`; owned by `assets/FIRST_MORNING_VISUAL_BIBLE.md`.

- `assets/characters/npc_jiyeon_first_snow.png`
  - December T0 portrait: deep charcoal tailored coat over a dark garnet knit with restrained geometric earrings.
  - Paired with the recurring left-hand-drive black sedan in `first_snow_jiyeon_v1.png`; owned by `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

- `assets/characters/npc_minseo.png`
  - Lee Minseo transparent portrait, 38-year-old self-made Gangnam arrival mentor.
  - Runtime use: `minseo` / `minseo_normal` portrait IDs in late-game Minseo arc events.
  - Readability lock: short neat dark hair, charcoal practical blazer, ivory knit/blouse, calm tired eyes; must not resemble Han Jiyeon's long-haired old-money aura or Kim Daeun's soft convenience-store warmth.

- `assets/characters/npc_tip_seller.png`
  - Horse-racing tip seller transparent portrait, 45-50-year-old track information seller with cap, worn windbreaker, and folded racing forms.

- `assets/characters/npc_father.png`
  - Kim Minjun's father work/outdoor transparent portrait, 63-year-old Changwon factory-worker dignity and guilt.

- `assets/characters/npc_father_weak.png`
  - Kim Minjun's father weakened work/outdoor variant for non-home, non-ward crisis contexts.

- `assets/characters/npc_father_home.png`
  - Kim Minjun's father at-home transparent portrait: faded burgundy polo and old gray-brown zip knit; normal Changwon-home presence and remote calls.

- `assets/characters/npc_father_home_weak.png`
  - Same at-home identity and clothes with restrained illness fatigue for the late pre-ending call.

- `assets/characters/npc_father_hospitalized.png`
  - Same identity in a pale blue-gray inpatient gown, reserved for admitted-patient and ward scenes.

- `assets/characters/npc_mother.png`
  - Kim Minjun's mother transparent portrait, tired and warm 61-year-old family-wound axis.

- `assets/characters/npc_jaehyuk.png`
  - Choi Jaehyuk normal transparent portrait, charismatic but morally dangerous.

- `assets/characters/npc_jaehyuk_shadow.png`
  - Choi Jaehyuk shadowed transparent expression variant for betrayal, danger, and underworld pressure scenes.

- `assets/characters/npc_team_lead.png`
  - Korean office team leader transparent portrait for workplace pressure events, 47-year-old middle manager with wrinkled shirt and loose tie.

- `assets/characters/npc_goshiwon_owner.png`
  - Goshiwon owner/manager transparent portrait, 58-year-old practical Sinchon boarding-house operator.

- `assets/characters/npc_seongjun.png`
  - Park Seongjun transparent portrait, 34-year-old high-school friend and third-year 9th-grade civil servant.
  - Readability lock: no glasses, muted cardigan/jacket, ID lanyard; must not resemble the office team lead.

### Backgrounds
- `assets/backgrounds/goshiwon_room.png`
  - Starting room / poor early-life background.
  - Canonical goshiwon layout: tiny high frosted ventilation window, narrow bed, low foldable desk at the bed foot / screen-bottom foreground, no scenic city view.

- `assets/backgrounds/oneroom_apartment.png`
  - Mid-game housing upgrade background.

- `assets/backgrounds/gangnam_apartment.png`
  - Late-game success / ending target background.

- `assets/backgrounds/seoul_rainy_street.png`
  - General event background for social life, jobs, crisis, night-city events.
  - Status: P2 regenerated as rainy Seoul side street without a clear central pedestrian/protagonist figure.

- `assets/backgrounds/street_seoul_day.png`
  - Daytime Seoul street background for ordinary errands, social pressure, and neutral city-life scenes.

- `assets/backgrounds/seoul_subway.png`
  - Late-night transit background for commute, loneliness, job, and fatigue events.

- `assets/backgrounds/seoul_bus_terminal_night.png`
  - Person-free Seoul intercity terminal at night for the goodbye result of `arc_y2_hyunsu_night_bus`.
  - The coach door faces the curbside platform; vehicle lane, tactile paving, waiting seats, terminal glass, and pedestrian circulation remain physically separate. Keep the right edge readable under Hyunsu's portrait and do not reuse it as an ordinary city bus stop.

- `assets/backgrounds/seoul_bus_stop_wallet.png`
  - One-off rainy Seoul neighborhood bus shelter for `amb_wallet_00`.
  - The bench runs parallel to the curb and faces the roadway; the camera sees its back, the full front glass windbreak, open boarding doorway, tactile paving, curb, and bus lane as one usable path.
  - Exactly one wallet remains under the bench and above the StoryMode dialogue/choice safe area. Do not reuse it as a generic empty bus stop because the wallet is baked into the event background.

- `assets/backgrounds/heatwave_city.png`
  - Dry Seoul heatwave street background for August heat-alert events.
  - Use for `heatwave_city` inferred/explicit backgrounds and `kx_heatwave`.
  - Status: approved for first in-game QA. Person-free, no readable signs/logos, dry asphalt/heat haze signal.

- `assets/backgrounds/seoul_cold_snap_street.png`
  - Person-free working-class Seoul street with frozen asphalt, bare trees, light snow residue, and immediately readable curb/road geometry.
  - Use only for explicit cold-snap and severe-winter outdoor events.

- `assets/backgrounds/winter_bungeoppang_stall.png`
  - One-off winter Seoul alley background for `kx_street_food`.
  - Screen-left cart shows fish-shaped molds, finished bungeoppang, brown paper bags, fish-cake broth, cups, and warm steam; the vendor is an anonymous obscured silhouette and the right third stays clear for Minjun's winter portrait.
  - No readable price/menu, brand, recurring face, or protagonist is baked into the background.

- `assets/backgrounds/year2_winter_last_night.png`
  - Person-free late-December Seoul residential street at night for `arc_year2_close` only.
  - Preserves the canonical cold-snap street architecture while replacing daylight with practical streetlamps and sparse window light. Do not reuse as a generic snowy street.

- `assets/backgrounds/fine_dust_sky.png`
  - Dry yellow-gray Seoul street under fine dust / yellow dust conditions.
  - Use for `fine_dust_sky` inferred/explicit backgrounds and `kx_fine_dust`.
  - Status: approved for first in-game QA. Person-light, no rain, no readable signs/logos, road/sidewalk geometry clear.

- `assets/backgrounds/chuseok_highway.png`
  - Chuseok homecoming traffic on a Korean expressway with brake-light congestion.
  - Use for `chuseok_highway` inferred/explicit backgrounds and `kx_chuseok_traffic`.
  - Status: approved for first in-game QA. No readable plates/signs/logos; traffic direction and highway structure are clear.

- `assets/backgrounds/open_chat_screen.png`
  - Goshiwon desk with smartphone chat bubbles for anonymous open-chat / group-chat scenes.
  - Use for `open_chat_screen` inferred/explicit backgrounds, `kx_open_chat`, and `geojibang_chat`.
  - Status: approved for first in-game QA. Brand-free abstract chat UI only; no readable fake text, no app logo, no wall note text.

- `assets/backgrounds/sangchul_private_dining.png`
  - One-off Gangnam private dining/networking room for `arc_sangchul_03_network`.
  - Two physically coherent table groups, blank business cards, restrained fine-dining service, and anonymous background-only business silhouettes make the social machinery visible without baking Sangchul or Minjun into the room.
  - The right third stays quiet for Sangchul's separate portrait. Do not reuse for public restaurant, company dinner, or generic meeting events.

- `assets/backgrounds/hangang_riverside_walk.png`
  - Han River evening promenade background for Seoul rest, walking, running, romance, and reflective callback events.
  - Use for `hangang_riverside` inferred backgrounds and explicit `hangang` tags.
  - Status: approved for first in-game QA. 1280x800, blue-hour river, bridge, skyline, benches, lamps, only distant anonymous silhouettes, no readable signs/logos.

- `assets/backgrounds/year3_hangang_winter_night.png`
  - Late-December Han River promenade for `arc_year3_close` only.
  - Bare branches, dormant shrubs, dark water, restrained practical lights, and no foreground character. It must not replace the mild-weather riverside used by dates and ordinary walks.

- `assets/backgrounds/year4_winter_rooftop.png`
  - Person-free late-December old-Seoul rooftop for `arc_year4_close` only.
  - Preserves the canonical door, water tank, parapet, antennas, and skyline while removing laundry and leafy planters. The empty center is reserved for Minjun's separate winter portrait.

- `assets/backgrounds/namsan_tower_view.png`
  - Namsan Tower night overlook background for aspirational Seoul, reflective city-view, and future landmark events.
  - Use for `namsan_tower` inferred backgrounds and explicit `namsan` tags.
  - Status: approved for first in-game QA. 1280x800, clear tower landmark, Seoul city lights, overlook path, no readable signs/logos or foreground character.

- `assets/backgrounds/namsan_cable_car_night.png`
  - Person-free enclosed cable-car ascent for Namsan date paragraph 0.
  - Status: approved. 1280x800, coherent cabin/window/cable geometry, Seoul and the Han River below, no people or signage.
- `assets/backgrounds/namsan_tonkatsu_restaurant_night.png`
  - Modest Namsan wang-donkatsu restaurant for date paragraph 1.
  - Status: approved. 1280x800, two oversized pork-cutlet plates, no tabletop grills, no readable menu text, only tiny distant staff backs.

- `assets/backgrounds/namsan_observation_deck_night.png`
  - Person-free summit observation-deck interior for the two Namsan date preludes.
  - Status: approved. 1280x800, floor-to-ceiling glass, Han River and Seoul/Gangnam lights below, no cafe furniture, signage, crowd, or named character.
  - Layout owner: `assets/NAMSAN_VISUAL_BIBLE.md`.

- `assets/backgrounds/amusement_park_parade_day.png`
  - Fictional Korean urban amusement-park promenade during a distant parade; named-character-free, coherent ride/support/circulation geometry.
- `assets/backgrounds/amusement_roller_coaster_day.png`
  - Empty front-row lift-hill viewpoint with plausible rails, chain and park/city depth; no protagonist hands or passengers.
- `assets/backgrounds/amusement_photo_booth_evening.png`
  - Correct two-person four-cut booth: right-wall bench faces left-wall camera/monitor, with a side entrance on the near wall.
  - Status: approved. All three are 1280x800 and owned by `assets/AMUSEMENT_PARK_VISUAL_BIBLE.md`.

- `assets/backgrounds/office_desk.png`
  - Late-night office desk background for overtime, salary, promotion, startup, and burnout events.

- `assets/backgrounds/office_interview_day.png`
  - Daytime small-company interview room background for first interview, interviewer, and job-entry events.
  - Use instead of `office_desk.png` whenever the text is about a formal interview rather than overtime or late-night work.
  - Status: approved for first in-game QA. 1280x800, reusable person-free Korean office interview room, no readable signs/logos.
  - Layout owner: `assets/OFFICE_INTERVIEW_VISUAL_BIBLE.md`.

- `assets/backgrounds/convenience_store_night_v2.png`
  - Midnight Korean convenience store interior with a physically locked Korean retail floor plan.
  - Use for comedy, health, night, convenience, and food events.
  - Status: approved. Entrance and customer lane are on the right, counter/POS beside the entrance, staff storage wall behind the clerk, and refrigerators on the far-left perimeter. See `assets/CONVENIENCE_STORE_VISUAL_BIBLE.md`.
- `assets/backgrounds/convenience_store_exterior_first_snow.png`
  - Person-free exterior of the same neighborhood store during first snow, with blank fascia, right-side entrance/counter relation, and refrigerators deeper at left.
  - December prelude owner: `assets/FIRST_SNOW_VISUAL_BIBLE.md`.
- `assets/backgrounds/convenience_store_night.png`
  - Legacy layout. Do not route new events here.

- `assets/backgrounds/cafe_seoul.png`
  - Small rainy Seoul cafe interior.
  - Use for social, relationship, date, romance, and cafe events.

- `assets/backgrounds/restaurant_korean.png`
  - Modest Korean restaurant interior for family meals, awkward meetings, and relationship conversation scenes.
  - Status: P2 regenerated with distant faceless diner ambience only.

- `assets/backgrounds/company_dinner_restaurant.png`
  - Korean samgyeopsal company-dinner background for hoesik/workplace loyalty-pressure scenes.
  - Use for `company_dinner_restaurant` inferred/explicit backgrounds and `kx_hoesik`.
  - Status: approved for first in-game QA. Distant faceless office-worker silhouettes only, no named-character proxy.

- `assets/backgrounds/family_living_room.png`
  - Canon-safe Minjun-family background, regenerated as his father's modest older Changwon working-class home.
  - Use for father/family/home events. Contains no large framed extended-family portrait, no wealthy Seoul apartment signal, and no happy big-family household implication.

- `assets/backgrounds/hometown_train_station.png`
  - Modest provincial Korean station platform for hometown return/family-pressure scenes.
  - Status: P2 regenerated without a central traveler; should feel working-class and regional, not wealthy Seoul.

- `assets/backgrounds/regional_train_window_summer.png`
  - Person-free interior of a modest Korean intercity train with a two-seat window pair and summer rice paddies outside.
  - Runtime IDs `ktx_window` and `regional_train_window` both resolve here. Use for written in-train window scenes; do not substitute the outdoor `hometown_train_station` platform.
- `assets/backgrounds/daeun_mother_home_dining_summer.png`
  - Daeun mother's modest rural dining room at summer dusk, separate from Minjun's father's Changwon home.
  - Exactly three rice/soup place settings, centered rolled omelet, standing fan, medicine and reading glasses; no large family portrait or male factory jacket.
  - Both are approved 1280x800 backgrounds owned by `assets/HOMETOWN_VISUAL_BIBLE.md`.

- `assets/backgrounds/daeun_newlywed_home_night.png`
  - Daeun's modest small Seoul one-bedroom rental with compact kitchen, center bedroom doorway, right-side entrance, two pairs of shoes, and half-unpacked boxes.
- `assets/backgrounds/jiyeon_newlywed_home_night.png`
  - Jiyeon's spacious high-rise home with charcoal materials, broad Seoul city window, restrained wine service, and sparse moving boxes.
  - Both are person-free 1280x800 first-night backgrounds and must never collapse back to the generic `apartment` key.

- `assets/backgrounds/jiyeon_sedan_first_snow_interior.png`
  - Person-free rear-seat view of Jiyeon's recurring black sedan: left-hand-drive wheel, two front seats, resting wipers, and snow gathering outside.
  - Prelude background only; the paired two-shot is a separate CG.

- `assets/backgrounds/library.png`
  - Quiet public library/study room background for study, exam prep, self-improvement, and solitude scenes.
  - Status: P2 regenerated as reusable study-room background with no recognizable students or protagonist-like figure.

- `assets/backgrounds/investment_phone.png`
  - Late-night smartphone investment anxiety background.
  - Use for investment, finance, stock, crypto, and gambling events.

- `assets/backgrounds/hospital_corridor.png`
  - Quiet Korean hospital corridor at night.
  - Use for health, hospital, crisis, and disaster events.

- `assets/backgrounds/gym_interior.png`
  - Korean neighborhood gym interior for exercise, workout, and health-improvement events.
  - Use for `gym` / `exercise` inferred backgrounds so fitness scenes do not fall back to hospital or generic rooftop imagery.
  - Status: approved for first in-game QA. 1280x800, clear exercise equipment, no medical props, no clear faces.

- `assets/backgrounds/rooftop_daytime.png`
  - Old Seoul villa rooftop in overcast daytime.
  - Use for politics, romance, break, reflection, and rare turning-point events.

- `assets/backgrounds/gangnam_night_street.png`
  - Rainy Gangnam Station night street.
  - Use for late-game reputation, finance, class, and opportunity events.
  - Status: approved for first in-game QA. Regenerated without foreground protagonist-like figure.

- `assets/backgrounds/penthouse_view.png`
  - Gangnam penthouse skyline view at night.
  - Use for Gangnam Dream success and bittersweet wealth endings.
  - Status: approved for first in-game QA. Regenerated as an empty luxury interior with no person or silhouette.

- `assets/backgrounds/burnout_hospital_room.png`
  - Empty hospital patient room for burnout.
  - Use for burnout, mental break, health collapse, and failure endings.

- `assets/backgrounds/racetrack_betting_hall.png`
  - Korean horse-racing betting hall background.
  - Use for RaceTrack betting screen and gambling/tipster events.
  - Status: P2 regenerated with anonymous dark crowd silhouettes as venue texture; no single bettor dominates.

- `assets/backgrounds/racetrack_track_view.png`
  - Horse-racing track grandstand view.
  - Use for RaceTrack race view and racing events.

- `assets/backgrounds/holdem_club_interior.png`
  - Underground Korean holdem club background.
  - Use for HoldemClub minigame and gambling events.
  - Status: P2 regenerated with readable holdem table/cards/chips, distant faceless patrons, and no foreground hands.

- `assets/backgrounds/casino_interior.png`
  - Shared Jeongseon Casino-inspired public casino floor background for the hub, blackjack, and baccarat tables.
  - Use for reusable casino minigame screens that need a general table-game room rather than the holdem club.
  - Status: approved for first in-game QA. 1280x800, bright stained-glass ceiling panels, black columns, red/yellow swirl carpet, slot rows, green table games, faceless distant silhouettes only, no foreground hands, no readable text/logos.

- `assets/backgrounds/jeongseon_casino_exterior.png`
  - Jeongseon Casino-inspired mountain resort exterior background from a protagonist eye-level driveway/drop-off view.
  - Use for Jeongseon Casino arrival/departure, bus, relapse, and addiction-reflection events outside the casino floor.
  - Status: approved for first in-game QA. 1280x800, mountain valley resort complex with teal roofs, hotel towers, entrance canopy, driveway, no aerial/drone view, no readable signage/logos/watermarks.

- `assets/backgrounds/jeongseon_casino_entrance.png`
  - Jeongseon Casino-inspired casino entrance/lobby threshold background.
  - Use for entry, exit, service desk, ID/check-in, and "one more time" relapse-urge events at the casino doorway.
  - Status: approved for first in-game QA. 1280x800, generic readable `CASINO` sign only, lobby gate/service desk, distant anonymous figures, no real logos/brand signage/watermarks.

- `assets/backgrounds/scalping_trading_room.png`
  - Multi-monitor stock scalping setup.
  - Use for ScalpingGame and high-intensity investment events.

- `assets/backgrounds/aruba_delivery_street.png`
  - Night delivery-rider street POV.
  - Use for ArubaGame and delivery/gig-work events.

- `assets/backgrounds/pc_bang_interior.png`
  - Late-night Korean PC bang background for internet cafe, gaming, and escape scenes.
  - Status: P2 regenerated with seated gamer silhouettes mostly hidden by monitors and chairs; no clear face or foreground portrait-like gamer.

- `assets/backgrounds/gangnam_station_exit.png`
  - Gangnam Station daytime street-level background.
  - Use for class-pressure, career, and late-game opportunity events.
  - Status: approved for first in-game QA. Regenerated as a neutral station-exit background with no dominant foreground person.

- `assets/backgrounds/gangnam_day.png`
  - Daytime Gangnam commercial district background.
  - Status: approved for first in-game QA. Regenerated without foreground protagonist-like figure.

- `assets/backgrounds/late_night_room.png`
  - Canonical 4am goshiwon variant generated from `goshiwon_room.png`.
  - Same room structure as the canonical goshiwon; safe for late-night/mental/goshiwon events.

- `assets/backgrounds/hagwon_street.png`
  - Night Korean private-academy street background for Daechi/hagwon pressure events.
  - Use for `hagwon_street` inferred backgrounds and explicit `hagwon` tags.
  - Status: approved for first in-game QA. 1672x941, rainy night academy district, abstract/blurred sign panels only, no readable fake text/logos, distant anonymous pedestrians.

- `assets/backgrounds/suneung_test_hall.png`
  - Korean CSAT/Suneung test hall corridor/classroom background.
  - Use for `suneung_test_hall` inferred backgrounds and explicit `suneung` tags.
  - Status: approved for first in-game QA. 1672x941, tense gray school corridor with classroom visible, no readable notices/logos, no foreground identifiable student.

- `assets/backgrounds/community_center.png`
  - Korean community-center public-service waiting area background.
  - Use for `community_center` inferred backgrounds and explicit `community_center` tags.
  - Status: approved for first in-game QA. 1672x941, number counters, kiosk, waiting chairs, blurred official signage, faceless background staff silhouettes only.

- `assets/backgrounds/jjimjilbang.png`
  - Korean jjimjilbang/sauna rest area background.
  - Use for `jjimjilbang` inferred backgrounds and explicit `jjimjilbang` tags.
  - Status: approved for first in-game QA. 1672x941, modern warm Korean sauna/rest room with lockers, towels, mats, wood pillows, vending machines, no clear faces.

- `assets/backgrounds/cherry_blossom_path.png`
  - Seoul cherry-blossom path background for spring/cherry blossom season events.
  - Use for `cherry_blossom_path` inferred backgrounds and explicit `cherry_blossom` or `spring_cherry` tags.
  - Status: approved for first in-game QA. 1672x941, muted gray-pink riverside path, fallen petals, distant anonymous silhouettes only, no readable signs/logos.

- `assets/backgrounds/saju_cafe.png`
  - Korean saju fortune-reading cafe interior background.
  - Use for `saju_cafe` inferred backgrounds and explicit `saju` tags.
  - Status: approved for first in-game QA. 1672x941, dim cramped consultation room, laptop, abstract blank chart, candle, plain books, no readable/fake text.

- `assets/backgrounds/military_base_gate.png`
  - Korean reserve-force training center entrance background.
  - Use for `military_base_gate` inferred backgrounds and reserve-duty events. Keep broader military memories on `military_training_ground.png`.
  - Status: approved for first in-game QA. 1672x941, cold rainy civilian eye-level gate, guard post, barrier, shuttle bus, no readable signs/insignia/weapons/clear faces.

### Key Art
- `assets/keyart/gangnam_dream_keyart_cast_v1.png`
  - Current textless launch master, 1920x1080.
  - Identity-locked Minjun, Daeun, and Jiyeon share one rain-darkened glass composition. This is the source for title screens, trailers, and store crops.

- `assets/keyart/gangnam_dream_keyart_rooftop.png`
  - Legacy textless concept, 1920x1080. Retained for archive/reference only.
  - Do not use for launch branding: the back-view silhouette does not sell the cast or the game's human conflict.

- `assets/keyart/steam_capsule_main.png`
  - Steam main capsule, 616x353.
  - Derived from the cast master with the deterministic Gangnam wordmark. `steam_capsule_main_v2.png` is the versioned approval copy.

- `assets/keyart/steam_header.png`
  - Steam header, 460x215.
  - Derived from the same cast master. `steam_header_v2.png` is the versioned approval copy.

- `assets/keyart/steam_capsule_small.png`
  - Steam small capsule, 231x87.
  - Compact wordmark plus all three locked character silhouettes. `steam_capsule_small_v2.png` is the versioned approval copy.

- Store derivatives are rendered by `tools/KeyArtExport.tscn`; `tools/generate_assets.py` does not own or regenerate them.

### Story CG
- `assets/cg/start.png`
  - Opening CG for the start of the run.
  - Cramped goshiwon room; no large view window. Gangnam is implied through the phone/goal object, not a skyline outside the room.

- `assets/cg/seollal_sebae_family_v1.png`
  - One-off `kx_seollal_sebae` CG in Minjun's canonical modest Changwon family home.
  - Minjun performs a formal Korean male sebae with both knees grounded, hands overlapped, and forehead lowered toward them; Father and two paternal relatives look at him rather than the lens.
  - Mother is absent because the parents remain separated. Exactly four people, one plain cream money envelope, no hanbok/Chinese red envelope/large intact-family portrait. The lower third is dialogue-safe.

- `assets/cg/ending_father.png`
  - Father ending CG: Kim Minjun gently holding his weakened father's hand in a quiet hospital room.
  - Currently reserved for a future father hospital/last reconciliation ending, not the Gangnam Dream victory ending.

- `assets/cg/ending_gangnam_dream.png`
  - S-rank Gangnam Dream ending CG: late-30s Kim Minjun and his older working-class father quietly facing the Gangnam night skyline together.
  - Use only for `gangnam_dream`; this is a specific success/reconciliation scene, not a generic apartment background.

- `assets/cg/ending_empty_house.png`
  - Empty House ending CG: the same Gangnam success space, but with Minjun alone, a dark table, unused second cup, and cold city light.
  - Use only for `empty_house`; it should read as success without anyone left to show it to.

- `assets/cg/ending_crypto_ghost.png`
  - Crypto Ghost ending CG: cramped late-night trading den, abstract chart light, phone in hand, cluttered desk, and exhausted Minjun.
  - Use only for `crypto_ghost`; charts must stay abstract with no readable exchange text or real crypto logos.

- `assets/cg/ending_full_circle_v1.png`
  - `full_circle` only. Newly occupied Gangnam room; Minjun tells Father by phone that Sangchul's debt is cleared. Father is not physically present.

- `assets/cg/ending_gangnam_dream_white_v1.png`
  - `gangnam_dream_white` only. Clear morning, blank deed folder, and one calm self-reflection; never share the ordinary Gangnam ending CG.

- `assets/cg/ending_with_daeun_v1.png`
  - `with_daeun` only. Two bowls of ramyeon in a modest outer-Seoul home. Rings remain hidden so married and unmarried prose variants stay valid.

- `assets/cg/ending_second_love_v1.png`
  - `second_love` only. Daeun turns from the Gangnam night window while Minjun prepares the second of exactly two mugs.

- `assets/cg/ending_jiyeon_man_v2.png`
  - `jiyeon_man` only. Reflection-only off-axis mirror shot: Minjun appears once at screen-left and Jiyeon once at screen-right, both inside the same mirror. No foreground backs or duplicate reflections are permitted; the frame, reflected room depth, and vanity edge establish the mirror while all hands remain below the crop.

- `assets/cg/ending_guardian_v1.png`
  - `guardian` only. Father walks out of a modest Changwon hospital while Minjun carries one duffel and a folded jacket; no bed or wheelchair.

- `assets/cg/ending_jaehyuk_way_v1.png`
  - `jaehyuk_way` only. Minjun holds a half-drawn curtain in an expensive empty room. Source midtones are lifted so Deep Black damages the print without hiding the action.

- `assets/cg/ending_sangchul_reckoning_v1.png`
  - `sangchul_reckoning` only. Lowered phone, open window, blank papers, and one pen support both police-statement and direct-settlement prose variants.

- `assets/cg/ending_late_call_v1.png`
  - `late_call` only. On the Changwon-bound KTX, late-30s Minjun holds one phone to his right ear and one removed earbud above the ending crop while winter rain moves down the window.
  - Father, Sangchul, Jaehyuk, and romance characters remain outside the frame because the ending variants guarantee only Minjun, the train, the call, and the rain.

- `assets/cg/ending_lonely_rich_v1.png`
  - `lonely_rich` only. Minjun occupies one end of a four-seat Gangnam dining table with one single-person delivery, one face-down phone, and exactly three empty chairs.
  - Do not substitute `ending_empty_house.png`: that ending owns Father's death, the sofa, two unused cups, envelope, keys, and collapsed posture. A divorce below the Gangnam target receives no rich-apartment CG.

- `assets/cg/ending_gambling_recovery_v1.png`
  - `gambling_recovery` only. In the canonical goshiwon, late-30s Minjun completes today's circle on one plain wall calendar while one face-down phone remains on the desk.
  - The 950x430 ending crop must keep his face, pen hand, calendar grid, and current circle. No cards, chips, casino neon, readable dates, helper character, or Gangnam success signal appears.

- `assets/cg/jaehyuk_reveal.png`
  - Jaehyuk route reveal CG: private meeting room, moral line-crossing moment.

- `assets/cg/jiyeon_crash_day_v3.png`
  - Canon Jiyeon first-contact CG: rainy overcast Gangnam afternoon, complete bicycle, unbranded black S-Class-level sedan, and left-hand driver exit.
  - Jiyeon and Minjun look at each other; neither looks at the lens. The lower road remains dialogue-safe.
- `assets/cg/jiyeon_crash.png`
  - Legacy night version. Do not route new events here.

- `assets/cg/romance/sea_daeun_v3.png`
- `assets/cg/romance/sea_jiyeon_v2.png`
- `assets/cg/romance/fireworks_daeun.png`
- `assets/cg/romance/fireworks_jiyeon.png`
- `assets/cg/romance/cherry_daeun.png`
- `assets/cg/romance/cherry_jiyeon.png`
- `assets/cg/romance/first_kiss_daeun.png`
- `assets/cg/romance/first_kiss_jiyeon.png`
  - Approved T0 romance CG set, all 1280x800 and wired to their exact event owners.
  - Uses 2D Korean manhwa/Japanese VN scene grammar with restrained full color at Gray, White clarity, and Black ink loss at runtime.
  - First-kiss images freeze before contact so the player's choice remains valid.
  - Jiyeon's car interior is the left-hand-drive reference for her recurring black executive sedan; see `assets/VEHICLE_VISUAL_BIBLE.md`.

- `assets/cg/romance/narrow_room_jiyeon_v1.png`
  - T1 Jiyeon climax: canonical left-wall bed/right-front desk goshiwon geometry, exactly two cup ramyeon bowls, coat-off oxblood outfit, and mutual Jiyeon/Minjun eye line.
  - Layout owner: `assets/GOSHIWON_VISUAL_BIBLE.md`.

- `assets/cg/romance/namsan_lock_daeun_v1.png`
  - T1 Daeun love-lock beat: same-summit terrace, immediate partial tower structure, moss duffle outfit, and mutual Daeun/Minjun eye line before the choice.
- `assets/cg/romance/namsan_lock_jiyeon_v1.png`
  - T1 Jiyeon love-lock beat: same-summit terrace, sapphire tailored coat, Jiyeon studying an existing lock while Minjun watches her contradiction.
  - Both Namsan CGs are 1280x800 and owned by `assets/NAMSAN_VISUAL_BIBLE.md`.

- `assets/cg/romance/amusement_lost_child_daeun_v1.png`
  - T1 Daeun kindness beat: Daeun and Minjun each hold one hand of the tearful lost child; all three gazes form a coherent triangle.
  - Minjun uses a small reassuring smile rather than inheriting the defeated default-portrait expression.
- `assets/cg/romance/amusement_photo_strip_jiyeon_v1.png`
  - T1 Jiyeon choice-result CG: four fixed-identity booth frames progress from posing to mutual gaze, laughter, and a surprise cheek kiss.
  - Both are 1280x800, mild-weather outfit locked, and owned by `assets/AMUSEMENT_PARK_VISUAL_BIBLE.md`.

- `assets/cg/romance/hometown_night_bus_daeun_v1.png`
  - T1 Daeun return-bus CG: Daeun sleeps against the window in the same summer outfit while Minjun watches her and the rural-to-Seoul reflection with quiet relief.
  - Approved 1280x800. Shared event-result CG for both dinner choices, revealed only at result paragraph 1; owned by `assets/HOMETOWN_VISUAL_BIBLE.md`.

- `assets/cg/romance/proposal_daeun_v1.png`
  - T1 accepted-proposal CG: rainy cafe, one open ring box, Daeun's hand-over-mouth reaction, and mutual off-lens eye line over Minjun's shoulder.
  - Approved 1280x800 choice-result CG, revealed at result paragraph 1 only for the accepted branch.
- `assets/cg/romance/wedding_daeun_small_v1.png`
  - Modest couple-only wide entry: Minjun waits at the altar and Daeun approaches in the simple A-line dress; only the couple is identifiable, with faceless bride-side silhouettes and empty groom-side chairs kept as context.
- `assets/cg/romance/wedding_daeun_full_v1.png`
  - Full-package couple-only wide entry with refined gown/veil, larger bouquet, and upgraded flowers while preserving the same two-person gaze and sparse-seat geometry.
- `assets/cg/romance/wedding_daeun_mother_reaction_v1.png`
  - Bride-side parent reaction: Daeun's mother is grounded in the screen-left front-row aisle seat, wears the fixed dusty-rose/raspberry honju hanbok, and looks toward the closed doors; every guest behind her is a low-contrast faceless silhouette.
- `assets/cg/romance/wedding_daeun_father_reaction_v1.png`
  - Living-Father groom-side reaction: he occupies the screen-right front-row aisle seat in a charcoal honju suit and turns his face and eyes toward the unseen bride rather than the viewer.
- `assets/cg/romance/wedding_daeun_father_reaction_hyunsu_v1.png`
  - `hyunsu_reconnected`: Father keeps the front row and Hyunsu attends alone one full row behind him; no spouse or child is invented.
- `assets/cg/romance/wedding_daeun_father_reaction_passed_v1.png`
  - `father_passed`: the front-row aisle chair remains completely empty, with no portrait, prop, or replacement guest.
- `assets/cg/romance/wedding_daeun_father_reaction_passed_hyunsu_v1.png`
  - `father_passed&hyunsu_reconnected`: Father's empty chair remains unobstructed while Hyunsu sits alone one row behind it.
- `assets/cg/romance/wedding_daeun_small_close_v1.png`
- `assets/cg/romance/wedding_daeun_full_close_v1.png`
  - Couple-only aisle close variants that preserve the small/full wardrobe while making Daeun's canonical face, mutual gaze, bouquet grip, and restrained emotion readable without a parent competing in frame.
- `assets/cg/romance/wedding_gap_jiyeon_v1.png`
  - Pre-decision hotel-ballroom negotiation: Jiyeon's father pressures the couple across unequal blank invitation-card groups; Jiyeon remains in an ivory planning suit, not a bridal gown.
  - All commitment assets are owned by `assets/COMMITMENT_VISUAL_BIBLE.md`; Daeun's nine wedding files separate couple/package state from family-route state, while the Jiyeon image deliberately does not depict either choice outcome.

- `assets/cg/romance/wedding_morning_daeun_v1.png`
  - Daeun's first married morning from Minjun's POV: same mauve indoor outfit, wedding-ring pan hand, spatula hand, and rolled omelet in the canonical small kitchen.
- `assets/cg/romance/wedding_morning_jiyeon_v1.png`
  - Jiyeon's first married morning from Minjun's POV: bare face, same midnight-blue blouse, one visible duvet hand, and cool dawn high-rise continuity.
  - Both are 1280x800 event-result CGs revealed only at result paragraph 1 and owned by `assets/FIRST_MORNING_VISUAL_BIBLE.md`.

- `assets/cg/romance/breakup_daeun_v1.png`
  - T2 betrayal-result CG in the canonical modest Daeun home: Daeun uses her dusty-mauve home outfit and presses one red seal onto one blank separation agreement while Minjun remains withdrawn in the rear foreground.
- `assets/cg/romance/breakup_jiyeon_v1.png`
  - T2 release-result CG in the canonical Jiyeon high-rise: Jiyeon crosses the front-door threshold toward an indoor corridor while Minjun stays seated and does not reach after her.
  - Both are 1280x800 choice-result CGs, never preludes or ending substitutes; exact timing and acting belong to `assets/BREAKUP_VISUAL_BIBLE.md`.

- `assets/cg/romance/first_snow_daeun_v1.png`
  - December two-shot outside the canonical convenience store: mutual gaze and exactly two small plain canned coffees, one offered and one retained.
- `assets/cg/romance/first_snow_jiyeon_v1.png`
  - December back-seat two-shot: Jiyeon at the left driver seat, Minjun at the right passenger seat, both belted, wipers resting, and mutual gaze after her line.
  - Both are 1280x800 paragraph-1 event CGs owned by `assets/FIRST_SNOW_VISUAL_BIBLE.md`.

- `assets/cg/demo/daeun_first_kindness_v2.png`
  - Demo kindness CG: Daeun remains inside the staff pocket, Minjun remains on the customer side near the entrance, and both share an explicit mutual eye line over two triangle rice packages.
- `assets/cg/demo/father_first_call_v1.png`
  - Demo father-call diptych: Minjun in the goshiwon and Father in a factory break room, with inward-facing phone poses and parallel emotional blocking.
- `assets/cg/demo/first_interview_v1.png`
  - Demo opening-interview CG: inexpensive-suit Minjun on the candidate side and a distinct early-40s interviewer on the staff side share a mutual eye line over the resume.
  - Lower 30 percent remains dialogue-safe; layout and acting owner is `assets/OFFICE_INTERVIEW_VISUAL_BIBLE.md`.

### Logo Concept
- `assets/logos/gangnam_dream_logo_concept.png`
  - AI-generated logo direction only.
  - Treat as visual reference, not final production logo.
  - Final logo should be rebuilt with a real Korean font/vector treatment.

## Do Not Use

Avoid earlier generated images that include orbit rings, sci-fi nodes, or Lumen Run-like icon motifs. Gangnam Dream should stay grounded: Korean webtoon, lo-fi realism, social survival, Seoul anxiety.

### UI Assets
- `assets/ui/action_tiles/action_*_atlas.png`
  - Legacy prop-only AP studies retained for source history; no longer referenced by the runtime.
  - Runtime AP cards use the canonical background/CG paths in `MainGame.ACTION_ILLUSTRATION_DATA`, so the action menu previews the same world the player enters.
- `assets/ui/action_tiles/action_*.svg`
  - Functional fallback symbols only. Keep for missing art, compact status, lock, AP cost, and navigation; do not use as the primary recurring AP-card image.

- `assets/ui/card_back.png`
  - Practical 256x358 poker card back design for hidden/deck cards.
  - Updated on 2026-06-15 with an axis-aligned black/white geometric pattern: centered inner panel, centered medallion, and symmetric borders.
  - Used by `HoldemClub.gd`, `BlackjackTable.gd`, and `BaccaratTable.gd` for hidden cards.

- `assets/ui/card_front_base.svg`
  - High-resolution vector playing-card face base: ivory paper, rounded corners, subtle inner guides, no baked rank/suit.
  - Added on 2026-06-19 so rank/suit labels can be drawn consistently on top of a shared physical card texture.
  - Used by `HoldemClub.gd`, `BlackjackTable.gd`, and `BaccaratTable.gd` for visible cards.

- `assets/ui/poker_chip_icon.png`
  - Practical 128x128 transparent poker chip icon for pot/chip UI.
  - Updated on 2026-06-15 with a blank center field, concentric rings, outer white inserts, and small inner dash marks matching real casino chips.
  - Used by `HoldemClub.gd` for the central POT display; animated chip bursts are still drawn procedurally.

- `assets/ui/chips/chip_1k.svg`
- `assets/ui/chips/chip_5k.svg`
- `assets/ui/chips/chip_10k.svg`
- `assets/ui/chips/chip_50k.svg`
- `assets/ui/chips/chip_100k.svg`
- `assets/ui/chips/chip_500k.svg`
- `assets/ui/chips/chip_1m.svg`
  - Denomination chip set for casino stake buttons.
  - Real-chip layout: colored body, white edge inserts, concentric rings, small inner dash marks, centered numeric value only.
  - No center ornament/logo/suit mark; this is intentional to avoid the misaligned motif problem from earlier chip attempts.
  - Wired into Blackjack, Baccarat, Slot, Roulette, and BigWheel stake buttons. Slot uses the lower `chip_1k`/`chip_5k` denominations.

## Style Guardrails

- Use grounded Korean modern-life imagery.
- Prefer real spaces: goshiwon, one-room apartment, rainy Seoul street, rooftop, office, subway, convenience store.
- Avoid sci-fi UI motifs, glowing orbit rings, abstract circular nodes, magical cores, or Lumen Run visual language.
- Keep palette dark and restrained: charcoal, muted navy, warm gold, small cool-blue accents.
