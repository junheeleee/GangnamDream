# Gangnam Dream Audio QA

Updated: 2026-08-11

Production gate: an audio file existing and loading is not the same as launch approval. Every asset must also satisfy `docs/PRODUCTION_ASSET_PIPELINE.md`: commercial provenance, clean head/tail, mix balance, semantic runtime mapping, image-paired listening, and 30-minute fatigue QA.

## Audio Identity

The sound must belong to the same work as the `Gangnam Ink` visual direction.

- **World:** grounded contemporary 2026 Seoul rooms, transport, rain, HVAC, crowds, and close dry foley.
- **UI:** short paper pressure, muted latch, and restrained mechanical contact. No arcade laser, bubbly missile, chiptune, or generic mobile reward language.
- **Gameplay:** confirm the physical result, not every focus movement. A card sound occurs when the card moves; a chip sound occurs when the wager reaches the table.
- **Music:** restrained cinematic score. Important scenes own authored roles (`intimate`, `reckoning`, `grief`, `wonder`, `wedding_processional`) rather than restarting the generic lo-fi loop.
- **Moral sound:** dark routes first remove human presence and air; bright routes restore human detail and acoustic openness. A morality number or obvious good/evil jingle is forbidden.
- **Language:** Korea remains Korea. Diegetic voices and room calls stay Korean under every text locale; meaningful speech receives localized subtitles.
- **Era lock:** the illustration is contemporary, so the default sound language is contemporary. Chiptune, 8-bit oscillators, retro menu bleeps, and arcade reward tones are prohibited unless a visible diegetic machine is producing them.

`assets/game_audio_manifest.json` is the machine-readable identity and stage contract. Every shipping master uses field/object recordings or recorded real-instrument samples. Keep the semantic key and stage contract stable when replacing a take; never preserve an unsuitable sound merely because it already loads.

## Current Inventory

| Class | Count | Runtime owner |
|---|---:|---|
| BGM | 20 | `autoloads/BGMPlayer.gd` |
| Ambience | 49 | `autoloads/BGMPlayer.gd` (39 inert/place + 10 human-presence layers) |
| SFX | 70 | `autoloads/AudioManager.gd` |
| **Total** | **139** | one provenance-tracked recording/sample master each |

All 139 current assets are recording/sample-backed: 20 real-piano scores, 49 field-recorded ambience beds, and 70 recorded physical/UI/gameplay effects. `assets/audio/AUDIO_SOURCE_MANIFEST.json` records the exact source and transform for every file, and `tools/audio_source_audit.py` rejects synthesized provenance, code, and known source-to-scene substitutions.

## Public Office Queue Cue

- `story_last_payment_wait` keeps `public_office` room ambience. A queue call is a result-owned physical cue, not a substitute ambience.
- `queue_chime` uses LG's CC0 field recording `20231229 - Duisburg station announcement ding dong` from Freesound recording 718032. The source and output SHA-256 values, trim, gain, and license are fixed in `assets/audio/AUDIO_SOURCE_MANIFEST.json`.
- The cue belongs only to choice `0`, result paragraph `0`, with a 0.22-second delay. It does not play in the waiting description, on locale changes, or when the same result paragraph is rendered again.
- `scene_audio_contract_check.py` rejects a missing stream, wrong result paragraph, missing `public_office`, or a return to a medical/device substitute. `BGMContinuityCheck.tscn` executes the one-shot and locale-switch contract.

## 24-Week First Bill Chain

- `v2_demo_first_bill_opening`, `v2_demo_first_bill`, and
  `v2_demo_first_bill_ledger` share the live housing room tone and one
  `reckoning` playback. The opening admits the score at paragraph 1; both later
  links request the same key at paragraph 0, so `_play_or_keep` preserves the
  existing playback position instead of restarting it.
- `paper_handle` occurs exactly once at opening description paragraph 0, when
  Minjun opens the banking app and notebook. `pen_write` occurs exactly once at
  ledger choice 0, result paragraph 0, when he writes the next Monday date.
  The notebook close receives no reward sound or emotional sting.
