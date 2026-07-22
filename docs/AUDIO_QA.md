# Gangnam Dream Audio QA

Updated: 2026-07-23

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
| Ambience | 47 | `autoloads/BGMPlayer.gd` (38 inert/place + 9 human-presence layers) |
| SFX | 67 | `autoloads/AudioManager.gd` |
| **Total** | **134** | one provenance-tracked recording/sample master each |

All 134 current assets are recording/sample-backed: 20 real-piano scores, 47 field-recorded ambience beds, and 67 recorded physical/UI/gameplay effects. `assets/audio/AUDIO_SOURCE_MANIFEST.json` records the exact source and transform for every file, and `tools/audio_source_audit.py` rejects synthesized provenance or code.

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

- All 45 contracted demo events have explicit audio intent; 43 use paragraph-owned physical foley and 41 use authored music. The remaining silence is deliberate, not a missing fallback.
- The Knee memory uses a dedicated `family_home` bed: modest refrigerator motor, wall clock, and distant unintelligible television texture. It must never sound like Minjun's goshiwon.
- `story_knee_door`, `story_knee_witness`, and `story_knee_choice` share one uninterrupted `family` playback position. Door latch and paper movement land on physical prose beats; there is no melodramatic sting.
- Demo room/season trims place the source beds in an audible default window. Human presence is clear at Gray, attenuated at Light Black, and nearly absent at Deep Black while machinery and weather remain.
- Korean PlayStation and English Xbox 24-week profiles expose the same 46 events, ten music keys, 41 authored-music events, and a maximum unscored root run of one.

`assets/scene_audio_manifest.json` maps all 59 active CGs to ambience and all 116 events on the 30 Tier-1 peak paths to explicit scene audio. The mother and groom-side reaction shots keep one wedding-hall room tone; the processional begins on the couple-wide entrance and continues into the close without restarting. Wedding applause and cheer are tied to the authored entrance paragraph, not to a timer from scene load. Mother's Table keeps rural room tone through the first three paragraphs before `intimate` enters on the inherited-care reveal. The Narrow Room likewise holds only the cramped-room bed through the opening truth, then admits the same cue without restarting across either buildup route or the final decision. Jiyeon's verdict and Daeun's final test keep only their apartment/oneroom life through both buildup paths; `reckoning` enters once at the irreversible decision instead of using a breakup cue that would spoil the choice. The guarantee bill holds street/pojangmacha ambience without score before Hyunsu's intimate meal, while the last signature keeps the city bed until `reckoning` enters at the authored paragraph. Father's 48-week legacy uses the live housing ambience before `grief`. Both sea dates remain on train ambience with no score through their two buildup paths, then move explicitly to seaside ambience and `wonder` only after the beach arrival. Both fireworks dates retain the Hangang crowd bed with no fireworks cue during buildup; the final decision alone admits `wonder` and the paragraph-2 distant explosion, so the soundtrack cannot announce the first shell before the prose and image do. Daeun's first-night chain keeps the actual housing image while the explicit `rain_room` bed carries rain on glass and a restrained indoor appliance/HVAC floor; it contains no outdoor voices, never enables indoor rain particles, and does not restart across the four linked events. Sangchul's first meeting keeps only the same real-estate-office room tone through all four linked events: no `reckoning` or reveal cue may label him a villain before Minjun knows why he paused at the word Changwon. His deduction then resolves `current_housing` into the live goshiwon, one-room, villa, or apartment room tone; both evidence routes stay unscored, and `reckoning` starts only when the records converge at the final choice. `orthodox_pinnacle` keeps the ordinary restaurant bed under the team-dinner pause instead of borrowing a victory cue. `burnout` keeps only the existing hospital room tone under the first-person observation-bed image; no score, alarm, heartbeat, or melodramatic monitor announces how the player should read the silence.

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

## Player-Facing Controls

- Event scenes expose a compact top-right Settings button for mouse users.
- `gd_menu` opens text size, language, Music/Ambience, SFX, and Reduce Motion from inside a story event without scrolling.
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
AUDIO_SOURCE_AUDIT_OK assets=134 bgm=20 ambience=47 sfx=67 source_libraries=8 recordings_or_samples=134 procedural=0
SCENE_AUDIO_CONTRACT_OK cg=59 peak_events=116 ambience_keys=38 music_keys=20 demo_contracts=45 demo_foley_events=43
GAME_AUDIO_CONTRACT_OK physical=31 stages=19 activities=7 activity_music=1 human_layers=9 direct_pad=9
AUDIO_ASSET_CHECK_OK bgm=20 ambience=47 sfx=67
LAUNCH_AUDIO_OK stereo=2 rate=44100 duration=1.55
BGM_CONTINUITY_OK mode=menu key=menu ambience=
GAME_AUDIO_RUNTIME_OK physical=31 ambience_roundtrip=3 varied_playback=1 casino_music=1
MORAL_AMBIENCE_CHECK_OK profiles=9 neutral=-8.04 dark=-22.04 deep=-54.04
STORY_AUDIO_SETTINGS_CHECK_OK text=3 locale=ko/en timer_pause=11996 result_replay=0
DEMO_EXPERIENCE_AUDIT_OK reports=2 parity=ko/en music=10 authored_music=41
```

Sangchul's casino invitation remains on the live housing room tone through the message, both thought routes, and the final reply without restarting or introducing villain music. Only an accepted reply, ticket confirmation, and explicit bus arrival may switch the camera to `jeongseon_casino_exterior` and the street bed.

Hyunsu's reunion remains scoreless on the live housing room tone through the employment message and both memory routes. Only the explicit Saturday arrival at the old-neighborhood restaurant starts the `cafe` bed and `intimate` score; moving between message links cannot restart either layer.

## Human Listening Gate

Before demo lock, listen at the real 1280x800/Steam Deck presentation and on headphones, laptop speakers, and a living-room TV:

1. Play the complete Knee memory without skipping. The player must hear a modest family home before seeing the room, recognize one unbroken family motif, and feel the door/paper beats without hearing a tragedy jingle.
2. Play ten consecutive rounds of each casino game. Repeated ticks must not become a metronome.
3. Compare each physical sound with the visible material. Paper, felt, ceramic, metal, glass, and asphalt must not share one transient.
4. Enter and leave every activity. In Jeongseon, move floor→table→floor repeatedly; the motif must intensify and relax without restarting, while room tone and physical sounds remain legible. No abrupt cut or AP-hub bleed is allowed.
5. Play the wedding chain without skipping. Processional continuity, paragraph applause, voice-free room tone, and decision silence must feel like one scene.
6. A/B alternate recorded takes for any weak physical cue. Promote only the take that sounds native to the modern illustration while preserving source hashes and license evidence.
7. Compare the same cafe, street, casino, and wedding screen at Gray, Light Black, Deep Black, and White. Only human presence should radically recede; the place and interaction timing must remain believable.
8. Cold-boot three times on all three output classes. The publisher sting must read as one restrained brand gesture, never as a mobile reward chirp, and must not replay at the title or New Story transition.
