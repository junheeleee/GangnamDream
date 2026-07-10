#!/usr/bin/env python3
"""Generate the dry, non-pitched Gangnam Ink UI sound set.

No external samples are used. Output is deterministic 44.1 kHz mono PCM.
"""

from __future__ import annotations

import math
import random
import struct
import wave
import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "audio"
SAMPLE_RATE = 44_100


def band_noise(duration: float, seed: int, low_alpha: float, high_alpha: float) -> list[float]:
    rng = random.Random(seed)
    raw = [rng.uniform(-1.0, 1.0) for _ in range(round(duration * SAMPLE_RATE))]
    low: list[float] = []
    state = 0.0
    for value in raw:
        state += low_alpha * (value - state)
        low.append(state)
    bass = 0.0
    result: list[float] = []
    for value in low:
        bass += high_alpha * (value - bass)
        result.append(value - bass)
    return result


def burst(t: float, start: float, decay: float) -> float:
    return 0.0 if t < start else math.exp(-(t - start) * decay)


def choice_stamp() -> list[float]:
    duration = 0.105
    noise = band_noise(duration, 1907, 0.46, 0.075)
    samples: list[float] = []
    for i, grain in enumerate(noise):
        t = i / SAMPLE_RATE
        paper = grain * (0.68 * burst(t, 0.0, 82.0) + 0.20 * burst(t, 0.026, 105.0))
        body = math.sin(2.0 * math.pi * (132.0 * t - 170.0 * t * t)) * burst(t, 0.0, 58.0)
        samples.append(paper + body * 0.12)
    return normalize(samples, 0.14)


def modal_slide(opening: bool) -> list[float]:
    duration = 0.155
    noise = band_noise(duration, 2718 if opening else 3141, 0.26, 0.032)
    samples: list[float] = []
    for i, grain in enumerate(noise):
        t = i / SAMPLE_RATE
        sweep = math.sin(math.pi * min(1.0, t / duration)) ** 1.45
        if not opening:
            sweep = math.sin(math.pi * min(1.0, (duration - t) / duration)) ** 1.45
        start_tap = burst(t, 0.0 if opening else 0.102, 115.0)
        end_tap = burst(t, 0.105 if opening else 0.0, 125.0)
        body_start = 0.0 if opening else 0.100
        body = math.sin(2.0 * math.pi * 118.0 * max(0.0, t - body_start)) * burst(t, body_start, 72.0)
        samples.append(grain * (0.22 * sweep + 0.46 * start_tap + 0.18 * end_tap) + body * 0.045)
    return normalize(samples, 0.12)


def tab_snap() -> list[float]:
    duration = 0.075
    noise = band_noise(duration, 1618, 0.62, 0.115)
    samples: list[float] = []
    for i, grain in enumerate(noise):
        t = i / SAMPLE_RATE
        envelope = 0.72 * burst(t, 0.0, 155.0) + 0.28 * burst(t, 0.017, 190.0)
        body = math.sin(2.0 * math.pi * 176.0 * t) * burst(t, 0.0, 105.0)
        samples.append(grain * envelope + body * 0.035)
    return normalize(samples, 0.08)


def normalize(samples: list[float], target_peak: float) -> list[float]:
    peak = max((abs(value) for value in samples), default=1.0)
    gain = target_peak / max(peak, 1e-9)
    return [math.tanh(value * gain * 1.08) / math.tanh(1.08) for value in samples]


def write_wav(name: str, samples: list[float]) -> None:
    path = OUT / name
    with wave.open(str(path), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(SAMPLE_RATE)
        target.writeframes(pcm_bytes(samples))
    print(f"WROTE {path.relative_to(ROOT)} {len(samples) / SAMPLE_RATE:.3f}s")


def pcm_bytes(samples: list[float]) -> bytes:
    pcm = bytearray()
    for value in samples:
        pcm.extend(struct.pack("<h", round(max(-1.0, min(1.0, value)) * 32767.0)))
    return bytes(pcm)


def check_wav(name: str, samples: list[float]) -> None:
    path = OUT / name
    with wave.open(str(path), "rb") as source:
        if source.getnchannels() != 1 or source.getsampwidth() != 2 or source.getframerate() != SAMPLE_RATE:
            raise SystemExit(f"UI_SFX_CHECK_FAIL format mismatch: {name}")
        actual = source.readframes(source.getnframes())
    if actual != pcm_bytes(samples):
        raise SystemExit(f"UI_SFX_CHECK_FAIL generated source drift: {name}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    assets = {
        "sfx_choice_made.wav": choice_stamp(),
        "sfx_open_modal.wav": modal_slide(True),
        "sfx_close.wav": modal_slide(False),
        "sfx_tab_open.wav": tab_snap(),
    }
    for name, samples in assets.items():
        if args.check:
            check_wav(name, samples)
        else:
            write_wav(name, samples)
    if args.check:
        print("UI_SFX_CHECK_OK assets=4 source=deterministic")


if __name__ == "__main__":
    main()
