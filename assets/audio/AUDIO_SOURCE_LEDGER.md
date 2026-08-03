# Audio Source Ledger

Updated: 2026-07-23

## Release Rule

Every shipping sound must originate from an actual field/object recording or a
recorded real-instrument sample. Editing, layering, looping, resampling, pitch
shifting, EQ, compression, reverb, and loudness normalization are allowed.
Oscillators, generated noise, code-built waveforms, and runtime synthesized
fallbacks are prohibited.

The per-file source of truth is
`assets/audio/AUDIO_SOURCE_MANIFEST.json`. It records all 139 output paths,
source pack and original filename, source SHA-256, output SHA-256, license, and
edit history. Raw third-party libraries remain outside the repository.

## Inventory

| Class | Count | Source palette |
|---|---:|---|
| BGM | 20 | Original scores rendered from recorded Yamaha C5 samples |
| Ambience | 49 | Field-recorded rooms, weather, transport, city, water, crowds, and machinery |
| SFX | 70 | Recorded paper, cloth, doors, controls, phone, keyboard, cards, chips, dice, vehicles, crowds, and piano stingers |
| **Total** | **139** | **139 recording/sample-backed assets; 0 synthesized assets** |

## Libraries

| Library | Provider/author | License | Primary use |
|---|---|---|---|
| GDC 2026 Game Audio Bundle | Sonniss and participating recordists | Sonniss GDC Bundle License | Modern ambience, transport, weather, mechanisms, crowd, paper, casino, fireworks |
| Owlish Media Sound Effects | OwlishMedia | CC0 1.0 | Clock, cloth, footsteps, paper, phone, water, small impacts |
| Casino Audio 1.1 | Kenney Vleugels | CC0 1.0 | Cards, chips, dice |
| Horse Gallop on Different Surfaces | D4XX (`ground.mp3`; pack curated by congusbongus) | CC0 1.0 for the used file; pack has mixed per-file licenses | Racetrack hoof cycle |
| Salamander Grand Piano V3 | Alexander Holm | CC BY 3.0 | All score and piano stingers |
| Keyboard Soundpack #1 | unicaegames | CC0 1.0 | Human typing and key presses |
| Storm & Siren | TinyWorlds | CC0 1.0 | Civil-defense/storm siren |
| Crash Collision | qubodup | CC0 1.0 | Bicycle collision impact layer |
| Thirteen scene-specific Freesound recordings | Eirikr, unreadpages, giovannapaludetto, DylanTheFish, aghirlandaio, takecoins, cMilan, ecfike, mzui, JohnsonBrandEditing, Pfannkuchn, Kinoton, LG | CC0 1.0 | Barcode scanner, bus, wedding, casino, slot, roulette, apartment, office, convenience store, gym, hospital, and public announcement chime |

The audit reports 21 source records: the eight libraries above plus thirteen
individually pinned Freesound takes. Each take has its own author, sound page,
source hash, and edit history in the machine-readable manifest.

Required and voluntary credits are in
`assets/audio/AUDIO_THIRD_PARTY_NOTICES.md`.

## Build And Audit

```bash
python3 tools/build_sample_audio_assets.py --validate-only
python3 tools/build_sample_audio_assets.py
python3 tools/audio_source_audit.py
```

The canonical builder never generates a source waveform. The four former
generators are retired compatibility gates and cannot write release assets.
`BGMPlayer` and `AudioManager` report a missing asset as an error and leave that
cue silent; they never synthesize a substitute.

Expected audit result:

```text
AUDIO_SOURCE_AUDIT_OK assets=139 bgm=20 ambience=49 sfx=70 source_libraries=21 recordings_or_samples=139 procedural=0
```

The builder normalizes every Ogg page to a filename-derived stream serial and
recomputed checksum. Two consecutive complete builds must therefore produce
identical hashes for all 139 masters rather than changing RC provenance through
random container metadata.

The audit also rejects known semantic substitutions such as metro halls behind
goshiwon walls, food courts in convenience stores or casinos, thermometer
beeps as barcode scanners or queue calls, truck passes as buses, and radio controls as roulette
wheels. This proves provenance, inventory, hashes, basic duration/loudness,
semantic source identity, and absence of known synthesis code. It does not
approve musical taste, fatigue, or final mix quality. Those remain human
listening gates.
