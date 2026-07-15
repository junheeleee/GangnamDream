# Gangnam Dream Audio QA

Updated: 2026-07-15

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
| BGM | 12 | `autoloads/BGMPlayer.gd` |
| Ambience | 45 | `autoloads/BGMPlayer.gd` (36 inert/place + 9 human-presence layers) |
| SFX | 52 | `autoloads/AudioManager.gd` |
| **Total** | **109** | one deterministic in-repo source each |

All current audio uses original deterministic synthesis; external samples: 0. The source ledger is enforced by `tools/audio_source_audit.py`.

## Scene Music

The seven base tracks cover title, routine, crisis, and endings. Five authored scene tracks cover emotional peaks:

| Key | Role | Loop rule |
|---|---|---|
| `wedding_processional` | Daeun entrance, aisle approach, vows | starts with the couple-wide entrance and continues into the close without restart |
| `intimate` | vulnerable romance and family closeness | paragraph-triggered |
| `reckoning` | confrontation and irreversible truth | silence before entry |
| `grief` | death, separation, aftermath | paragraph-triggered |
| `wonder` | awe, release, landmark-scale emotional lift | paragraph-triggered |

`assets/scene_audio_manifest.json` maps all 57 active CGs to ambience and all 37 events on the 28 Tier-1 peak paths to explicit scene audio. The mother and groom-side reaction shots keep one wedding-hall room tone; the processional begins on the couple-wide entrance and continues into the close without restarting. Wedding applause and cheer are tied to the authored entrance paragraph, not to a timer from scene load.

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

Focus traversal is a last resort. Gameplay scenes use direct state machines and contextual actions; focus is allowed only for settings and short conventional linear menus. The audio settings panel therefore focuses its first of two rows, while casino rounds, racing, and card play never require walking a flat button graph.

## Player-Facing Controls

- Event scenes expose a compact top-right audio button for mouse users.
- `gd_menu` opens Music/Ambience and SFX sliders from inside a story event.
- Xbox/Steam Deck Menu, DualSense Options, and Switch `+` resolve through the same action.
- The modal blocks story advance and AUTO while open; Menu or Cancel closes it.

## Automated Gates

```bash
python3 tools/audio_source_audit.py
python3 tools/scene_audio_contract_check.py
python3 tools/game_audio_contract_check.py
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/AudioAssetCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/BGMContinuityCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/GameAudioContractCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/MoralAmbienceCheck.tscn
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/StoryAudioSettingsCheck.tscn
```

Latest targeted result:

```text
AUDIO_SOURCE_AUDIT_OK assets=109 bgm=12 ambience=45 sfx=52 external_samples=0
SCENE_AUDIO_CONTRACT_OK cg=57 peak_events=37 ambience_keys=36 music_keys=12
GAME_AUDIO_CONTRACT_OK physical=17 stages=19 activities=7 human_layers=9 direct_pad=9
AUDIO_ASSET_CHECK_OK bgm=12 ambience=45 sfx=52
BGM_CONTINUITY_OK
GAME_AUDIO_RUNTIME_OK physical=17 ambience_roundtrip=3 varied_playback=1
MORAL_AMBIENCE_CHECK_OK profiles=9
STORY_AUDIO_SETTINGS_CHECK_OK
```

## Human Listening Gate

Before demo lock, listen at the real 1280x800/Steam Deck presentation and on both headphones and laptop speakers:

1. Play ten consecutive rounds of each casino game. Repeated ticks must not become a metronome.
2. Compare each physical sound with the visible material. Paper, felt, ceramic, metal, glass, and asphalt must not share one transient.
3. Enter and leave every activity. No BGM restart, abrupt room-tone cut, or AP-hub bleed is allowed.
4. Play the wedding chain without skipping. Processional continuity, paragraph applause, voice-free room tone, and decision silence must feel like one scene.
5. A/B every procedural physical asset against a professional foley candidate. Promote only the version that sounds native to the modern illustration while preserving license evidence.
6. Compare the same cafe, street, casino, and wedding screen at Gray, Light Black, Deep Black, and White. Only human presence should radically recede; the place and interaction timing must remain believable.
