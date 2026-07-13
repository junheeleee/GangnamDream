#!/usr/bin/env python3
"""Static and rendered-output gates for the Gangnam Dream store trailers."""

from __future__ import annotations

import argparse
import json
import re
import struct
import subprocess
import sys
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
TIMELINE = HERE / "timeline.json"
LANGUAGES = ("ko", "en")
EDIT_LENGTHS = ("30", "60")
STYLES = {"Hook", "EndTitle", "EndBody"}


def fail(message: str) -> None:
    raise RuntimeError(message)


def load_timeline() -> dict:
    with TIMELINE.open(encoding="utf-8") as handle:
        return json.load(handle)


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        header = handle.read(24)
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        fail(f"not a PNG: {path}")
    return struct.unpack(">II", header[16:24])


def source_path(data: dict, captures: Path | None, frame: str) -> Path:
    if frame == "@keyart":
        return ROOT / data["keyart"]
    if captures is None:
        return Path(frame)
    return captures / frame


def check_static(data: dict, captures: Path | None = None) -> None:
    video = data.get("video", {})
    if (video.get("width"), video.get("height"), video.get("fps")) != (1920, 1080, 60):
        fail("trailer master contract must remain 1920x1080 at 60 fps")
    for asset_key in ("keyart", "music"):
        asset = ROOT / str(data.get(asset_key, ""))
        if not asset.is_file():
            fail(f"missing trailer {asset_key}: {asset}")

    edits = data.get("edits", {})
    if tuple(sorted(edits.keys())) != EDIT_LENGTHS:
        fail("timeline must define exactly the 30 and 60 second edits")
    used_frames: set[str] = set()
    for edit_key in EDIT_LENGTHS:
        edit = edits[edit_key]
        target = float(edit["duration"])
        cuts = edit.get("cuts", [])
        actual = sum(float(cut["duration"]) for cut in cuts)
        if abs(actual - target) > 0.001:
            fail(f"{edit_key}s cut durations total {actual:.3f}, expected {target:.3f}")
        if not cuts or cuts[-1].get("frame") != "@keyart":
            fail(f"{edit_key}s edit must end on the canonical key art")
        for cut in cuts:
            frame = str(cut.get("frame", ""))
            duration = float(cut.get("duration", 0.0))
            if duration <= 0.0:
                fail(f"{edit_key}s edit has a non-positive cut: {frame}")
            if frame != "@keyart" and not re.fullmatch(r"trailer_\d{2}_[a-z0-9_]+\.png", frame):
                fail(f"invalid capture name in {edit_key}s edit: {frame}")
            used_frames.add(frame)
            if captures is not None:
                path = source_path(data, captures, frame)
                if not path.is_file():
                    fail(f"missing captured frame: {path}")
                if png_size(path) != (1920, 1080):
                    fail(f"capture is not 1920x1080: {path} -> {png_size(path)}")

        last_start = -1.0
        for caption in edit.get("captions", []):
            start = float(caption.get("start", -1.0))
            end = float(caption.get("end", -1.0))
            if start < last_start or start < 0.0 or end <= start or end > target:
                fail(f"invalid caption timing in {edit_key}s edit: {caption}")
            last_start = start
            if caption.get("style") not in STYLES:
                fail(f"unknown caption style in {edit_key}s edit: {caption.get('style')}")
            for lang in LANGUAGES:
                if not str(caption.get(lang, "")).strip():
                    fail(f"missing {lang} caption in {edit_key}s edit at {start}")

        audio = edit.get("audio", {})
        for band in ("gray", "dark", "silence"):
            span = audio.get(band, [])
            if len(span) != 2 or not (0.0 <= float(span[0]) < float(span[1]) <= target):
                fail(f"invalid {band} audio span in {edit_key}s edit")
        for cue in audio.get("cues", []):
            cue_path = ROOT / str(cue.get("path", ""))
            cue_at = float(cue.get("at", -1.0))
            if not cue_path.is_file() or not (0.0 <= cue_at < target):
                fail(f"invalid audio cue in {edit_key}s edit: {cue}")

    expected = {f"trailer_{index:02d}_" for index in range(1, 23)}
    observed = {frame[:11] for frame in used_frames if frame != "@keyart"}
    if observed != expected:
        fail(f"capture contract mismatch: missing={sorted(expected - observed)} extra={sorted(observed - expected)}")


def probe_video(video: Path, ffmpeg: Path, expected_seconds: float) -> None:
    if not video.is_file() or video.stat().st_size < 1_000_000:
        fail(f"rendered trailer is missing or implausibly small: {video}")
    result = subprocess.run(
        [str(ffmpeg), "-hide_banner", "-i", str(video)],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    metadata = result.stderr
    duration_match = re.search(r"Duration: (\d+):(\d+):(\d+(?:\.\d+)?)", metadata)
    if not duration_match:
        fail(f"could not read duration from {video}")
    hours, minutes, seconds = duration_match.groups()
    duration = int(hours) * 3600 + int(minutes) * 60 + float(seconds)
    if abs(duration - expected_seconds) > 0.12:
        fail(f"{video.name} duration {duration:.3f}s, expected {expected_seconds:.3f}s")
    if not re.search(r"Video: h264.*1920x1080.*60 fps", metadata):
        fail(f"{video.name} is not H.264 1920x1080 at 60 fps")
    if not re.search(r"Audio: aac.*48000 Hz.*stereo", metadata):
        fail(f"{video.name} is missing the 48 kHz stereo AAC mix")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--captures", type=Path)
    parser.add_argument("--video", type=Path)
    parser.add_argument("--ffmpeg", type=Path)
    parser.add_argument("--seconds", type=float)
    args = parser.parse_args()
    try:
        data = load_timeline()
        check_static(data, args.captures)
        if args.video is not None:
            if args.ffmpeg is None or args.seconds is None:
                fail("--video requires --ffmpeg and --seconds")
            probe_video(args.video, args.ffmpeg, args.seconds)
    except (OSError, ValueError, KeyError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"TRAILER_CHECK_FAIL {exc}", file=sys.stderr)
        return 1
    suffix = f" captures={args.captures}" if args.captures else ""
    if args.video:
        suffix += f" video={args.video}"
    print(f"TRAILER_CHECK_OK edits=2 languages=2 frames=22{suffix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
