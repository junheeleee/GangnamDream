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


def _add_sweep(buf: list[list[float]], start: float, start_freq: float, end_freq: float,
               seconds: float, amp: float, pos: float = 0.0, kind: str = "sine") -> None:
    start_i = int(start * SR)
    total = int(seconds * SR)
    if start_i >= len(buf):
        return
    phase = 0.0
    for j in range(total):
        i = start_i + j
        if i >= len(buf):
            break
        x = j / max(1, total - 1)
        env = min(1.0, x / 0.06) * min(1.0, (1.0 - x) / 0.12)
        freq = start_freq + (end_freq - start_freq) * x
        phase += 2.0 * math.pi * freq / SR
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


def ambience_seoul_street() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.030, "dark", -0.05, 0.08)
    _add_tone(buf, 0.0, 66.0, 6.0, 0.018, 0.0, "sine")
    _add_tone(buf, 0.0, 132.0, 6.0, 0.006, 0.18, "sine")
    for t in [0.65, 1.45, 2.9, 4.25, 5.15]:
        _add_tone(buf, t, RNG.uniform(380.0, 620.0), 0.14, 0.010, RNG.uniform(-0.55, 0.55), "tri")
    for t in [1.9, 3.6]:
        _add_sweep(buf, t, 260.0, 210.0, 0.42, 0.020, RNG.uniform(-0.35, 0.35), "sine")
    return buf


def ambience_subway() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.042, "dark", -0.08, 0.18)
    _add_tone(buf, 0.0, 72.0, 6.0, 0.030, 0.0, "sine")
    _add_tone(buf, 0.0, 144.0, 6.0, 0.012, 0.12, "sine")
    for t in [0.7, 2.1, 3.4, 5.0]:
        _add_tone(buf, t, 680.0, 0.18, 0.018, RNG.uniform(-0.45, 0.45), "tri")
    return buf


def ambience_racetrack() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.052, "dark", 0.0, 0.30)
    _add_tone(buf, 0.0, 82.0, 6.0, 0.020, -0.10, "sine")
    for t in [0.5, 1.15, 1.9, 2.8, 3.6, 4.45, 5.2]:
        _add_tick(buf, t, 0.060, RNG.uniform(-0.65, 0.65))
    for t in [1.4, 3.05, 4.75]:
        _add_tone(buf, t, 210.0, 0.42, 0.024, RNG.uniform(-0.35, 0.35), "tri")
    return buf


def ambience_cafe() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.024, "dark", -0.15, 0.10)
    _add_tone(buf, 0.0, 104.0, 6.0, 0.012, 0.0, "sine")
    for t in [0.6, 1.9, 3.2, 4.8]:
        _add_tick(buf, t, 0.024, RNG.uniform(-0.45, 0.45))
    for t in [2.4, 5.1]:
        _add_tone(buf, t, 520.0, 0.22, 0.010, 0.30, "sine")
    return buf


def ambience_pc_bang() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.038, "bright", -0.10, 0.22)
    _add_tone(buf, 0.0, 156.0, 6.0, 0.018, -0.20, "sine")
    for t in [0.25, 0.33, 1.1, 1.28, 2.7, 3.9, 4.02, 5.3]:
        _add_tick(buf, t, 0.030, RNG.uniform(-0.55, 0.55))
    for t in [1.8, 4.6]:
        _add_tone(buf, t, 880.0, 0.08, 0.014, 0.45, "square")
    return buf


def ambience_gym() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.030, "dark", 0.0, 0.16)
    _add_tone(buf, 0.0, 118.0, 6.0, 0.018, 0.0, "sine")
    for t in [0.45, 1.35, 2.25, 3.15, 4.05, 4.95]:
        _add_tone(buf, t, 74.0, 0.12, 0.045, RNG.uniform(-0.3, 0.3), "sine")
    for t in [0.95, 2.95, 5.15]:
        _add_tick(buf, t, 0.026, RNG.uniform(-0.45, 0.45))
    return buf


def ambience_convenience() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.026, "bright", 0.15, 0.08)
    _add_tone(buf, 0.0, 60.0, 6.0, 0.024, -0.12, "sine")
    _add_tone(buf, 0.0, 120.0, 6.0, 0.012, 0.10, "sine")
    for t in [1.0, 3.4, 5.2]:
        _add_chord(buf, t, ["E5", "B5"], 0.16, 0.018, RNG.uniform(-0.35, 0.35))
    return buf


def ambience_hagwon_street() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.040, "bright", -0.12, 0.10)
    _add_noise(buf, 0.026, "dark", 0.18, 0.06)
    _add_tone(buf, 0.0, 86.0, 6.0, 0.016, 0.0, "sine")
    for t in [0.65, 1.55, 2.8, 4.15, 5.25]:
        _add_tick(buf, t, 0.026, RNG.uniform(-0.55, 0.55))
    for t in [1.15, 3.65]:
        _add_chord(buf, t, ["G5", "D6"], 0.14, 0.014, RNG.uniform(-0.35, 0.35))
    return buf


