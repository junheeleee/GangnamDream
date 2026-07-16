#!/usr/bin/env python3
"""Generate the restrained, project-owned JUNPAC launch sting."""

from __future__ import annotations

import argparse
import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "audio" / "sfx_publisher_sting.wav"
SAMPLE_RATE = 48_000
DURATION = 1.55


def smoothstep(value: float) -> float:
    value = max(0.0, min(1.0, value))
    return value * value * (3.0 - 2.0 * value)


def envelope(t: float, start: float, attack: float, release: float) -> float:
    if t < start or t >= start + attack + release:
        return 0.0
    if t < start + attack:
        return smoothstep((t - start) / attack)
    return 1.0 - smoothstep((t - start - attack) / release)


def render() -> bytes:
    rng = random.Random(0x4A554E50)
    frames: list[bytes] = []
    peak = 0.0
    samples: list[tuple[float, float]] = []
    for index in range(int(SAMPLE_RATE * DURATION)):
        t = index / SAMPLE_RATE
        low_env = envelope(t, 0.02, 0.16, 1.18)
        low = (
            math.sin(2.0 * math.pi * 73.42 * t) * 0.24
            + math.sin(2.0 * math.pi * 110.0 * t + 0.4) * 0.11
        ) * low_env

        gold_env = envelope(t, 0.18, 0.025, 0.92)
        gold = (
            math.sin(2.0 * math.pi * 659.25 * t) * 0.16
            + math.sin(2.0 * math.pi * 988.88 * t + 0.2) * 0.07
            + math.sin(2.0 * math.pi * 1318.51 * t + 0.7) * 0.025
        ) * gold_env * math.exp(-2.2 * max(0.0, t - 0.18))

        impact_env = envelope(t, 0.84, 0.004, 0.16)
        impact = (
            rng.uniform(-1.0, 1.0) * 0.08
            + math.sin(2.0 * math.pi * 176.0 * t) * 0.15
        ) * impact_env

        air_env = envelope(t, 0.0, 0.28, 1.20)
        air = rng.uniform(-1.0, 1.0) * 0.012 * air_env
        left = low + gold * 0.92 + impact + air
        right = low + gold * 1.06 + impact * 0.94 - air
        samples.append((left, right))
        peak = max(peak, abs(left), abs(right))

    gain = 0.62 / max(peak, 0.001)
    for left, right in samples:
        left_i = int(max(-1.0, min(1.0, left * gain)) * 32767)
        right_i = int(max(-1.0, min(1.0, right * gain)) * 32767)
        frames.append(struct.pack("<hh", left_i, right_i))
    return b"".join(frames)


def expected_properties(path: Path) -> bool:
    if not path.is_file():
        return False
    with wave.open(str(path), "rb") as source:
        return (
            source.getframerate() == SAMPLE_RATE
            and source.getnchannels() == 2
            and source.getsampwidth() == 2
            and abs(source.getnframes() / SAMPLE_RATE - DURATION) < 0.01
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        if not expected_properties(OUTPUT):
            print("LAUNCH_AUDIO_FAIL missing or invalid publisher sting")
            return 1
        print("LAUNCH_AUDIO_OK stereo=2 rate=48000 duration=1.55")
        return 0
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as target:
        target.setnchannels(2)
        target.setsampwidth(2)
        target.setframerate(SAMPLE_RATE)
        target.writeframes(render())
    print(f"wrote {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
