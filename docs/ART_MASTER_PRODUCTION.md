# P0 Art Master Production

> Status: 1 of 52 P0 active rasters promoted. A promoted file is not permission to batch-process anatomy, lettering, reflections, or recurring props.

## Pilot Result

`assets/backgrounds/goshiwon_hallway.png` is the first approved 4K master.

| Contract | Result |
|---|---|
| Source | reviewed 1280x800 runtime background at Git ref `7530c4a` |
| Output | 3840x2400 PNG, SHA-256 `bc2192e633c4df9328327ce86390d8340da88affdb86c6eb38d9973e06fbfa70` |
| Engine | official Real-ESRGAN NCNN Vulkan v0.2.5.0, `realesrgan-x4plus` |
| Tile policy | one 1280px full-frame tile; no internal inference boundary |
| Human A/B | PASS: left utility fixture, center perspective, right shoe racks |
| Runtime QA | KO/EN `chapter1-spine`: 8 shots each at 1920x1080; EN 8 shots at 3840x2160 |

The promoted image keeps the same corridor, doors, window, utility fixtures, floor reflection, and shoe racks. It contains no foreground person, readable sign, real logo, vehicle, mirror, or narrative text. The 16:9 runtime cover crop remains stable behind portraits and three-choice docks.

## Rejected Trials

- `realesrgan-x4plus`, tile 256: rejected because every tile acquired a visibly different exposure block.
- `realesrgan-x4plus`, tile 0/auto: rejected because larger rectangular exposure seams remained.
- `realesrgan-x4plus-anime`, tile 256: rejected for the same seams plus excessive texture simplification.

The release gate therefore permits only `full_frame` tiling at least as large as the reviewed source. A higher pixel count with seams is a regression, not a master.

## Provenance

- Project/release: [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN/) / [v0.2.5.0](https://github.com/xinntao/Real-ESRGAN/releases/tag/v0.2.5.0)
- Portable macOS archive: recorded in `tools/art_master_manifest.json`, including archive, binary, model `.bin`, and model `.param` SHA-256 values.
- License: [BSD-3-Clause](https://raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE)
- Source, settings, rejected candidates, crop boxes, review verdict, and promoted hash: `tools/art_master_manifest.json`.

No downloaded binary or model is redistributed in this repository. The pipeline verifies a locally supplied official release against the pinned hashes before processing.

## Reproduction

```bash
python3 tools/art_master_pipeline.py build goshiwon_hallway \
  --engine /path/to/realesrgan-ncnn-vulkan \
  --model-dir /path/to/models \
  --ab

# Only after reviewing every generated 100% crop:
python3 tools/art_master_pipeline.py build goshiwon_hallway \
  --engine /path/to/realesrgan-ncnn-vulkan \
  --model-dir /path/to/models \
  --ab --promote --human-review-pass

python3 tools/art_master_audit.py
```

Candidates and A/B sheets default to the system temporary directory, outside the Godot project, so they cannot enter the import scan or release package.

## Next Gate

1. Preflight the next P0 environment candidates individually; do not assume a background is safe because it has no named actor.
2. Any screen, sign, book spine, family photo, distant face, vehicle badge, hand, or reflection moves the asset to repaint/regeneration review.
3. Character CG and portraits remain blocked from this blind pipeline. They require identity-locked final-size production or an alpha-aware process plus human paintover.
4. Physical 4K TV at normal sofa distance and Steam Deck inspection remain open human gates.
