# Gangnam Dream Store Trailer Production

## Master Contract

- Deliverables: Korean and English 30-second trailers plus Korean and English 60-second extended trailers.
- Master: 1920x1080, 60 fps, H.264 High, yuv420p, AAC 48 kHz stereo, fast-start MP4.
- Source rule: every gameplay frame comes from a real Godot scene rendered by `ScreenshotQA --qa=trailer`. ffmpeg only cuts, burns localized captions, mixes project-owned audio, and encodes.
- Canonical timeline: `tools/trailer/timeline.json`. Cut totals, caption timing, source paths, audio spans, and both locales are machine checked.
- Generated videos stay under ignored `build/trailer/`; they are release artifacts, not runtime assets.

## Locked 30-Second Cut

| Time | In-game material | Message / sound |
|---|---|---|
| 0-4s | 2031 Gangnam cold open | Who Minjun becomes is the player's decision. |
| 4-8s | Actual week-one AP board, 500,000 won against 3 billion won | Five-year pressure. |
| 8-12s | Actual money-mule choice at 12, 7, and 3 seconds | Countdown and event/choice impacts. |
| 12-17s | The same StoryMode surface at White, Gray, and Black | BGM closes through two low-pass stages. |
| 17-22s | Cherry blossom, sea, fireworks, and first married morning | A marriage that can be lost. |
| 22-26s | Divorce seal, Jiyeon's departure, and Rich and Alone | Full silence. |
| 26-30s | Canonical cast key art | Localized title, 35 endings, Steam wishlist CTA. |

The 60-second edit keeps this spine and adds the montage/time-record surfaces, investment, horse racing, blackjack, roulette, and the final five-scene recap. It does not introduce footage or claims that are absent from the game.

## Rebuild

```bash
GODOT=/absolute/path/to/godot ./tools/trailer/render_all.sh
```

`resolve_ffmpeg.sh` uses, in order, `$FFMPEG`, a system ffmpeg, an existing build-local `imageio-ffmpeg`, or installs pinned `imageio-ffmpeg==0.6.0` under ignored `build/trailer-tools/`. No global tool install is required.

Outputs:

- `build/trailer/final/gangnam_dream_30s_ko.mp4`
- `build/trailer/final/gangnam_dream_30s_en.mp4`
- `build/trailer/final/gangnam_dream_60s_ko.mp4`
- `build/trailer/final/gangnam_dream_60s_en.mp4`

Each MP4 has a matching SRT and JSON SHA-256 manifest. Five review frames per edit are exported to `build/trailer/final/qa/`.

## Release QA

1. Run `python3 tools/trailer/trailer_check.py` before capture.
2. Run `./tools/trailer/render_all.sh`; all four renders must end in `TRAILER_RENDER_OK` and the wrapper in `TRAILER_ALL_OK`.
3. Inspect all 20 extracted QA frames. Captions must stay inside title-safe space, preserve faces and decisive controls, and contain no wrong-language surface text.
4. Confirm the 30-second mix is near -16 LUFS, below -1 dBTP, and fully silent from 22-26 seconds. The 60-second mix is silent from 44-50 seconds.
5. Watch each MP4 once at normal speed with sound and once muted. The premise, timer, Moral Tint, romance loss, and CTA must read in both passes.
6. Claude owns the final editorial/copy judgment. A passing pipeline proves reproducibility and technical conformance, not that a cut is creatively locked.

2026-07-13 production proof: all 22 Korean and English source frames rendered at 1920x1080; all four MP4s passed duration/codec/audio probes. The 30-second English mix measured -15.3 LUFS integrated and -1.1 dBTP. Godot exits the dense multi-scene capture scope with known Texture/RID cleanup warnings but returns code 0 after `SCREENSHOT_QA_DONE`; this is harness cleanup debt, not missing footage.