- Both masters are existing provenance-locked recordings. `paper_handle` is the
  Sonniss GDC 2026 paper-foley take fixed in the source manifest; `pen_write` is
  Owlish Media's CC0 pencil-scratch recording. ORDER-75 adds no synthesized or
  untracked audio file; it adds `pen_write` to the semantic physical-SFX ledger.
- `scene_audio_contract_check.py` rejects a changed ambience, score key,
  paragraph entrance, duplicated cue, cue migration into prose that does not
  perform the action, or an extra first-bill cue on any of the three links.
- Dedicated Core Loop V2 ScreenshotQA rendered opening, all three decision
  contexts, all three ledger states, and the convenience/warehouse result
  moves at KO 960×600 and EN 1280×800. This proves the authored First Bill
  surfaces are reachable in the V2 harness. The separate V2
  `demo-experience` route now completes the Korean and English 24-week paths
  and reports `DEMO_EXPERIENCE_AUDIT_OK`; neither automated result is a
  continuous human listening approval. Legacy six-month profile counts below
  must not be cited as V2 completion evidence.

## Launch Identity

- `publisher_sting` is a project-owned 1.55-second stereo 44.1 kHz cue rendered from recorded Yamaha C5 samples.
- It plays exactly once with the transparent JUNPAC mark, at a restrained -4 dB mix trim. It is neither menu music nor a reusable reward sound.
- Skipping the publisher pre-roll cannot stack or replay the sting. The title and new-story opening then use their existing music/ambience owners without carrying the sting forward.
- `First30SecondsCheck.tscn` locks one sting, one mandatory title input gate, and a maximum three-beat opening. `generate_launch_audio.py --check` is now a read-only provenance/format gate and cannot generate audio.

## Scene Music

`menu`, `early`, `hustle`, and `late_tense` are lobby-only masters. StoryMode, the weekly hub, month transitions, ordinary events, and unscored arcs may not infer them from age, rarity, category, or an `arc_` prefix. Those surfaces retain only authored place, season, and human ambience. Cinematic story music enters solely through an explicit `scene_audio_manifest` paragraph contract or a menu/ending owner; continuous activity music requires its own `game_audio_manifest` contract.

The seven base tracks cover title, routine, crisis, and endings. Five authored peak tracks and six demo character/theme motifs cover explicit story roles:

| Key | Role | Loop rule |
|---|---|---|
| `wedding_processional` | Daeun entrance, aisle approach, vows | starts with the couple-wide entrance and continues into the close without restart |
| `intimate` | vulnerable romance and family closeness | paragraph-triggered |
| `reckoning` | confrontation and irreversible truth | silence before entry |
| `grief` | death, separation, aftermath | paragraph-triggered |
| `wonder` | awe, release, landmark-scale emotional lift | paragraph-triggered |
| `family` | Father's debt, home, and inherited duty | continuous through the three-scene Knee memory |
| `survival` | applications, shifts, and first earned stability | paragraph-triggered; never a victory cue |
| `hyunsu` | cramped-room solidarity and deferred hope | continuous inside authored Hyunsu chains |
| `ambition` | comparison, Gangnam, and upward appetite | paragraph-triggered |
| `daeun` | ordinary warmth and mutual attention | paragraph-triggered |
| `jiyeon` | danger, speed, and magnetic distance | paragraph-triggered |

### Six-Month Demo Mix

