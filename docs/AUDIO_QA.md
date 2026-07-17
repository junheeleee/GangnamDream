# Gangnam Dream Audio QA

Updated: 2026-07-17

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

`assets/game_audio_manifest.json` is the machine-readable identity and stage contract. Procedural masters are project-owned, timing-safe originals. If any one sounds synthetic beside the final illustration, replace the file behind the same semantic key; do not weaken the stage contract to preserve a placeholder.

## Current Inventory

| Class | Count | Runtime owner |
|---|---:|---|
| BGM | 14 | `autoloads/BGMPlayer.gd` |
| Ambience | 45 | `autoloads/BGMPlayer.gd` (36 inert/place + 9 human-presence layers) |
| SFX | 53 | `autoloads/AudioManager.gd` |
| **Total** | **112** | one deterministic in-repo source each |

All current audio uses original deterministic synthesis; external samples: 0. The source ledger is enforced by `tools/audio_source_audit.py`.

## Launch Identity

- `publisher_sting` is a project-owned 1.55-second stereo 48 kHz mark, generated deterministically by `tools/generate_launch_audio.py`.
- It plays exactly once with the transparent JUNPAC mark, at a restrained -4 dB mix trim. It is neither menu music nor a reusable reward sound.
- Skipping the publisher pre-roll cannot stack or replay the sting. The title and new-story opening then use their existing music/ambience owners without carrying the sting forward.
- `First30SecondsCheck.tscn` locks one sting, one mandatory title input gate, and a maximum three-beat opening. `generate_launch_audio.py --check` locks the file format and duration.

## Scene Music

`menu`, `early`, `hustle`, and `late_tense` are lobby-only masters. StoryMode, the weekly hub, month transitions, ordinary events, and unscored arcs may not infer them from age, rarity, category, or an `arc_` prefix. Those surfaces retain only authored place, season, and human ambience. Cinematic story music enters solely through an explicit `scene_audio_manifest` paragraph contract or a menu/ending owner; continuous activity music requires its own `game_audio_manifest` contract.

The seven base tracks cover title, routine, crisis, and endings. Five authored scene tracks cover emotional peaks:

| Key | Role | Loop rule |
|---|---|---|
| `wedding_processional` | Daeun entrance, aisle approach, vows | starts with the couple-wide entrance and continues into the close without restart |
| `intimate` | vulnerable romance and family closeness | paragraph-triggered |
| `reckoning` | confrontation and irreversible truth | silence before entry |
| `grief` | death, separation, aftermath | paragraph-triggered |
| `wonder` | awe, release, landmark-scale emotional lift | paragraph-triggered |

`assets/scene_audio_manifest.json` maps all 57 active CGs to ambience and all 90 events on the 28 Tier-1 peak paths to explicit scene audio. The mother and groom-side reaction shots keep one wedding-hall room tone; the processional begins on the couple-wide entrance and continues into the close without restarting. Wedding applause and cheer are tied to the authored entrance paragraph, not to a timer from scene load. Mother's Table keeps rural room tone through the first three paragraphs before `intimate` enters on the inherited-care reveal. The Narrow Room likewise holds only the cramped-room bed through the opening truth, then admits the same cue without restarting across either buildup route or the final decision. Jiyeon's verdict and Daeun's final test keep only their apartment/oneroom life through both buildup paths; `reckoning` enters once at the irreversible decision instead of using a breakup cue that would spoil the choice. Both sea dates remain on train ambience with no score through their two buildup paths, then move explicitly to seaside ambience and `wonder` only after the beach arrival. Both fireworks dates retain the Hangang crowd bed with no fireworks cue during buildup; the final decision alone admits `wonder` and the paragraph-2 distant explosion, so the soundtrack cannot announce the first shell before the prose and image do.

## Jeongseon Casino Music

Jeongseon is the only current activity that owns continuous music. `casino_floor` and `casino_table` are two arrangements of one 92 BPM, 16-bar, 41.74-second motif. They share harmony, melody, loop metadata, and playback phase:

- The floor arrangement leaves space for room tone and restrained human presence.
- The table arrangement adds a low pulse and muted offbeats without replacing chip, card, dice, wheel, or reel transients. Its integrated level is 2.0 LU above the floor arrangement, enough to increase pressure without becoming a separate song.
- Entering any of the six tables inherits the floor playback position. Returning to the hub inherits it back. Re-entering the same layer never rewinds.
- Leaving Jeongseon fades the score out once, then restores housing and seasonal ambience. The AP hub cannot remain audible under the casino.

The two generated masters establish timing and identity, not final human approval. They still require headphones, laptop speakers, and living-room TV listening beside ten consecutive rounds of each game.

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

## Moral Ambience

The world is split by meaning rather than by a global dark filter:

- `Master` place layers keep traffic, HVAC, appliances, weather, wheels, and room resonance present so the location never disappears.
- `GangnamDreamHumanAmbience` carries only indistinct population and thin-wall life. It has its own low-pass filter and gain envelope.
- At Gray, human presence is restrained but clear. Light Black moves it 14 dB farther away and low-passes it to 2.6 kHz. Deep Black places it 46 dB below Gray and low-passes it to 780 Hz.
- White restores human detail and air. No morality UI, threshold sting, or good/evil jingle announces the transition.
- The transition lasts 3.8 seconds and does not restart the room loop. The intended realization is delayed recognition: the player notices that Seoul has become populated by machines before being told anything.

These generated layers contain no intelligible language and no musical pitch pattern. They are replaceable semantic masters; launch approval still requires image-paired listening against professional contemporary field recordings.

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
AUDIO_SOURCE_AUDIT_OK assets=112 bgm=14 ambience=45 sfx=53 external_samples=0
SCENE_AUDIO_CONTRACT_OK cg=57 peak_events=90 ambience_keys=36 music_keys=14
GAME_AUDIO_CONTRACT_OK physical=17 stages=19 activities=7 activity_music=1 human_layers=9 direct_pad=9
AUDIO_ASSET_CHECK_OK bgm=14 ambience=45 sfx=53
LAUNCH_AUDIO_OK stereo=2 rate=48000 duration=1.55
BGM_CONTINUITY_OK mode=menu key=menu ambience=
GAME_AUDIO_RUNTIME_OK physical=17 ambience_roundtrip=3 varied_playback=1 casino_music=1
MORAL_AMBIENCE_CHECK_OK profiles=9
STORY_AUDIO_SETTINGS_CHECK_OK text=3 locale=ko/en timer_pause=11996 result_replay=0
```

## Human Listening Gate

Before demo lock, listen at the real 1280x800/Steam Deck presentation and on both headphones and laptop speakers:

1. Play ten consecutive rounds of each casino game. Repeated ticks must not become a metronome.
2. Compare each physical sound with the visible material. Paper, felt, ceramic, metal, glass, and asphalt must not share one transient.
3. Enter and leave every activity. In Jeongseon, move floor→table→floor repeatedly; the motif must intensify and relax without restarting, while room tone and physical sounds remain legible. No abrupt cut or AP-hub bleed is allowed.
4. Play the wedding chain without skipping. Processional continuity, paragraph applause, voice-free room tone, and decision silence must feel like one scene.
5. A/B every procedural physical asset against a professional foley candidate. Promote only the version that sounds native to the modern illustration while preserving license evidence.
6. Compare the same cafe, street, casino, and wedding screen at Gray, Light Black, Deep Black, and White. Only human presence should radically recede; the place and interaction timing must remain believable.
7. Cold-boot three times on headphones, laptop speakers, and a living-room TV. The publisher sting must read as one restrained brand gesture, never as a mobile reward chirp, and must not replay at the title or New Story transition.