def ambience_school_hall() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.022, "dark", 0.0, 0.08)
    _add_tone(buf, 0.0, 118.0, 6.0, 0.017, -0.08, "sine")
    _add_tone(buf, 0.0, 236.0, 6.0, 0.006, 0.12, "sine")
    for t in [0.9, 2.2, 3.85, 5.1]:
        _add_tick(buf, t, 0.018, RNG.uniform(-0.5, 0.5))
    for t in [1.7, 4.45]:
        _add_tone(buf, t, 440.0, 0.22, 0.008, RNG.uniform(-0.25, 0.25), "tri")
    return buf


def ambience_public_office() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.024, "dark", 0.0, 0.10)
    _add_tone(buf, 0.0, 112.0, 6.0, 0.016, -0.05, "sine")
    for t in [0.45, 1.9, 3.15, 4.7]:
        _add_tick(buf, t, 0.024, RNG.uniform(-0.45, 0.45))
    for t in [1.25, 4.1]:
        _add_chord(buf, t, ["C5", "G5"], 0.18, 0.012, 0.20)
    return buf


def ambience_jjimjilbang() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.028, "dark", -0.08, 0.05)
    _add_tone(buf, 0.0, 64.0, 6.0, 0.022, 0.0, "sine")
    _add_tone(buf, 0.0, 128.0, 6.0, 0.008, 0.15, "sine")
    for t in [1.0, 2.75, 4.6]:
        _add_tick(buf, t, 0.018, RNG.uniform(-0.35, 0.35))
    for t in [2.15, 5.05]:
        _add_tone(buf, t, 260.0, 0.35, 0.010, -0.20, "sine")
    return buf


def ambience_cherry_blossom() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.024, "bright", -0.20, 0.05)
    _add_noise(buf, 0.020, "dark", 0.22, 0.04)
    _add_tone(buf, 0.0, 78.0, 6.0, 0.010, 0.0, "sine")
    for t in [0.55, 1.7, 2.95, 4.15, 5.35]:
        _add_tone(buf, t, RNG.uniform(620.0, 920.0), 0.16, 0.009, RNG.uniform(-0.55, 0.55), "tri")
    return buf


def ambience_saju_cafe() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.021, "dark", -0.08, 0.08)
    _add_tone(buf, 0.0, 96.0, 6.0, 0.013, 0.0, "sine")
    for t in [0.9, 2.6, 4.55]:
        _add_tick(buf, t, 0.018, RNG.uniform(-0.35, 0.35))
    for t in [1.35, 3.75]:
        _add_chord(buf, t, ["Eb5", "Bb5"], 0.22, 0.010, RNG.uniform(-0.25, 0.25))
    return buf


def ambience_military_gate() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.030, "dark", 0.0, 0.07)
    _add_tone(buf, 0.0, 70.0, 6.0, 0.020, -0.10, "sine")
    for t in [0.75, 2.25, 3.9, 5.15]:
        _add_tone(buf, t, 190.0, 0.18, 0.020, RNG.uniform(-0.35, 0.35), "tri")
    for t in [1.65, 4.7]:
        _add_tone(buf, t, 520.0, 0.26, 0.010, 0.25, "sine")
    return buf


def ambience_company_dinner() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.040, "dark", 0.0, 0.12)
    _add_noise(buf, 0.018, "bright", -0.18, 0.0)
    _add_tone(buf, 0.0, 96.0, 6.0, 0.014, -0.08, "sine")
    for t in [0.35, 1.15, 1.9, 2.55, 3.45, 4.15, 5.05]:
        _add_tick(buf, t, 0.036, RNG.uniform(-0.55, 0.55))
    for t in [0.8, 2.7, 4.65]:
        _add_noise(buf[int(t * SR): min(len(buf), int((t + 0.45) * SR))], 0.026, "bright", 0.15, 0.0)
    return buf


def ambience_heatwave_city() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.026, "bright", -0.05, 0.05)
    _add_tone(buf, 0.0, 62.0, 6.0, 0.018, 0.0, "sine")
    _add_tone(buf, 0.0, 124.0, 6.0, 0.008, 0.16, "sine")
    _add_sweep(buf, 0.4, 420.0, 520.0, 1.2, 0.010, 0.25, "sine")
    _add_sweep(buf, 2.5, 470.0, 390.0, 1.4, 0.009, -0.25, "sine")
    _add_sweep(buf, 4.6, 440.0, 505.0, 0.9, 0.008, 0.10, "sine")
    for t in [1.55, 3.85, 5.35]:
        _add_tick(buf, t, 0.020, RNG.uniform(-0.45, 0.45))
    return buf


def ambience_fine_dust_city() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.022, "dark", -0.05, 0.04)
    _add_noise(buf, 0.014, "bright", 0.12, 0.0)
    _add_tone(buf, 0.0, 58.0, 6.0, 0.017, 0.0, "sine")
    _add_tone(buf, 0.0, 116.0, 6.0, 0.006, 0.18, "sine")
    for t in [0.9, 2.8, 4.9]:
        _add_sweep(buf, t, 210.0, 170.0, 0.45, 0.014, RNG.uniform(-0.35, 0.35), "sine")
    for t in [1.7, 3.55]:
        _add_tick(buf, t, 0.014, RNG.uniform(-0.45, 0.45))
    return buf


