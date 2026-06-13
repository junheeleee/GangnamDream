# Gangnam Dream Canon Map

Updated: 2026-06-12

This is the operational canon map for story, characters, and expansion work. If this file conflicts with older planning documents, use this order of truth:

1. `CLAUDE.md` current-state block and hard project rules
2. Runtime code and shipped content JSON
3. `docs/CANON_MAP.md`
4. `docs/STORY_BIBLE.md`
5. Asset-specific canon files such as `assets/CHARACTER_VISUAL_BIBLE.md`
6. Historical logs and old briefs

`docs/GAME_DESIGN.md` is archival. It describes an older roguelike version and is not current canon.

## Hard Canon

- Setting: Seoul, 2026.
- Protagonist: Kim Minjun, 33, unemployed, male.
- Default start: reality mode, 500,000 KRW cash, goshiwon in Sinchon, no job.
- Difficulty variants:
  - Drama mode: 2,000,000 KRW start, lower pressure.
  - Reality mode: 500,000 KRW start, intended balance.
  - Jiokgo mode: 300,000 KRW start, higher pressure.
- Core deadline: 5 years, 60 turns, age 33 to 38.
- Victory target: total assets 3,000,000,000 KRW.
- Default goshiwon monthly fixed expense: 650,000 KRW.
- Genre: interactive drama / visual novel life sim, not a pure economy simulator.
- Core question: can Minjun reach Gangnam without losing the reason he wanted it?

## Main Cast

### Kim Minjun

The player character. He spent age 27 to 32 paying off debt caused by his father's failed guarantee. At 33, the debt is gone but so is his life momentum. He is quiet, proud, emotionally restrained, and stubborn once he commits.

Story function: the vessel for the player's social mobility choices. His visual design must stay 33 to 38 during the core loop. Older portraits are epilogue or legacy only.

### Han Jiyeon

31, wealthy Gangnam heiress and dangerous romance heroine. She is not a middle-aged mentor. She represents the fast door into Gangnam: seductive opportunity, status pressure, real affection, and hidden calculation.

Canon first meeting: rainy Sinchon backstreet bicycle accident with her black Mercedes-Benz S-Class-level sedan. Current canonical first-meet event is `arc_jiyeon_01_crash`.

Story function: "Is entering her world the same as achieving my dream?"

### Kim Daeun

33, ordinary woman from the outskirts. She meets Minjun at the convenience store and shares the same Seoul survival fatigue. She is not glamorous; her strength is recognition, warmth, and realistic companionship.

Story function: "Can a life outside Gangnam still be enough if it is honest and shared?"

### Im Sangchul

52, self-made real estate broker and mentor. He came to Seoul without connections and built himself through labor, brokerage, compromise, and networks. He gives perspective, not answers.

Story function: teaches that Gangnam is not only money or buildings; it is a human network. Also exposes the risk behind Jiyeon's construction-world opportunity.

### Choi Jaehyuk

34, Minjun's old army friend. Charming, successful-looking, and morally dangerous. He is involved in a fraud-like investment scheme, partly victim and partly perpetrator.

Story function: tests greed, loyalty, suspicion, and whether Minjun will copy the same corruption that ruined his family.

### Father

63, factory worker from Changwon. His failed guarantee created Minjun's lost six years, but he carries deep guilt and shame. His health decline is the emotional clock behind the money clock.

Story function: keeps the Gangnam dream personal. The dream began as a family wound, not a luxury fantasy.

### Kang Hyunsu

26-27, goshiwon neighbor and fourth-year civil-service-exam student. He is a grounded younger peer mirror, not a power fantasy. He later connects to warnings around Jaehyuk.

Story function: shows another life stalled at the same starting line.

### Mother

61, separated from Father after the fraud. She is currently a secondary family axis with room for future expansion.

Story function: exposes what the father's failure did to the whole family, not only to Minjun.

## Main Story Arcs

### 1. Survival Opening

Events: `story_arrival`, `story_prologue_dad`, `story_prologue_goal`, `story_prologue_meal`, early intro arc events.

Purpose: establish 50만원, 65만원 goshiwon pressure, father's guilt, and the impossible 30억 goal.

### 2. Route Identity

Events: specialization and tendency arcs.

Purpose: the player leans into career, investment, or founding. This should emerge through repeated actions, not only a label.

### 3. Han Jiyeon Arc

Events: `arc_jiyeon_01_crash`, `arc_jiyeon_02_store`, `arc_jiyeon_03_offer`, `arc_jiyeon_03b_lunch`, `arc_opp_jiyeon_bunyang`, `arc_jiyeon_truth_moment` or `arc_jiyeon_truth_warned`, `arc_jiyeon_05_epilogue`.

Purpose: connect romance, class gap, and a high-upside/high-obligation investment door.

### 4. Kim Daeun Arc

Events: `arc_daeun_01_meet`, `arc_daeun_02_regular`, `arc_daeun_03_fork`, `arc_daeun_03b_date`, `arc_daeun_04_morning`, `arc_daeun_04b_future`, plus later echo/regret events.

