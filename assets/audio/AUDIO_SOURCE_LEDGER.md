# Audio Source Ledger

This ledger records source and redistribution status for production audio. `tools/audio_source_audit.py` is the machine-readable per-file owner map and fails when any WAV/OGG is missing, stale, or assigned twice.

| Asset | Source | External samples | Commercial status | Reproduction |
|---|---|---|---|---|
| `sfx_choice_made.wav` | Deterministic in-repo synthesis | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |
| `sfx_open_modal.wav` | Deterministic in-repo synthesis | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |
| `sfx_close.wav` | Deterministic in-repo synthesis | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |
| `sfx_tab_open.wav` | Deterministic in-repo synthesis | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |
| `sfx_result_ledger.wav` | Deterministic dry register contact | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |
| `sfx_result_human.wav` | Deterministic cloth-and-breath swell | None | Project-owned | `python3 tools/generate_gangnam_ui_sfx.py` |

| Asset group | Source | External samples | Commercial status | Reproduction |
|---|---|---|---|---|
| 7 base `bgm_*.ogg` files | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_audio_assets.py` |
| 21 general/casino SFX | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_audio_assets.py` |
| 13 scene/casino `bgm_*.ogg` files | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_audio_p1_assets.py` |
| 47 `amb_*.wav` files | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_audio_p1_assets.py` |
| 39 scene/casino SFX | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_audio_p1_assets.py` |
| 6 Gangnam Ink UI SFX | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_gangnam_ui_sfx.py` |
| 1 publisher sting | Deterministic in-repo synthesis | None | Project-owned | `tools/generate_launch_audio.py` |

The current release inventory is 134 files: 20 BGM, 47 ambience, and 67 SFX. The demo-facing long beds, human-presence beds, and story foley also pass duration, RMS, and clipping envelopes in `tools/audio_source_audit.py`. `python3 tools/generate_audio_p1_assets.py --demo-audio-only` reproduces the 39 files remastered or added for the six-month vertical slice without rewriting unrelated audio.

## Release Gate

- Every BGM, ambience, and SFX file must be assigned exactly once in `audio_source_audit.py` before release candidate status.
- Generated audio must name its deterministic source script or generation job.
- Purchased audio must include vendor, pack, license type, purchase proof location, and modification notes.
- AI-generated audio must record the service, account ownership, generation date, prompt/job reference, and the service terms snapshot used at generation time.
- Files with unknown provenance may remain during development but may not ship.
