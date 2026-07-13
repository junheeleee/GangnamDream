# Store Trailer Pipeline

This pipeline captures real Godot surfaces first, then uses ffmpeg only for cuts,
localized subtitles, the canonical BGM mix, and final H.264 encoding.

```bash
GODOT=/absolute/path/to/godot ./tools/trailer/render_all.sh
```

Outputs are written to the ignored `build/trailer/final/` directory:

- `gangnam_dream_30s_ko.mp4`
- `gangnam_dream_30s_en.mp4`
- `gangnam_dream_60s_ko.mp4`
- `gangnam_dream_60s_en.mp4`

Each video has a matching `.srt` subtitle file and `.json` checksum manifest.
Five extracted QA frames per edit are written under `build/trailer/final/qa/`.

`resolve_ffmpeg.sh` uses `FFMPEG`, a system ffmpeg, or a build-local pinned
`imageio-ffmpeg` binary in that order. Generated tools and videos stay under
`build/` and are not committed.