Purpose: offer recognition and grounded intimacy. Daeun is not the "poor alternative"; she is the route where the player asks what success is for.

### 5. Im Sangchul Arc

Events: `arc_sangchul_01_meet`, `arc_sangchul_02_coffee`, `arc_sangchul_03_network`, `arc_sangchul_jiyeon_reveal`, `arc_opp_sangchul_realty`.

Purpose: show the machinery of Gangnam and create the moral warning system around Jiyeon and real estate networks.

### 6. Choi Jaehyuk Arc

Events: `arc_jaehyuk_01_reunion`, `arc_jaehyuk_01b_real_face`, `arc_jaehyuk_02_bond`, `arc_jaehyuk_02b_favor`, `arc_jaehyuk_03_pitch`, `arc_jaehyuk_hyunsu_warning`, `arc_jaehyuk_04a_ghost`, `arc_jaehyuk_04b_counter`, `arc_jaehyuk_04c_stand_up`, `arc_jaehyuk_aftermath`.

Purpose: turn Minjun's old debt wound into an active temptation. This is the core fraud/moral-collapse branch.

### 7. Father Arc

Events: `arc_father_01_call`, `arc_father_02_signal`, `arc_father_03_hospital`, `arc_father_04_visit`, `arc_father_05_after_visit`.

Purpose: keep the emotional stake alive. Money pressure should never fully replace family pressure.

### 8. Gangnam Cafe / Opportunity Scenarios

Events: `scenario_cafe`, `scenario_cafe_callback`, selected investment and drama events.

Purpose: create one-off social mobility collisions. These are scenario modules, not replacement main arcs.

## Deprecated Or Legacy

- 20세 시작, 55/65세 은퇴, long-life roguelike design.
- Start-profile selection as a core identity system. Current drama mode uses fixed unemployed Kim Minjun.
- Romance Sumin and old random relationship chains.
- Park Jiyeon / 40s mentor version of Han Jiyeon. Deprecated only; do not use for new events, portraits, or UI labels.
- `relationship_events.json` legacy `jiyeon_meet` to `jiyeon_confession` random chain as a canonical first-meet route. It is disabled; the active route is `arc_jiyeon_01_crash` and later `arc_jiyeon_*` events.
- Photorealistic or background-baked recurring character portraits.
- Multi-monitor trading rooms for early/default investing.
- 3,000,000 KRW default start. The current default/reality start is 500,000 KRW.
- The pre-2026-06-12 `family_living_room.png` version with a large unrelated extended-family portrait.

## Asset Continuity

Images are story facts. A background photo, car model, window size, monitor count, framed family photo, or visible hand position can contradict canon as strongly as wrong dialogue. All new visual assets must pass `docs/ASSET_CONTINUITY_CHECKLIST.md` before being wired into runtime mappings.

## Location Canon

### Minjun's Goshiwon

Tiny 1.5-pyeong survival room in Sinchon. Small high frosted ventilation window, narrow bed, low desk at the bed foot / screen-bottom foreground. No scenic skyline, no large apartment-style window, no luxury furniture.

### Minjun's Family Home

Modest older working-class Changwon home, not a wealthy Seoul apartment and not a warm intact large-family house. Father and mother are separated after the fraud; Minjun lives alone in Seoul. Wall decor may show one old faded photo of young father/mother/Minjun or father alone, but not a large happy extended-family portrait.

### Big Family / Holiday Gathering

If an event is explicitly at "큰집" or a relative's holiday table, a broader family setting is allowed, but it must still show Korean middle-class pressure rather than idealized warmth. The image should not imply Minjun grew up in a stable large household unless the event says it is a relative's house.

### Family Event Background

Use `family_living_room.png` for father/family home events after the 2026-06-12 regeneration. Use `restaurant_korean.png` for family meals, awkward restaurant meetings, and neutral off-home family conversations.

## Expansion Gate

Before adding DLC, seasonal content, new major characters, or new visual packs:

1. Write the canon delta first.
   - Who is added?
   - Which existing arc do they touch?
   - What exact problem do they create for Minjun?
   - What must not change?
2. Assign the content type.
   - Main arc: can affect ending/relationship state.
   - Scenario module: self-contained but can set memory flags.
   - Ambient event: mood/world texture only.
   - Asset pack: no story changes.
3. Reserve IDs and state.
   - Event IDs use `snake_case`.
   - New cast stages go into `content/meta/cast_stages.json` before use.
   - New flags must be read and set intentionally.
4. Lock visuals before generation.
   - Recurring characters: transparent portraits only.
   - Backgrounds: person-free places.
   - CGs: one specific scene, allowed to combine people and place.
5. Check continuity.
   - Age, hair, class signal, vehicle, room layout, season, time of day, economic level.
   - A generated image that contradicts canon is discarded even if it looks good.
6. Run verification.
   - JSON parse for edited files.
   - `./tools/audit.sh`.
   - In-game crop/placement QA for new visuals.

## Update Rule

No future update should add "just one cool image" or "just one cool event" directly to production. Every addition must attach to a canon owner: character, place, arc, route, or scenario module.