- All 45 contracted demo events have explicit audio intent; 42 use paragraph-owned physical foley and 41 use authored music. The remaining silence is deliberate, not a missing fallback.
- The Knee memory uses a dedicated `family_home` bed: restrained apartment room tone, modest refrigerator motor, and wall clock. It has no invented television and must never sound like Minjun's goshiwon.
- `story_knee_door`, `story_knee_witness`, and `story_knee_choice` share one uninterrupted `family` playback position. Door latch and paper movement land on physical prose beats; there is no melodramatic sting.
- Minjun's room uses refrigerator/clock machinery plus a separate sparse thin-wall layer made from distant cloth, cough, tap water, and corridor footfall recordings. Metro halls, food courts, streets, and continuous crowd walla are forbidden in both `goshiwon_room` and `goshiwon_hallway`.
- The convenience-store shift uses its refrigerator floor plus a real convenience-store human layer. Interviews and offices use office room tone; hospital and gym scenes use their own recorded rooms. A generic `night` tag no longer invents rain.
- Entrance or prop sounds land when prose names the physical action: the first meal scans at the checkout paragraph, the interview handles paper when the resume moves, Father's call vibrates only when the phone actually rings, and the prologue notebook turns a page before the pen writes.
- Demo room/season trims place the source beds in an audible default window. Human presence is clear at Gray, attenuated at Light Black, and nearly absent at Deep Black while machinery and weather remain.
- Korean PlayStation and English Xbox 24-week profiles expose the same 46 events, ten music keys, 41 authored-music events, and a maximum unscored root run of one.
- 이 데모 통과는 본편의 사람 청취 통과가 아니다. 전 사건 의도와 대표 경로
  연속성은 아래 자동 게이트로 확장됐지만, 활동 피로도와 장별 사람 청취는
  [`ORDER-43`](queue_archive/ORDER-43.md)의 열린 후속 게이트가 소유한다.

### Full-Run Audio Coverage

- `assets/scene_audio_manifest.json` version 19 locks all 1,603 Korean/English
  events into exactly one intent: 293 event contracts, six inherited CG
  contracts, 1,304 reviewed rendered-background profiles, or intentional
  silence. The current catalog has zero unclassified or stale IDs.
- All 94 registered backgrounds own an explicit ambience profile. Runtime
  location selection no longer searches localized prose, category names, or
  tags and no longer falls back to the goshiwon room. A newly registered
  background remains silent with a warning until its profile is reviewed, and
  `scene_audio_catalog.py` blocks the audit until the manifest is updated.
- `current_housing` follows the live home. `current_workplace` follows the live
  job instead of pretending every worker is in an office. Four late-route
  scenes that still forced the original goshiwon room now follow the live
  housing state.
- `full_run_audio_audit.py` traces two deterministic 240-week representative
  routes in Korean and English. The 960 traced weeks cover all five chapters,
  authored peaks, profiled connective weeks, explicit score entrances, seven
  activity owners, and two ending families with exact locale parity.
- This trace proves catalog ownership, route coverage, and deterministic
  continuity contracts. It is not a human full playthrough and cannot approve
  loudness, fatigue, dramatic taste, or living-room intelligibility.

`assets/scene_audio_manifest.json` maps all 74 active CGs to ambience and all 116 events on the 32 Tier-1 peak paths to explicit scene audio. The mother and groom-side reaction shots keep one wedding-hall room tone; the processional begins on the couple-wide entrance and continues into the close without restarting. Wedding applause and cheer are tied to the authored entrance paragraph, not to a timer from scene load. Mother's Table keeps rural room tone through the first three paragraphs before `intimate` enters on the inherited-care reveal. The Narrow Room likewise holds only the cramped-room bed through the opening truth, then admits the same cue without restarting across either buildup route or the final decision. Jiyeon's verdict and Daeun's final test keep only their apartment/oneroom life through both buildup paths; `reckoning` enters once at the irreversible decision instead of using a breakup cue that would spoil the choice. The guarantee bill holds street/pojangmacha ambience without score before Hyunsu's intimate meal, while the last signature keeps the city bed until `reckoning` enters at the authored paragraph. Father's 48-week legacy uses the live housing ambience before `grief`. Both sea dates remain on train ambience with no score through their two buildup paths, then move explicitly to seaside ambience and `wonder` only after the beach arrival. Both fireworks dates retain the Hangang crowd bed with no fireworks cue during buildup; the final decision alone admits `wonder` and the paragraph-2 distant explosion, so the soundtrack cannot announce the first shell before the prose and image do. Daeun's first-night chain keeps the actual housing image while the explicit `rain_room` bed carries rain on glass and a restrained indoor appliance/HVAC floor; it contains no outdoor voices, never enables indoor rain particles, and does not restart across the four linked events. Sangchul's first meeting keeps only the same real-estate-office room tone through all four linked events: the generic public-interior human layer is suppressed because the prose and image contain only Sangchul and Minjun, so its periodic cough cannot invent a third person. No `reckoning` or reveal cue may label him a villain before Minjun knows why he paused at the word Changwon. His deduction then resolves `current_housing` into the live goshiwon, one-room, villa, or apartment room tone; both evidence routes stay unscored, and `reckoning` starts only when the records converge at the final choice. `orthodox_pinnacle` keeps the ordinary restaurant bed under the team-dinner pause instead of borrowing a victory cue. `burnout` keeps only the existing hospital room tone under the first-person observation-bed image; no score, alarm, heartbeat, or melodramatic monitor announces how the player should read the silence.

