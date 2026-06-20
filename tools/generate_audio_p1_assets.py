#!/usr/bin/env python3
"""Generate small audio P1 ambience loops and ending stingers.

The main BGM generator intentionally rewrites every BGM/SFX file. This script is
scoped to the ambience/stinger assets added during the player-facing polish pass.
"""

from __future__ import annotations

import math
import random
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AUDIO_DIR = ROOT / "assets" / "audio"
SR = 22050
RNG = random.Random(20260619)


def _empty(seconds: float) -> list[list[float]]:
    return [[0.0, 0.0] for _ in range(int(SR * seconds))]


def _clamp(v: float, lo: float = -1.0, hi: float = 1.0) -> float:
    return max(lo, min(hi, v))


def _note(name: str) -> float:
    names = {
        "C": -9, "C#": -8, "Db": -8, "D": -7, "D#": -6, "Eb": -6,
        "E": -5, "F": -4, "F#": -3, "Gb": -3, "G": -2, "G#": -1,
        "Ab": -1, "A": 0, "A#": 1, "Bb": 1, "B": 2,
    }
    pitch = name[:-1]
    octave = int(name[-1])
    semitone = names[pitch] + (octave - 4) * 12
    return 440.0 * (2.0 ** (semitone / 12.0))


def _pan(sample: float, pos: float) -> tuple[float, float]:
    pos = _clamp(pos)
    left = math.cos((pos + 1.0) * math.pi / 4.0)
    right = math.sin((pos + 1.0) * math.pi / 4.0)
    return sample * left, sample * right


def _add_tone(buf: list[list[float]], start: float, freq: float, seconds: float,
              amp: float, pos: float = 0.0, kind: str = "sine") -> None:
    start_i = int(start * SR)
    total = int(seconds * SR)
    if start_i >= len(buf):
        return
    for j in range(total):
        i = start_i + j
        if i >= len(buf):
            break
        t = j / SR
        x = j / max(1, total - 1)
        env = min(1.0, x / 0.04) * min(1.0, (1.0 - x) / 0.10)
        phase = 2.0 * math.pi * freq * t
        if kind == "tri":
            s = (2.0 / math.pi) * math.asin(math.sin(phase))
        elif kind == "square":
            s = math.tanh(2.0 * math.sin(phase))
        else:
            s = math.sin(phase)
        l, r = _pan(s * amp * env, pos)
        buf[i][0] += l
        buf[i][1] += r


def _add_chord(buf: list[list[float]], start: float, notes: list[str],
               seconds: float, amp: float, pos: float = 0.0) -> None:
    for idx, note in enumerate(notes):
        _add_tone(buf, start + idx * 0.065, _note(note), seconds, amp, pos + (idx - 1) * 0.14, "tri")


def _add_noise(buf: list[list[float]], amp: float, color: str = "dark",
               pos: float = 0.0, pulse_hz: float = 0.0) -> None:
    lp = 0.0
    for i in range(len(buf)):
        raw = RNG.uniform(-1.0, 1.0)
        if color == "bright":
            s = raw - lp * 0.45
            lp = lp * 0.93 + raw * 0.07
        else:
            lp = lp * 0.985 + raw * 0.015
            s = lp
        if pulse_hz > 0.0:
            s *= 0.70 + 0.30 * math.sin(2.0 * math.pi * pulse_hz * i / SR)
        l, r = _pan(s * amp, pos)
        buf[i][0] += l
        buf[i][1] += r


def _add_tick(buf: list[list[float]], t: float, amp: float, pos: float) -> None:
    _add_tone(buf, t, RNG.uniform(900.0, 1800.0), 0.035, amp, pos, "tri")


def _soft_limit(buf: list[list[float]]) -> None:
    peak = max(max(abs(l), abs(r)) for l, r in buf) if buf else 0.0
    gain = 0.92 / peak if peak > 0.92 else 1.0
    for i, (l, r) in enumerate(buf):
        buf[i][0] = math.tanh(l * gain * 1.15)
        buf[i][1] = math.tanh(r * gain * 1.15)


