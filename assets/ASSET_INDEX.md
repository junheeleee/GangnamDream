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
Updated on 2026-07-03 for Lee Minseo transparent portrait and post-Claude story background alignment.

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

- `assets/characters/npc_boss.png`
  - Im Sangcheol normal transparent portrait, 52-year-old self-made broker/mentor.

- `assets/characters/npc_sangchul_serious.png`
  - Im Sangcheol serious transparent expression variant for warnings, high-stakes information, and morally tense choices.

- `assets/characters/npc_close_friend.png`
  - Kang Hyunsu transparent portrait, redesigned as a likable 26-27-year-old chubby exam-prep junior.
  - Distinctive lock: round glasses, soft round face, stockier body, olive-gray hoodie, muted burgundy striped shirt, awkward warm half-smile.

- `assets/characters/npc_mentor.png`
  - Han Jiyeon normal transparent portrait.
  - Production status: approved for first in-game QA. 31-year-old wealthy Gangnam heroine, long black hair, cream jacket, black inner top.

- `assets/characters/npc_jiyeon_warm.png`
  - Han Jiyeon warm transparent expression variant for private trust, romance, and emotionally open scenes.
  - Production status: approved for first in-game QA. Same identity/outfit as `npc_mentor.png`.

- `assets/characters/npc_jiyeon_cold.png`
  - Han Jiyeon cold transparent expression variant for negotiation, status pressure, and calculating investor scenes.
  - Production status: approved for first in-game QA. Same identity/outfit as `npc_mentor.png`.

- `assets/characters/npc_minseo.png`
  - Lee Minseo transparent portrait, 38-year-old self-made Gangnam arrival mentor.
  - Runtime use: `minseo` / `minseo_normal` portrait IDs in late-game Minseo arc events.
  - Readability lock: short neat dark hair, charcoal practical blazer, ivory knit/blouse, calm tired eyes; must not resemble Han Jiyeon's long-haired old-money aura or Kim Daeun's soft convenience-store warmth.

- `assets/characters/npc_tip_seller.png`
  - Horse-racing tip seller transparent portrait, 45-50-year-old track information seller with cap, worn windbreaker, and folded racing forms.

- `assets/characters/npc_father.png`
  - Kim Minjun's father normal transparent portrait, 63-year-old Changwon factory-worker dignity and guilt.

- `assets/characters/npc_father_weak.png`
  - Kim Minjun's father weakened transparent illness variant for father-arc crisis scenes.

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

- `assets/backgrounds/heatwave_city.png`
  - Dry Seoul heatwave street background for August heat-alert events.
  - Use for `heatwave_city` inferred/explicit backgrounds and `kx_heatwave`.
  - Status: approved for first in-game QA. Person-free, no readable signs/logos, dry asphalt/heat haze signal.

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

- `assets/backgrounds/hangang_riverside_walk.png`
  - Han River evening promenade background for Seoul rest, walking, running, romance, and reflective callback events.
  - Use for `hangang_riverside` inferred backgrounds and explicit `hangang` tags.
  - Status: approved for first in-game QA. 1280x800, blue-hour river, bridge, skyline, benches, lamps, only distant anonymous silhouettes, no readable signs/logos.

- `assets/backgrounds/namsan_tower_view.png`
  - Namsan Tower night overlook background for aspirational Seoul, reflective city-view, and future landmark events.
  - Use for `namsan_tower` inferred backgrounds and explicit `namsan` tags.
  - Status: approved for first in-game QA. 1280x800, clear tower landmark, Seoul city lights, overlook path, no readable signs/logos or foreground character.

- `assets/backgrounds/office_desk.png`
  - Late-night office desk background for overtime, salary, promotion, startup, and burnout events.

- `assets/backgrounds/office_interview_day.png`
  - Daytime small-company interview room background for first interview, interviewer, and job-entry events.
  - Use instead of `office_desk.png` whenever the text is about a formal interview rather than overtime or late-night work.
  - Status: approved for first in-game QA. 1280x800, reusable person-free Korean office interview room, no readable signs/logos.

- `assets/backgrounds/convenience_store_night.png`
  - Midnight Korean convenience store interior.
  - Use for comedy, health, night, convenience, and food events.
  - Status: approved for first in-game QA. Regenerated as a person-free reusable background with empty checkout counter.

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
- `assets/keyart/gangnam_dream_keyart_rooftop.png`
  - Textless master key art, 1920x1080 anime rooftop view toward Gangnam.
  - No embedded title text; use it as the clean source for title screens, trailers, and store crops.

- `assets/keyart/steam_capsule_main.png`
  - Steam main capsule, 616x353.
  - Derived from the textless rooftop master with deterministic local-font title overlay: `GANGNAM DREAM` + `강남드림`.

- `assets/keyart/steam_header.png`
  - Steam header, 460x215.
  - Derived from the same rooftop master with local-font title overlay.

- `assets/keyart/steam_capsule_small.png`
  - Steam small capsule, 231x87.
  - High-contrast compact `GANGNAM DREAM` title overlay for small-store readability.

### Story CG
- `assets/cg/start.png`
  - Opening CG for the start of the run.
  - Cramped goshiwon room; no large view window. Gangnam is implied through the phone/goal object, not a skyline outside the room.

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

- `assets/cg/jaehyuk_reveal.png`
  - Jaehyuk route reveal CG: private meeting room, moral line-crossing moment.

- `assets/cg/jiyeon_crash.png`
  - Jiyeon first-contact CG: rainy Gangnam bicycle incident.
  - Updated to match Han Jiyeon's transparent portrait identity: long wavy black hair, sharp almond eyes, cream blazer, black blouse, gold jewelry.

- `assets/cg/romance/sea_daeun.png`
- `assets/cg/romance/sea_jiyeon.png`
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

### Logo Concept
- `assets/logos/gangnam_dream_logo_concept.png`
  - AI-generated logo direction only.
  - Treat as visual reference, not final production logo.
  - Final logo should be rebuilt with a real Korean font/vector treatment.

## Do Not Use

Avoid earlier generated images that include orbit rings, sci-fi nodes, or Lumen Run-like icon motifs. Gangnam Dream should stay grounded: Korean webtoon, lo-fi realism, social survival, Seoul anxiety.

### UI Assets
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