Chapter 1's Hyunsu failure line is intentionally ambience-only. The exam and formal result use the goshiwon hallway with Minjun alone; later messages and the new-path call resolve the player's live housing and mark Hyunsu as remote. The goshiwon farewell keeps the hallway bed and the immediate first night changes to the new home's room tone. None of these eight connective scenes may restart or borrow the generic lo-fi score.

## Jeongseon Casino Music

Jeongseon is the only current activity that owns continuous music. `casino_floor` and `casino_table` are two arrangements of one 92 BPM, 16-bar, 41.74-second motif. They share harmony, melody, loop metadata, and playback phase:

- The floor arrangement leaves space for room tone and restrained human presence.
- The table arrangement adds a low pulse and muted offbeats without replacing chip, card, dice, wheel, or reel transients. Its integrated level is 2.0 LU above the floor arrangement, enough to increase pressure without becoming a separate song.
- Entering any of the six tables inherits the floor playback position. Returning to the hub inherits it back. Re-entering the same layer never rewinds.
- Leaving Jeongseon fades the score out once, then restores housing and seasonal ambience. The AP hub cannot remain audible under the casino.

The two recorded-piano-sample masters establish timing and identity, not final human approval. They still require headphones, laptop speakers, and living-room TV listening beside ten consecutive rounds of each game.

## Physical Gameplay SFX

The old `casino_card/casino_coin/casino_spin/casino_reel` set remains only as compatibility/result material. Physical stages use dedicated keys:

| System | Physical sequence |
|---|---|
| Blackjack | `card_shuffle` → `chip_place` → repeated `card_deal` → `card_flip` |
| Baccarat | `chip_place` → repeated `card_deal` → `chip_collect` on return |
| Hold'em | `chip_place` + `card_deal` → board `card_flip` → `chip_collect` |
| Roulette | `roulette_wheel` + varied `roulette_ball` → `roulette_land` |
| Dai Sai | `chip_place` → `dice_cup_shake` → varied `dice_roll` |
| Slot | `slot_start` → three pitch-separated `slot_reel_stop` impacts |
| Big Wheel | wheel bed + speed-varying `big_wheel_tick` pointer impacts |
| Racetrack | `chip_place` → `race_gate` → varied `horse_gallop` → `race_crowd_rise` → `race_finish` |

Repeated deal, tick, dice, and hoof sounds use bounded pitch variation and per-key cooldowns. They must read as natural variation, never as musical randomization.

## Ambience Ownership

- Jeongseon hub and standalone Hold'em own `casino` ambience while open.
- Racetrack owns `racetrack` ambience.
- Trading, scalping, and job hunt own `office` ambience.
- Part-time work selects `convenience`, `street`, or `office` from its actual mode.
- Closing an activity restores housing and season ambience. A stale child overlay cannot clear the current owner.
- Opening settings changes gain only; it does not restart BGM or ambience.
- A choice-owned `result_background` may declare KO-only `result_ambience`. The ambience changes in the same frame as the revealed result location without restarting punctuation music; `current_housing` resolves to the live room/one-room/apartment bed.
- Chapter 2 locks four result moves: Jiyeon refusal=`street`, coffee acceptance=`cafe`, hiding the room from the parents=`hoesik`, and showing the room=`current_housing`. `--qa=chapter2-peaks --lang=ko/en` asserts both the rendered location and active ambience key.
- Chapter 3 keeps Jiyeon and Hyunsu messages plus Father's call inside the live housing bed, marks their presence as remote instead of placing them in Minjun's room, and permits score only on authored paragraphs where a revelation actually lands. The midpoint, habit, reflex, and article beats remain ambience-only so the score cannot manufacture importance. `--qa=chapter3-spine --lang=ko/en` asserts all 22 surfaces per language.
- Chapters 2, 4, and 5 keep seventeen private milestones on `current_housing` instead of returning to a static goshiwon or invented late-night room. The body warning owns `subway`, the Hangang threshold owns `hangang`, the year-four close owns `winter`, and Father's real call alone uses the remote-call presentation. `--qa=late-chapter-spines --lang=ko/en` asserts 28 surfaces per language, including authored silence, ambience continuity, and the 2-billion-before-2.5-billion order.