def _fade_edges(buf: list[list[float]], fade_seconds: float = 0.12) -> None:
    n = min(len(buf) // 2, int(SR * fade_seconds))
    if n <= 0:
        return
    for i in range(n):
        x = i / n
        buf[i][0] *= x
        buf[i][1] *= x
        y = 1.0 - x
        buf[-1 - i][0] *= y
        buf[-1 - i][1] *= y


def _write(path: Path, buf: list[list[float]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    _soft_limit(buf)
    _fade_edges(buf)
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        frames = bytearray()
        for l, r in buf:
            for sample in (l, r):
                frames += int(_clamp(sample) * 32767.0).to_bytes(2, "little", signed=True)
        wf.writeframes(frames)


def ambience_goshiwon() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.030, "dark", -0.20, 0.08)
    _add_tone(buf, 0.0, 58.0, 6.0, 0.030, 0.0, "sine")
    _add_tone(buf, 0.0, 116.0, 6.0, 0.014, 0.12, "sine")
    for t in [0.9, 2.45, 4.8]:
        _add_tick(buf, t, 0.040, RNG.uniform(-0.6, 0.4))
    return buf


def ambience_rain() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.055, "bright", -0.10, 0.0)
    _add_noise(buf, 0.030, "dark", 0.20, 0.06)
    _add_tone(buf, 0.0, 92.0, 6.0, 0.018, 0.0, "sine")
    for t in [1.2, 3.6, 5.0]:
        _add_tone(buf, t, 330.0, 0.45, 0.018, 0.35, "sine")
    return buf


def ambience_hangang() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.032, "dark", -0.35, 0.18)
    _add_noise(buf, 0.018, "bright", 0.40, 0.0)
    _add_tone(buf, 0.0, 73.0, 6.0, 0.014, 0.0, "sine")
    for t in [0.4, 2.8, 4.2]:
        _add_tone(buf, t, 520.0, 0.35, 0.012, 0.25, "tri")
    return buf


def ambience_office() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.026, "dark", 0.0, 0.12)
    _add_tone(buf, 0.0, 120.0, 6.0, 0.018, -0.1, "sine")
    for t in [0.35, 0.42, 1.8, 2.05, 3.7, 4.6, 4.72]:
        _add_tick(buf, t, 0.028, RNG.uniform(-0.55, 0.55))
    return buf


def ambience_casino() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.045, "dark", 0.0, 0.10)
    _add_tone(buf, 0.0, 98.0, 6.0, 0.020, 0.0, "sine")
    for t in [0.25, 0.9, 1.55, 2.3, 3.05, 4.1, 5.15]:
        _add_chord(buf, t, ["C5", "E5"], 0.18, 0.025, RNG.uniform(-0.6, 0.6))
    for t in [1.15, 3.35, 4.55]:
        _add_tick(buf, t, 0.040, RNG.uniform(-0.35, 0.35))
    return buf


def stinger_good() -> list[list[float]]:
    buf = _empty(1.4)
    _add_chord(buf, 0.02, ["C4", "G4", "E5", "G5"], 1.0, 0.16, 0.0)
    _add_tone(buf, 0.10, _note("C3"), 0.65, 0.09, 0.0, "sine")
    return buf


def stinger_bad() -> list[list[float]]:
    buf = _empty(1.6)
    _add_chord(buf, 0.02, ["C4", "G3", "Eb3"], 1.2, 0.15, -0.05)
    _add_tone(buf, 0.0, 61.0, 1.5, 0.12, 0.0, "sine")
    _add_noise(buf, 0.010, "dark", 0.0, 0.0)
    return buf


def stinger_legend() -> list[list[float]]:
    buf = _empty(2.0)
    _add_chord(buf, 0.00, ["C4", "E4", "G4", "C5", "E5"], 1.4, 0.15, 0.0)
    _add_chord(buf, 0.55, ["G4", "B4", "D5", "G5"], 1.1, 0.12, 0.0)
    _add_tone(buf, 0.04, _note("C3"), 1.0, 0.10, 0.0, "sine")
    _add_tick(buf, 1.25, 0.080, -0.15)
    _add_tick(buf, 1.37, 0.070, 0.20)
    return buf


def main() -> None:
    targets = {
        "amb_goshiwon_room.wav": ambience_goshiwon(),
        "amb_seoul_rain.wav": ambience_rain(),
        "amb_hangang_riverside.wav": ambience_hangang(),
        "amb_office_room.wav": ambience_office(),
        "amb_casino_floor.wav": ambience_casino(),
        "sfx_ending_stinger_good.wav": stinger_good(),
        "sfx_ending_stinger_bad.wav": stinger_bad(),
        "sfx_ending_stinger_legend.wav": stinger_legend(),
    }
    for name, buf in targets.items():
        _write(AUDIO_DIR / name, buf)
    print("AUDIO_P1_ASSETS_GENERATED", len(targets))


if __name__ == "__main__":
    main()
