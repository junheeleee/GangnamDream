#!/usr/bin/env python3
"""Validate the committed Steam screenshot set without image dependencies."""

from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path


EXPECTED = [
    "01_cold_open.png",
    "02_money_mule_timer.png",
    "03_montage_card.png",
    "04_time_ledger.png",
    "05_moral_bright.png",
    "06_moral_dark.png",
    "07_season_date_cg.png",
    "08_ending_recap.png",
]
TARGET_SIZE = (1280, 720)
MIN_BYTES = 50_000
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def png_size(path: Path) -> tuple[int, int]:
    header = path.read_bytes()[:24]
    if len(header) < 24 or header[:8] != PNG_SIGNATURE or header[12:16] != b"IHDR":
        raise ValueError("not a valid PNG header")
    return struct.unpack(">II", header[16:24])


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    shot_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else repo_root / "assets/store/screenshots"
    errors: list[str] = []

    actual = sorted(path.name for path in shot_dir.glob("*.png")) if shot_dir.is_dir() else []
    if actual != EXPECTED:
        missing = [name for name in EXPECTED if name not in actual]
        extra = [name for name in actual if name not in EXPECTED]
        if missing:
            errors.append("missing screenshots: " + ", ".join(missing))
        if extra:
            errors.append("unexpected screenshots: " + ", ".join(extra))

    hashes: dict[str, str] = {}
    for name in EXPECTED:
        path = shot_dir / name
        if not path.is_file():
            continue
        try:
            size = png_size(path)
        except ValueError as exc:
            errors.append(f"{name}: {exc}")
            continue
        if size != TARGET_SIZE:
            errors.append(f"{name}: expected {TARGET_SIZE[0]}x{TARGET_SIZE[1]}, got {size[0]}x{size[1]}")
        if path.stat().st_size < MIN_BYTES:
            errors.append(f"{name}: suspiciously small file ({path.stat().st_size} bytes)")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest in hashes:
            errors.append(f"{name}: duplicates {hashes[digest]}")
        else:
            hashes[digest] = name

    if errors:
        for error in errors:
            print(f"STORE_SHOT_CHECK_ERROR {error}", file=sys.stderr)
        return 1

    print(
        "STORE_SHOT_CHECK_OK "
        f"count={len(EXPECTED)} size={TARGET_SIZE[0]}x{TARGET_SIZE[1]} unique={len(hashes)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