## Moral Ambience

The world is split by meaning rather than by a global dark filter:

- `Master` place layers keep traffic, HVAC, appliances, weather, wheels, and room resonance present so the location never disappears.
- `GangnamDreamHumanAmbience` carries only indistinct population and thin-wall life. It has its own low-pass filter and gain envelope.
- At Gray, human presence is restrained but clear. Light Black moves it 14 dB farther away and low-passes it to 2.6 kHz. Deep Black places it 46 dB below Gray and low-passes it to 780 Hz.
- White restores human detail and air. No morality UI, threshold sting, or good/evil jingle announces the transition.
- The transition lasts 3.8 seconds and does not restart the room loop. The intended realization is delayed recognition: the player notices that Seoul has become populated by machines before being told anything.

These field-recording layers are filtered to keep speech indistinct and contain no designed musical pattern. Launch approval still requires image-paired listening to ensure that foreign-language walla is not intelligible and that each room reads as contemporary Korea.

## Controller Rule

Focus traversal is a last resort. Gameplay scenes use direct state machines and contextual actions; focus is allowed only for settings and short conventional linear menus. The scene settings hub opens on the active text-size segment and uses explicit two-dimensional neighbors through language, audio, motion, and Close. Casino rounds, racing, and card play never require walking a flat button graph.

### Haptic ownership

- `AudioManager` owns named vibration profiles. Scenes may request a semantic
  profile but may not pass raw motor strengths or durations.
- UI focus, hover, click, open/close, tab/page navigation, prose advance, and
  reversible stake/value preview are silent. Failed or disabled actions are silent.
- Successful choice/action/wager commits, real danger, major results, and named
  physical beats may emit exactly one matching profile after success.
- Vibration never carries information alone. The same result, warning, and timing
  remain visible and audible with vibration disabled.
- `Vibration = Off` and `Strength = 0%` immediately stop active output and prevent
  every subsequent profile. The setting persists across save-independent settings
  reloads and is reachable from title, MainGame, and Story scene settings.
- A 30-minute physical-pad pass judges fatigue and whether profiles are actually
  distinguishable. Automated strength and call-site checks are not a feel verdict.

## Player-Facing Controls

- Event scenes expose a compact top-right Settings button for mouse users.
- `gd_menu` opens text size, language, Music/Ambience, SFX, Reduce Motion,
  Vibration, and Vibration Strength from inside a story event without scrolling.
- Xbox/Steam Deck Menu, DualSense Options, and Switch `+` resolve through the same action.
- The modal pauses typing, AUTO, direction holds/beats, and timed choices. Menu or Cancel closes it, restores the focused choice and remaining countdown, and does not restart scene audio.
- Language changes rebind the current paragraph, choices, and result in place. They never replay a choice effect, follow-up, paragraph cue, BGM, or ambience.

## Automated Gates

```bash
python3 tools/audio_source_audit.py
python3 tools/build_sample_audio_assets.py --validate-only
python3 tools/scene_audio_contract_check.py
python3 tools/game_audio_contract_check.py
python3 tools/generate_launch_audio.py --check
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/AudioAssetCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/BGMContinuityCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/GameAudioContractCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/MoralAmbienceCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/StoryAudioSettingsCheck.tscn
```

Latest targeted result:

