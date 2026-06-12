# Gangnam Dream Audio QA

Updated: 2026-06-13

## Scope

- BGM assets under `assets/audio/bgm_*.ogg`
- SFX assets under `assets/audio/sfx_*.wav`
- Runtime wiring in `autoloads/BGMPlayer.gd` and `autoloads/AudioManager.gd`
- Import settings for looping BGM

## Summary

VISUAL_AUDIO P3 audio replacement is complete for the current runtime surface.

- 7 BGM tracks regenerated as Ogg Vorbis, stereo, 44100 Hz.
- 17 SFX regenerated as mono 44100 Hz WAV.
- Previously silent runtime SFX calls are now mapped: `buy`, `sell`, `tab_open`.
- `tools/AudioAssetCheck.tscn` verifies all BGM/SFX paths resolve to `AudioStream` and scans source code for unmapped `AudioManager.play("...")` keys.
- BGM import loop settings are on for menu/goshiwon/main/apartment/crisis/ending and off for victory.

## BGM

| File | Runtime Key | Duration | Loop | Role |
|---|---|---:|---|---|
| `bgm_menu.ogg` | `menu` | 54.86s | yes | Title/menu, Seoul night anticipation |
| `bgm_gosiwon.ogg` | `early` | 53.33s | yes | Early goshiwon loop, fluorescent-night anxiety |
| `bgm_main.ogg` | `hustle` | 46.83s | yes | Employed/mid-run lo-fi Seoul routine |
| `bgm_apartment.ogg` | `late_tense` | 42.67s | yes | Late-run upward mobility tension |
| `bgm_crisis.ogg` | `crisis` | 42.35s | yes | Burnout/health/mental crisis |
| `bgm_victory.ogg` | `ending_good` / milestone material | 8.20s | no | Short understated success burst |
| `bgm_ending.ogg` | `ending_bad` | 63.16s | yes | Bittersweet ending reflection |

## SFX

| File | Runtime Key | Duration | Role |
|---|---|---:|---|
| `sfx_click.wav` | `click` | 0.055s | Button click |
| `sfx_close.wav` | `close` | 0.120s | Modal close |
| `sfx_open_modal.wav` | `open_modal` | 0.180s | Modal open |
| `sfx_tab_open.wav` | `tab_open` | 0.140s | Tab/minigame panel open |
| `sfx_choice_made.wav` | `choice_made` | 0.120s | Story choice confirm |
| `sfx_event_new.wav` | `event_new` | 0.320s | Event/race cue |
| `sfx_month.wav` | `month` | 0.350s | Month transition |
| `sfx_money_gain.wav` | `money_gain` | 0.280s | Small/normal gain |
| `sfx_money_loss.wav` | `money_loss` | 0.340s | Loss/spend |
| `sfx_money_big.wav` | `money_big` | 0.650s | Big gain/milestone |
| `sfx_buy.wav` | `buy` | 0.160s | Trading buy |
| `sfx_sell.wav` | `sell` | 0.160s | Trading sell |
| `sfx_stat_up.wav` | `stat_up` | 0.180s | Stat increase |
| `sfx_stat_down.wav` | `stat_down` | 0.220s | Stat decrease |
| `sfx_housing_up.wav` | `housing_up` | 0.550s | Housing upgrade |
| `sfx_game_over.wav` | `game_over` | 0.950s | Bad ending/game over |
| `sfx_success.wav` | `success` | 0.820s | Strong success/Gangnam Dream |

## Generation

- Script: `tools/generate_audio_assets.py`
- BGM generation: deterministic local lo-fi synthesis, then Ogg Vorbis encoding.
- SFX generation: deterministic local synthesis to WAV.
- Encoding fallback used in this session: `imageio-ffmpeg` installed into `/tmp/gangnam_audio_deps` because the CapCut-bundled ffmpeg binary exited with SIGTRAP on this machine.

## Verification

Commands run:

```bash
PYTHONPATH=/tmp/gangnam_audio_deps python tools/generate_audio_assets.py
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --quit-after 30
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/AudioAssetCheck.tscn
```

Latest result:

```text
AUDIO_ASSET_CHECK_OK bgm=7 sfx=17
```