def ambience_highway_traffic() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.034, "dark", 0.0, 0.10)
    _add_tone(buf, 0.0, 54.0, 6.0, 0.026, -0.10, "sine")
    _add_tone(buf, 0.0, 108.0, 6.0, 0.010, 0.14, "sine")
    for t in [0.55, 1.35, 2.15, 3.05, 4.1, 5.2]:
        _add_sweep(buf, t, RNG.uniform(150.0, 230.0), RNG.uniform(120.0, 180.0), 0.38, 0.018, RNG.uniform(-0.6, 0.6), "sine")
    for t in [1.0, 2.7, 4.75]:
        _add_tick(buf, t, 0.020, RNG.uniform(-0.45, 0.45))
    return buf


def ambience_open_chat_room() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.024, "dark", -0.05, 0.08)
    _add_tone(buf, 0.0, 64.0, 6.0, 0.016, 0.0, "sine")
    _add_tone(buf, 0.0, 128.0, 6.0, 0.006, 0.16, "sine")
    for t in [0.8, 2.35, 4.45]:
        _add_tone(buf, t, 92.0, 0.18, 0.020, -0.10, "sine")
        _add_tone(buf, t + 0.06, 184.0, 0.12, 0.008, 0.10, "sine")
    for t in [1.55, 3.25, 5.15]:
        _add_tick(buf, t, 0.014, RNG.uniform(-0.35, 0.35))
    return buf


def ambience_library_room() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.018, "dark", 0.0, 0.06)
    _add_tone(buf, 0.0, 102.0, 6.0, 0.012, -0.08, "sine")
    _add_tone(buf, 0.0, 204.0, 6.0, 0.004, 0.14, "sine")
    for t in [0.75, 2.2, 3.9, 5.3]:
        _add_tick(buf, t, 0.012, RNG.uniform(-0.45, 0.45))
    for t in [1.35, 4.65]:
        _add_tone(buf, t, 420.0, 0.20, 0.007, RNG.uniform(-0.25, 0.25), "tri")
    return buf


def sfx_civil_defense_siren() -> list[list[float]]:
    buf = _empty(2.8)
    _add_noise(buf, 0.008, "dark", 0.0, 0.0)
    _add_sweep(buf, 0.00, 520.0, 880.0, 0.68, 0.18, -0.05, "tri")
    _add_sweep(buf, 0.58, 880.0, 560.0, 0.68, 0.17, 0.06, "tri")
    _add_sweep(buf, 1.20, 540.0, 910.0, 0.70, 0.18, -0.02, "tri")
    _add_sweep(buf, 1.82, 910.0, 600.0, 0.72, 0.16, 0.03, "tri")
    return buf


def sfx_monsoon_rain() -> list[list[float]]:
    buf = _empty(2.8)
    _add_noise(buf, 0.090, "bright", -0.05, 0.0)
    _add_noise(buf, 0.045, "dark", 0.10, 0.08)
    _add_tone(buf, 0.2, 74.0, 1.6, 0.020, 0.0, "sine")
    _add_tone(buf, 1.5, 68.0, 1.0, 0.018, -0.12, "sine")
    for t in [0.35, 0.9, 1.35, 2.2]:
        _add_tick(buf, t, 0.026, RNG.uniform(-0.6, 0.6))
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
        "amb_subway_platform.wav": ambience_subway(),
        "amb_racetrack_crowd.wav": ambience_racetrack(),
        "amb_cafe_room.wav": ambience_cafe(),
        "amb_pc_bang.wav": ambience_pc_bang(),
        "amb_gym_room.wav": ambience_gym(),
        "amb_convenience_store.wav": ambience_convenience(),
        "amb_hagwon_street.wav": ambience_hagwon_street(),
        "amb_school_hall.wav": ambience_school_hall(),
        "amb_public_office.wav": ambience_public_office(),
        "amb_jjimjilbang.wav": ambience_jjimjilbang(),
        "amb_cherry_blossom.wav": ambience_cherry_blossom(),
        "amb_saju_cafe.wav": ambience_saju_cafe(),
        "amb_military_gate.wav": ambience_military_gate(),
        "amb_seoul_street.wav": ambience_seoul_street(),
        "amb_company_dinner.wav": ambience_company_dinner(),
        "amb_heatwave_city.wav": ambience_heatwave_city(),
        "amb_fine_dust_city.wav": ambience_fine_dust_city(),
        "amb_highway_traffic.wav": ambience_highway_traffic(),
        "amb_open_chat_room.wav": ambience_open_chat_room(),
        "amb_library_room.wav": ambience_library_room(),
        "sfx_civil_defense_siren.wav": sfx_civil_defense_siren(),
        "sfx_monsoon_rain.wav": sfx_monsoon_rain(),
    }
    for name, buf in targets.items():
        _write(AUDIO_DIR / name, buf)
    print("AUDIO_P1_ASSETS_GENERATED", len(targets))


if __name__ == "__main__":
    main()
