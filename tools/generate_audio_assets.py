#!/usr/bin/env python3
"""Retired compatibility gate for the sample-only release audio pipeline."""

from __future__ import annotations

import argparse

from audio_source_audit import main as audit_audio_sources


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if not args.check:
        print("CORE_AUDIO_GENERATOR_RETIRED use tools/build_sample_audio_assets.py")
        return 2
    result = audit_audio_sources()
    if result == 0:
        print("CORE_AUDIO_GENERATOR_OK source=recordings_and_real_instrument_samples")
    return result


if __name__ == "__main__":
    raise SystemExit(main())