```text
AUDIO_SOURCE_AUDIT_OK assets=139 bgm=20 ambience=49 sfx=70 source_libraries=21 recordings_or_samples=139 procedural=0
SCENE_AUDIO_CONTRACT_OK cg=74 peak_events=116 ambience_keys=39 music_keys=20 demo_contracts=45 demo_foley_events=42
GAME_AUDIO_CONTRACT_OK physical=32 stages=19 activities=7 activity_music=1 human_layers=10 direct_pad=9
AUDIO_ASSET_CHECK_OK bgm=20 ambience=49 sfx=70
LAUNCH_AUDIO_OK stereo=2 rate=44100 duration=1.55
BGM_CONTINUITY_OK mode=menu key=menu ambience=
GAME_AUDIO_RUNTIME_OK physical=32 ambience_roundtrip=3 varied_playback=1 casino_music=1 haptics=12 unused_profiles=0 direct_scene_raw=0 vibration_roundtrip=1 boundary_clamp=8 same_stack=3
MORAL_AMBIENCE_CHECK_OK profiles=10 neutral=-8.04 dark=-22.04 deep=-54.04
STORY_AUDIO_SETTINGS_CHECK_OK text=3 locale=ko/en timer_pause=11996 result_replay=0
DEMO_EXPERIENCE_AUDIT_OK reports=2 parity=ko/en music=10 authored_music=41
```

Sangchul's casino invitation remains on the live housing room tone through the message, both thought routes, and the final reply without restarting or introducing villain music. Only an accepted reply, ticket confirmation, and explicit bus arrival may switch the camera to `jeongseon_casino_exterior` and the street bed.

Hyunsu's reunion remains scoreless on the live housing room tone through the employment message and both memory routes. Only the explicit Saturday arrival at the old-neighborhood restaurant starts the `cafe` bed and `intimate` score; moving between message links cannot restart either layer.

## Human Listening Gate

This section preserves the legacy/internal W1–W24 listening gate. Its exact
candidate is owned only by `docs/human_gates.json` at
`release_candidates.demo_rc`; do not copy its commit, tree, or manifest hash
into this durable contract. That candidate's three-platform artifacts,
24-week parity, export, and package boot are historical regression evidence,
not the current public `story_demo_rc` identity or a listening approval.

Before closing that legacy/internal listening gate, listen at the real
1280x800/Steam Deck presentation and on headphones, laptop speakers, and a
living-room TV:

1. Play the complete Knee memory without skipping. The player must hear a modest family home before seeing the room, recognize one unbroken family motif, and feel the door/paper beats without hearing a tragedy jingle.
2. Play the goshiwon arrival, Father's call, Hyunsu corridor scenes, and one quiet weekly return in sequence. The room may contain refrigerator, clock, cloth, plumbing, a distant cough, or corridor footfall; it must never resemble a station, food court, street, or outdoor crowd.
3. Play the first convenience-store meal, interview, first shift, gym, and hospital scenes. Each place must be identifiable with the image hidden; scanner, paper, phone, and room cues must occur only when the prose reaches the action.
4. Play ten consecutive rounds of each casino game. Repeated ticks must not become a metronome.
5. Compare each physical sound with the visible material. Paper, felt, ceramic, metal, glass, and asphalt must not share one transient.
6. Enter and leave every activity. In Jeongseon, move floor→table→floor repeatedly; the motif must intensify and relax without restarting, while room tone and physical sounds remain legible. No abrupt cut or AP-hub bleed is allowed.
7. Play the wedding chain without skipping. Processional continuity, paragraph applause, voice-free room tone, and decision silence must feel like one scene.
8. A/B alternate recorded takes for any weak physical cue. Promote only the take that sounds native to the modern illustration while preserving source hashes and license evidence.
9. Compare the same cafe, street, casino, and wedding screen at Gray, Light Black, Deep Black, and White. Only human presence should radically recede; the place and interaction timing must remain believable.
10. Cold-boot three times on all three output classes. The publisher sting must read as one restrained brand gesture, never as a mobile reward chirp, and must not replay at the title or New Story transition.
