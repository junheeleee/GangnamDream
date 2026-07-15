#!/usr/bin/env python3
"""Generate small audio P1 ambience loops and ending stingers.

The main BGM generator intentionally rewrites every BGM/SFX file. This script is
scoped to the ambience/stinger assets added during the player-facing polish pass.
"""

from __future__ import annotations

import math
import random
import shutil
import subprocess
import sys
import tempfile
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


def _add_noise_burst(buf: list[list[float]], start: float, seconds: float,
                     amp: float, pos: float = 0.0, color: str = "bright") -> None:
    start_i = int(start * SR)
    total = int(seconds * SR)
    low = 0.0
    for j in range(total):
        i = start_i + j
        if i >= len(buf):
            break
        x = j / max(1, total - 1)
        attack = min(1.0, x / 0.025)
        release = max(0.0, 1.0 - x) ** 2.4
        raw = RNG.uniform(-1.0, 1.0)
        low = low * 0.90 + raw * 0.10
        sample = raw - low * 0.58 if color == "bright" else low
        l, r = _pan(sample * amp * attack * release, pos)
        buf[i][0] += l
        buf[i][1] += r


def _add_instrument_note(buf: list[list[float]], start: float, note: str,
                         seconds: float, amp: float, pos: float, voice: str) -> None:
    freq = _note(note)
    if voice == "organ":
        harmonics = [(1.0, 0.60, "sine"), (2.0, 0.20, "sine"), (3.0, 0.08, "tri")]
    elif voice == "piano":
        harmonics = [(1.0, 0.62, "tri"), (2.0, 0.16, "sine"), (3.0, 0.05, "sine")]
    elif voice == "bell":
        harmonics = [(1.0, 0.48, "sine"), (2.01, 0.17, "sine"), (3.98, 0.06, "sine")]
    elif voice == "cello":
        harmonics = [(1.0, 0.68, "tri"), (2.0, 0.12, "sine"), (3.0, 0.04, "sine")]
    else:
        harmonics = [(1.0, 0.62, "sine"), (2.0, 0.10, "sine")]
    for multiplier, weight, kind in harmonics:
        _add_tone(buf, start, freq * multiplier, seconds, amp * weight, pos, kind)
    # Sparse reflections create room depth without baking a loud reverb tail.
    if voice in {"organ", "piano", "bell"}:
        for delay, gain, drift in [(0.105, 0.14, -0.08), (0.215, 0.08, 0.09)]:
            _add_tone(buf, start + delay, freq, max(0.08, seconds - delay),
                      amp * gain, _clamp(pos + drift), "sine")


def _add_scene_chord(buf: list[list[float]], start: float, notes: list[str],
                     seconds: float, amp: float, voice: str = "organ") -> None:
    spread = max(1, len(notes) - 1)
    for index, note in enumerate(notes):
        pos = -0.35 + 0.70 * index / spread
        _add_instrument_note(buf, start, note, seconds, amp, pos, voice)


def _add_room_murmur(buf: list[list[float]], start: float, seconds: float,
                     amp: float, pos: float) -> None:
    base = RNG.uniform(115.0, 205.0)
    _add_sweep(buf, start, base, base * RNG.uniform(0.88, 1.12), seconds,
               amp, pos, "sine")
    _add_sweep(buf, start + 0.03, base * 2.35, base * 2.10, seconds * 0.82,
               amp * 0.30, _clamp(pos + 0.05), "sine")


def _add_indistinct_phrase(buf: list[list[float]], start: float, seconds: float,
                           amp: float, pos: float, pitch_band: tuple[float, float]) -> None:
    """Add distant speech-shaped movement without intelligible words or musical notes."""
    syllables = RNG.randint(2, 5)
    cursor = start
    remaining = seconds
    for syllable in range(syllables):
        slots_left = syllables - syllable
        duration = min(remaining / slots_left, RNG.uniform(0.10, 0.24))
        base = RNG.uniform(*pitch_band)
        drift = RNG.uniform(0.84, 1.18)
        local_pos = _clamp(pos + RNG.uniform(-0.06, 0.06))
        _add_sweep(buf, cursor, base, base * drift, duration,
                   amp * RNG.uniform(0.55, 0.92), local_pos, "sine")
        _add_sweep(buf, cursor + 0.012, base * 2.15, base * 2.42 * drift,
                   duration * 0.78, amp * 0.16, local_pos, "sine")
        _add_noise_burst(buf, cursor, min(0.055, duration * 0.35),
                         amp * 0.10, local_pos, "dark")
        pause = RNG.uniform(0.035, 0.11)
        cursor += duration + pause
        remaining = max(0.04, start + seconds - cursor)


def _human_layer(profile: str) -> list[list[float]]:
    """Low-level diegetic human presence separated from mechanical room tone."""
    duration = 10.0
    buf = _empty(duration)
    profiles = {
        "thin_wall": (9, (0.30, 0.75), (95.0, 155.0), 0.0065),
        "street": (24, (0.22, 0.72), (115.0, 225.0), 0.0065),
        "public_interior": (18, (0.28, 0.82), (110.0, 205.0), 0.0058),
        "cafe": (20, (0.34, 0.95), (120.0, 215.0), 0.0062),
        "casino": (28, (0.18, 0.62), (120.0, 230.0), 0.0068),
        "racetrack": (30, (0.16, 0.55), (125.0, 245.0), 0.0072),
        "wedding": (16, (0.35, 0.92), (115.0, 220.0), 0.0057),
        "transit": (12, (0.22, 0.65), (105.0, 190.0), 0.0048),
        "leisure": (22, (0.20, 0.70), (120.0, 235.0), 0.0060),
    }
    count, length_range, pitch_band, amp = profiles[profile]
    _add_noise(buf, amp * 0.18, "dark", 0.0, 0.025)
    for _ in range(count):
        phrase_seconds = RNG.uniform(*length_range)
        start = RNG.uniform(0.12, duration - phrase_seconds - 0.12)
        pos = RNG.uniform(-0.88, 0.88)
        _add_indistinct_phrase(buf, start, phrase_seconds,
                               amp * RNG.uniform(0.65, 1.15), pos, pitch_band)
    step_count = 5 if profile in {"thin_wall", "transit", "public_interior"} else 9
    for _ in range(step_count):
        start = RNG.uniform(0.2, duration - 0.25)
        pos = RNG.uniform(-0.85, 0.85)
        _add_sweep(buf, start, RNG.uniform(105.0, 155.0), RNG.uniform(58.0, 92.0),
                   RNG.uniform(0.10, 0.18), amp * 1.25, pos, "sine")
    if profile == "racetrack":
        for start in (2.1, 5.4, 8.2):
            for voice in range(8):
                pos = RNG.uniform(-0.9, 0.9)
                _add_sweep(buf, start + RNG.uniform(0.0, 0.18), RNG.uniform(140.0, 220.0),
                           RNG.uniform(210.0, 330.0), RNG.uniform(0.35, 0.75),
                           amp * 0.85, pos, "sine")
    return buf


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


def _write(path: Path, buf: list[list[float]], fade_edges: bool = True) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    _soft_limit(buf)
    if fade_edges:
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


def _ffmpeg() -> str:
    try:
        import imageio_ffmpeg  # type: ignore

        candidate = imageio_ffmpeg.get_ffmpeg_exe()
        if candidate and Path(candidate).is_file():
            return str(candidate)
    except Exception:
        pass
    candidates = [
        shutil.which("ffmpeg"),
        "/Applications/CapCut.app/Contents/Resources/ffmpeg",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return str(candidate)
    raise RuntimeError("ffmpeg not found; install ffmpeg or imageio-ffmpeg")


def _write_ogg(path: Path, buf: list[list[float]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="gangnam-scene-audio-") as tmp:
        wav_path = Path(tmp) / (path.stem + ".wav")
        _write(wav_path, buf, False)
        subprocess.run(
            [
                _ffmpeg(), "-y", "-loglevel", "error", "-i", str(wav_path),
                "-c:a", "libvorbis", "-q:a", "5", str(path),
            ],
            check=True,
        )


def ambience_goshiwon() -> list[list[float]]:
    buf = _empty(6.0)
    _add_noise(buf, 0.030, "dark", -0.20, 0.08)
    _add_tone(buf, 0.0, 58.0, 6.0, 0.030, 0.0, "sine")
    _add_tone(buf, 0.0, 116.0, 6.0, 0.014, 0.12, "sine")
    for t in [0.9, 2.45, 4.8]:
        _add_tick(buf, t, 0.040, RNG.uniform(-0.6, 0.4))
    # Thin-wall life: muffled corridor steps and a restrained cough next door.
    for t, pos in [(1.55, -0.62), (1.88, -0.48), (4.05, 0.55), (4.38, 0.42)]:
        _add_sweep(buf, t, 105.0, 68.0, 0.18, 0.026, pos, "sine")
    _add_sweep(buf, 3.05, 210.0, 112.0, 0.20, 0.018, 0.68, "tri")
    _add_sweep(buf, 3.31, 185.0, 98.0, 0.16, 0.014, 0.68, "tri")
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


def ambience_oneroom_room() -> list[list[float]]:
    """A private room: refrigerator compressor, relay clicks, no shared-wall traffic."""
    buf = _empty(6.0)
    _add_noise(buf, 0.014, "dark", 0.0, 0.04)
    _add_tone(buf, 0.0, 49.5, 6.0, 0.026, -0.08, "sine")
    _add_tone(buf, 0.0, 99.0, 6.0, 0.010, 0.10, "sine")
    _add_tick(buf, 0.55, 0.013, -0.25)
    _add_tick(buf, 5.25, 0.011, -0.20)
    _add_sweep(buf, 2.7, 86.0, 72.0, 0.28, 0.010, 0.22, "sine")
    return buf


def ambience_apartment_room() -> list[list[float]]:
    """An insulated apartment: deliberate near-silence with distant building systems."""
    buf = _empty(6.0)
    _add_noise(buf, 0.007, "dark", 0.0, 0.025)
    _add_tone(buf, 0.0, 42.0, 6.0, 0.009, -0.05, "sine")
    _add_sweep(buf, 1.65, 132.0, 118.0, 0.42, 0.006, 0.55, "sine")
    _add_tone(buf, 4.35, 660.0, 0.12, 0.004, -0.48, "tri")
    return buf


def ambience_summer_night() -> list[list[float]]:
    """A low seasonal layer: distant cicadas, kept below the room tone."""
    buf = _empty(6.0)
    _add_noise(buf, 0.006, "bright", 0.0, 0.0)
    for start, pos in [(0.30, -0.55), (1.15, 0.48), (2.15, -0.18), (3.25, 0.58), (4.45, -0.42), (5.15, 0.20)]:
        for pulse in range(4):
            _add_sweep(buf, start + pulse * 0.075, 3450.0, 2850.0, 0.055, 0.010, pos, "tri")
    return buf


def ambience_winter_wind() -> list[list[float]]:
    """A low seasonal layer: wind pressure outside a closed Seoul room."""
    buf = _empty(6.0)
    _add_noise(buf, 0.012, "dark", -0.12, 0.035)
    _add_sweep(buf, 0.25, 118.0, 82.0, 1.15, 0.010, -0.38, "sine")
    _add_sweep(buf, 2.35, 92.0, 128.0, 1.35, 0.009, 0.34, "sine")
    _add_sweep(buf, 4.55, 110.0, 76.0, 0.95, 0.008, -0.08, "sine")
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


def ambience_wedding_hall() -> list[list[float]]:
    buf = _empty(10.0)
    _add_noise(buf, 0.010, "dark", 0.0, 0.03)
    _add_tone(buf, 0.0, 48.0, 10.0, 0.012, -0.08, "sine")
    _add_tone(buf, 0.0, 96.0, 10.0, 0.005, 0.14, "sine")
    for start, seconds, amp, pos in [
        (0.65, 0.48, 0.012, -0.65), (1.45, 0.62, 0.010, 0.52),
        (2.85, 0.42, 0.009, -0.22), (4.05, 0.70, 0.011, 0.66),
        (5.55, 0.55, 0.010, -0.52), (7.05, 0.44, 0.009, 0.28),
        (8.45, 0.66, 0.010, -0.10),
    ]:
        _add_room_murmur(buf, start, seconds, amp, pos)
    for t, pos in [(1.12, -0.48), (3.48, 0.55), (6.35, -0.18), (8.92, 0.44)]:
        _add_noise_burst(buf, t, 0.055, 0.020, pos, "dark")
    return buf


def ambience_hospital_room() -> list[list[float]]:
    buf = _empty(8.0)
    _add_noise(buf, 0.010, "bright", 0.0, 0.02)
    _add_tone(buf, 0.0, 59.5, 8.0, 0.012, -0.12, "sine")
    _add_tone(buf, 0.0, 119.0, 8.0, 0.004, 0.18, "sine")
    for t in [1.05, 3.45, 5.85]:
        _add_tone(buf, t, 1045.0, 0.075, 0.015, 0.45, "sine")
    _add_sweep(buf, 2.1, 92.0, 74.0, 0.70, 0.008, -0.55, "sine")
    _add_sweep(buf, 6.55, 78.0, 96.0, 0.55, 0.007, 0.52, "sine")
    return buf


def ambience_seaside() -> list[list[float]]:
    buf = _empty(10.0)
    _add_noise(buf, 0.012, "bright", -0.15, 0.0)
    for start, length, pos in [(0.0, 2.8, -0.30), (2.6, 3.2, 0.25), (5.6, 3.0, -0.05), (8.1, 1.9, 0.35)]:
        total = int(length * SR)
        base_i = int(start * SR)
        low = 0.0
        for j in range(total):
            i = base_i + j
            if i >= len(buf):
                break
            x = j / max(1, total - 1)
            swell = math.sin(math.pi * x) ** 1.7
            raw = RNG.uniform(-1.0, 1.0)
            low = low * 0.93 + raw * 0.07
            foam = (raw - low * 0.35) * 0.045 * swell
            l, r = _pan(foam, pos)
            buf[i][0] += l
            buf[i][1] += r
    _add_sweep(buf, 3.9, 980.0, 720.0, 0.38, 0.006, -0.65, "sine")
    _add_sweep(buf, 7.4, 850.0, 1120.0, 0.32, 0.005, 0.58, "sine")
    return buf


def ambience_amusement_park() -> list[list[float]]:
    buf = _empty(9.0)
    _add_noise(buf, 0.018, "dark", 0.0, 0.08)
    _add_tone(buf, 0.0, 72.0, 9.0, 0.010, -0.08, "sine")
    for start, seconds, amp, pos in [
        (0.45, 0.50, 0.012, -0.55), (1.25, 0.58, 0.011, 0.45),
        (2.75, 0.42, 0.010, -0.18), (4.35, 0.62, 0.012, 0.62),
        (5.65, 0.48, 0.010, -0.48), (7.15, 0.58, 0.011, 0.22),
    ]:
        _add_room_murmur(buf, start, seconds, amp, pos)
    for t, notes, pos in [(1.9, ["C6", "G5"], -0.42), (5.0, ["E6", "C6"], 0.48), (7.9, ["G5", "C6"], -0.10)]:
        _add_chord(buf, t, notes, 0.20, 0.010, pos)
    _add_sweep(buf, 3.25, 145.0, 92.0, 0.85, 0.014, 0.62, "sine")
    return buf


def ambience_car_interior() -> list[list[float]]:
    buf = _empty(8.0)
    _add_noise(buf, 0.010, "dark", 0.0, 0.03)
    _add_tone(buf, 0.0, 43.0, 8.0, 0.026, -0.10, "sine")
    _add_tone(buf, 0.0, 86.0, 8.0, 0.011, 0.12, "sine")
    _add_tone(buf, 0.0, 129.0, 8.0, 0.004, 0.0, "sine")
    for t in [1.2, 3.75, 6.35]:
        _add_sweep(buf, t, 74.0, 58.0, 0.22, 0.012, RNG.uniform(-0.25, 0.25), "sine")
    return buf


def ambience_night_bus() -> list[list[float]]:
    buf = _empty(8.0)
    _add_noise(buf, 0.016, "dark", 0.0, 0.05)
    _add_tone(buf, 0.0, 38.0, 8.0, 0.030, -0.05, "sine")
    _add_tone(buf, 0.0, 76.0, 8.0, 0.012, 0.12, "sine")
    for t, pos in [(0.85, -0.25), (2.35, 0.18), (4.8, -0.12), (6.65, 0.26)]:
        _add_noise_burst(buf, t, 0.11, 0.018, pos, "dark")
        _add_sweep(buf, t, 92.0, 61.0, 0.18, 0.010, pos, "sine")
    return buf


def ambience_train_interior() -> list[list[float]]:
    buf = _empty(8.0)
    _add_noise(buf, 0.014, "bright", 0.0, 0.04)
    _add_tone(buf, 0.0, 51.0, 8.0, 0.022, -0.06, "sine")
    _add_tone(buf, 0.0, 102.0, 8.0, 0.008, 0.14, "sine")
    for t in [0.45, 1.25, 2.05, 2.85, 3.65, 4.45, 5.25, 6.05, 6.85, 7.65]:
        _add_noise_burst(buf, t, 0.035, 0.012, -0.18 if int(t * 10) % 2 else 0.18, "dark")
    _add_chord(buf, 3.15, ["E5", "B5"], 0.22, 0.006, 0.42)
    return buf


def sfx_wedding_applause() -> list[list[float]]:
    duration = 6.4
    buf = _empty(duration)
    t = 0.0
    while t < duration - 0.18:
        density = 10.0 + 13.0 * math.sin(math.pi * t / duration)
        t += RNG.uniform(0.55, 1.25) / density
        envelope = min(1.0, t / 0.45) * min(1.0, (duration - t) / 1.25)
        pos = RNG.uniform(-0.82, 0.82)
        amp = RNG.uniform(0.035, 0.075) * envelope
        length = RNG.uniform(0.045, 0.105)
        _add_noise_burst(buf, t, length, amp, pos, "bright")
        _add_noise_burst(buf, t + 0.018, length * 0.75, amp * 0.46, pos * 0.72, "dark")
        _add_noise_burst(buf, t + 0.11, length, amp * 0.14, -pos * 0.55, "bright")
    return buf


def sfx_wedding_cheer() -> list[list[float]]:
    duration = 4.2
    buf = _empty(duration)
    _add_noise(buf, 0.006, "dark", 0.0, 0.0)
    for voice in range(14):
        start = RNG.uniform(0.10, 0.95)
        seconds = RNG.uniform(1.3, 2.8)
        base = RNG.uniform(145.0, 260.0)
        end = base * RNG.uniform(1.05, 1.42)
        pos = RNG.uniform(-0.82, 0.82)
        amp = RNG.uniform(0.009, 0.021)
        _add_sweep(buf, start, base, end, seconds, amp, pos, "sine")
        _add_sweep(buf, start + 0.04, base * 2.25, end * 2.05, seconds * 0.86, amp * 0.34, pos, "sine")
        _add_noise_burst(buf, start, min(0.32, seconds * 0.2), amp * 0.55, pos, "bright")
    return buf


def sfx_distant_fireworks() -> list[list[float]]:
    buf = _empty(6.2)
    for start, pos, weight in [(0.25, -0.48, 1.0), (1.72, 0.36, 0.78), (3.25, -0.12, 1.18), (5.05, 0.58, 0.86)]:
        _add_noise_burst(buf, start, 0.18, 0.095 * weight, pos, "dark")
        _add_sweep(buf, start, 78.0, 41.0, 0.75, 0.075 * weight, pos, "sine")
        for crack in range(7):
            _add_noise_burst(buf, start + 0.10 + crack * RNG.uniform(0.035, 0.075),
                             0.035, 0.022 * weight, _clamp(pos + RNG.uniform(-0.25, 0.25)), "bright")
        _add_noise_burst(buf, start + 0.38, 0.25, 0.018 * weight, -pos * 0.45, "dark")
    return buf


def sfx_card_shuffle() -> list[list[float]]:
    """Dry paper packets sliding and settling on a felt table."""
    buf = _empty(1.35)
    for packet in range(11):
        start = 0.05 + packet * 0.085 + RNG.uniform(-0.018, 0.018)
        pos = -0.38 + packet / 10.0 * 0.76
        _add_noise_burst(buf, start, 0.16, 0.095, pos, "bright")
        _add_sweep(buf, start, 1680.0, 620.0, 0.13, 0.025, pos, "tri")
    for start, pos in [(1.03, -0.16), (1.12, 0.17)]:
        _add_noise_burst(buf, start, 0.075, 0.11, pos, "dark")
        _add_tone(buf, start, 185.0, 0.09, 0.052, pos, "tri")
    return buf


def sfx_card_deal() -> list[list[float]]:
    """One card sliding across felt, followed by a soft landing."""
    buf = _empty(0.34)
    _add_noise_burst(buf, 0.01, 0.22, 0.105, -0.18, "bright")
    _add_sweep(buf, 0.015, 2100.0, 540.0, 0.20, 0.028, 0.12, "tri")
    _add_noise_burst(buf, 0.215, 0.065, 0.16, 0.16, "dark")
    _add_tone(buf, 0.215, 165.0, 0.075, 0.055, 0.14, "tri")
    return buf


def sfx_card_flip() -> list[list[float]]:
    """A fingertip lifts and turns a card without a synthetic ping."""
    buf = _empty(0.38)
    _add_noise_burst(buf, 0.015, 0.085, 0.095, -0.12, "bright")
    _add_sweep(buf, 0.03, 780.0, 1840.0, 0.14, 0.034, -0.04, "tri")
    _add_noise_burst(buf, 0.19, 0.075, 0.15, 0.12, "dark")
    _add_tone(buf, 0.19, 205.0, 0.085, 0.052, 0.12, "tri")
    return buf


def _add_chip_clack(buf: list[list[float]], start: float, amp: float,
                    pos: float, pitch: float = 1.0) -> None:
    _add_noise_burst(buf, start, 0.030, amp * 0.46, pos, "bright")
    _add_tone(buf, start, 1640.0 * pitch, 0.055, amp, pos, "sine")
    _add_tone(buf, start + 0.004, 2870.0 * pitch, 0.038, amp * 0.33, pos, "sine")
    _add_tone(buf, start + 0.018, 780.0 * pitch, 0.065, amp * 0.22, pos, "tri")


def sfx_chip_place() -> list[list[float]]:
    buf = _empty(0.24)
    _add_chip_clack(buf, 0.012, 0.115, -0.06, 0.96)
    _add_noise_burst(buf, 0.086, 0.055, 0.045, 0.08, "dark")
    return buf


def sfx_chip_collect() -> list[list[float]]:
    buf = _empty(0.82)
    for index, start in enumerate([0.03, 0.11, 0.19, 0.31, 0.43, 0.57]):
        _add_chip_clack(buf, start, 0.075 - index * 0.004,
                        -0.45 + index * 0.17, RNG.uniform(0.88, 1.12))
    _add_noise_burst(buf, 0.12, 0.55, 0.035, 0.0, "dark")
    return buf


def sfx_dice_cup_shake() -> list[list[float]]:
    buf = _empty(1.08)
    _add_tone(buf, 0.0, 118.0, 0.95, 0.050, -0.05, "tri")
    for index in range(16):
        start = 0.05 + index * 0.055 + RNG.uniform(-0.012, 0.012)
        pos = -0.42 if index % 2 == 0 else 0.42
        _add_noise_burst(buf, start, 0.045, 0.085, pos, "dark")
        _add_tone(buf, start, RNG.uniform(420.0, 840.0), 0.050, 0.055, pos, "tri")
    _add_noise_burst(buf, 0.90, 0.10, 0.12, 0.0, "dark")
    return buf


def sfx_dice_roll() -> list[list[float]]:
    """A short tumbling cluster; runtime pitch variation forms a full roll."""
    buf = _empty(0.20)
    for index, start in enumerate([0.006, 0.046, 0.092, 0.139]):
        pos = -0.34 + index * 0.23
        _add_noise_burst(buf, start, 0.032, 0.10 - index * 0.012, pos, "bright")
        _add_tone(buf, start, 520.0 + index * 130.0, 0.045, 0.065, pos, "tri")
    return buf


def sfx_roulette_wheel() -> list[list[float]]:
    buf = _empty(3.1)
    _add_tone(buf, 0.0, 76.0, 3.0, 0.045, 0.0, "sine")
    _add_sweep(buf, 0.0, 128.0, 72.0, 3.0, 0.038, -0.08, "tri")
    _add_noise(buf, 0.024, "dark", 0.0, 4.8)
    for index in range(14):
        start = 0.08 + index * (0.13 + index * 0.006)
        _add_noise_burst(buf, start, 0.024, 0.035, RNG.uniform(-0.4, 0.4), "dark")
    return buf


def sfx_roulette_ball() -> list[list[float]]:
    """A single ivory-ball rail tick, repeated with varied pitch at runtime."""
    buf = _empty(0.115)
    _add_noise_burst(buf, 0.004, 0.026, 0.11, 0.0, "bright")
    _add_tone(buf, 0.004, 2420.0, 0.070, 0.090, 0.0, "sine")
    _add_tone(buf, 0.011, 920.0, 0.080, 0.032, 0.0, "tri")
    return buf


def sfx_roulette_land() -> list[list[float]]:
    buf = _empty(0.48)
    for index, start in enumerate([0.01, 0.09, 0.18, 0.285]):
        _add_noise_burst(buf, start, 0.030, 0.13 - index * 0.018,
                         -0.20 + index * 0.13, "bright")
        _add_tone(buf, start, 2100.0 - index * 270.0, 0.06, 0.075, 0.0, "sine")
    _add_tone(buf, 0.28, 310.0, 0.13, 0.045, 0.12, "tri")
    return buf


def sfx_slot_start() -> list[list[float]]:
    buf = _empty(0.62)
    _add_noise_burst(buf, 0.01, 0.09, 0.10, -0.28, "dark")
    _add_sweep(buf, 0.02, 112.0, 48.0, 0.24, 0.12, -0.15, "tri")
    _add_noise_burst(buf, 0.24, 0.11, 0.13, 0.12, "dark")
    _add_sweep(buf, 0.26, 82.0, 162.0, 0.27, 0.055, 0.18, "tri")
    return buf


def sfx_slot_reel_stop() -> list[list[float]]:
    buf = _empty(0.29)
    _add_noise_burst(buf, 0.005, 0.055, 0.16, -0.05, "dark")
    _add_tone(buf, 0.01, 142.0, 0.14, 0.13, 0.0, "tri")
    _add_tone(buf, 0.065, 690.0, 0.08, 0.048, 0.08, "sine")
    return buf


def sfx_big_wheel_tick() -> list[list[float]]:
    buf = _empty(0.10)
    _add_noise_burst(buf, 0.002, 0.030, 0.14, -0.03, "bright")
    _add_sweep(buf, 0.002, 980.0, 430.0, 0.075, 0.090, 0.04, "tri")
    return buf


def sfx_race_gate() -> list[list[float]]:
    buf = _empty(1.05)
    _add_tone(buf, 0.01, 1180.0, 0.36, 0.105, -0.12, "sine")
    _add_tone(buf, 0.01, 2360.0, 0.26, 0.045, 0.08, "sine")
    _add_noise_burst(buf, 0.24, 0.18, 0.16, 0.0, "dark")
    _add_sweep(buf, 0.24, 155.0, 61.0, 0.55, 0.14, 0.0, "tri")
    _add_noise_burst(buf, 0.55, 0.18, 0.08, 0.22, "dark")
    return buf


def sfx_horse_gallop() -> list[list[float]]:
    """One short hoof pair; runtime cadence turns it into a gallop."""
    buf = _empty(0.19)
    for start, pos, amp in [(0.005, -0.18, 0.15), (0.072, 0.16, 0.12)]:
        _add_noise_burst(buf, start, 0.050, amp, pos, "dark")
        _add_tone(buf, start, 92.0, 0.095, amp * 0.82, pos, "tri")
        _add_tone(buf, start + 0.008, 315.0, 0.055, amp * 0.24, pos, "tri")
    return buf


def sfx_race_crowd_rise() -> list[list[float]]:
    buf = _empty(2.8)
    _add_noise(buf, 0.018, "dark", 0.0, 0.0)
    for voice in range(18):
        start = RNG.uniform(0.0, 0.65)
        duration = RNG.uniform(1.5, 2.5)
        base = RNG.uniform(110.0, 230.0)
        pos = RNG.uniform(-0.88, 0.88)
        amp = RNG.uniform(0.008, 0.019)
        _add_sweep(buf, start, base, base * RNG.uniform(1.15, 1.65),
                   duration, amp, pos, "sine")
        _add_noise_burst(buf, start + duration * 0.45, 0.25, amp * 0.55, pos, "bright")
    return buf


def sfx_race_finish() -> list[list[float]]:
    buf = _empty(1.15)
    _add_noise_burst(buf, 0.005, 0.055, 0.17, -0.15, "bright")
    _add_tone(buf, 0.01, 1480.0, 0.30, 0.105, -0.08, "sine")
    _add_tone(buf, 0.01, 2960.0, 0.18, 0.045, 0.10, "sine")
    for start, pos in [(0.32, -0.46), (0.39, 0.35), (0.51, -0.12), (0.62, 0.54)]:
        _add_noise_burst(buf, start, 0.10, 0.085, pos, "bright")
    return buf


def _scene_music(bpm: float, meter: int, bars: int, progression: list[list[str]],
                 melody: list[list[str]], voice: str, bass_voice: str = "cello") -> list[list[float]]:
    beat = 60.0 / bpm
    bar_len = beat * meter
    buf = _empty(bar_len * bars)
    _add_noise(buf, 0.0028, "dark", 0.0, 0.0)
    for bar in range(bars):
        start = bar * bar_len
        chord = progression[bar % len(progression)]
        _add_scene_chord(buf, start, chord, bar_len * 0.92, 0.070, voice)
        _add_instrument_note(buf, start, chord[0], bar_len * 0.82, 0.070, -0.18, bass_voice)
        notes = melody[bar % len(melody)]
        if notes:
            step = bar_len / len(notes)
            for index, note in enumerate(notes):
                if note == "-":
                    continue
                _add_instrument_note(buf, start + index * step, note,
                                     min(step * 0.82, 0.72), 0.050, 0.22, "piano" if voice != "bell" else "bell")
    return buf


def bgm_wedding_processional() -> list[list[float]]:
    progression = [
        ["C3", "G3", "C4", "E4"], ["G2", "D3", "G3", "B3"],
        ["A2", "E3", "A3", "C4"], ["E3", "B3", "E4", "G4"],
        ["F2", "C3", "F3", "A3"], ["C3", "G3", "C4", "E4"],
        ["D3", "A3", "D4", "F4"], ["G2", "D3", "G3", "B3"],
    ]
    melody = [
        ["E4", "G4", "C5"], ["D4", "G4", "B4"], ["E4", "A4", "C5"], ["B3", "E4", "G4"],
        ["A4", "G4", "F4"], ["E4", "G4", "C5"], ["F4", "A4", "D5"], ["B4", "A4", "G4"],
    ]
    return _scene_music(76.0, 3, 16, progression, melody, "organ")


def bgm_intimate() -> list[list[float]]:
    progression = [
        ["C3", "G3", "B3", "E4"], ["A2", "E3", "G3", "C4"],
        ["F2", "C3", "E3", "A3"], ["G2", "D3", "G3", "C4"],
    ]
    melody = [
        ["E4", "-", "G4", "B4"], ["C4", "E4", "G4", "-"],
        ["A3", "C4", "E4", "G4"], ["D4", "-", "G4", "E4"],
    ]
    return _scene_music(70.0, 4, 8, progression, melody, "piano")


def bgm_reckoning() -> list[list[float]]:
    progression = [
        ["D2", "A2", "D3", "F3"], ["Bb2", "F3", "A3", "D4"],
        ["G2", "D3", "G3", "Bb3"], ["A2", "E3", "A3", "C4"],
    ]
    melody = [
        ["D4", "-", "F4", "E4"], ["D4", "A3", "-", "C4"],
        ["Bb3", "D4", "G4", "-"], ["E4", "C4", "A3", "-"],
    ]
    return _scene_music(62.0, 4, 8, progression, melody, "organ")


def bgm_grief() -> list[list[float]]:
    progression = [
        ["A2", "E3", "A3", "C4"], ["F2", "C3", "F3", "A3"],
        ["C3", "G3", "C4", "E4"], ["E2", "B2", "E3", "G3"],
    ]
    melody = [
        ["E4", "-", "C4", "-"], ["A3", "C4", "-", "E4"],
        ["G4", "-", "E4", "D4"], ["B3", "-", "G3", "-"],
    ]
    return _scene_music(58.0, 4, 8, progression, melody, "piano")


def bgm_wonder() -> list[list[float]]:
    progression = [
        ["C3", "G3", "B3", "E4"], ["E3", "B3", "D4", "G4"],
        ["F2", "C3", "E3", "A3"], ["G2", "D3", "G3", "B3"],
    ]
    melody = [
        ["G4", "B4", "E5", "-"], ["G4", "D5", "B4", "-"],
        ["A4", "C5", "E5", "C5"], ["B4", "D5", "G5", "-"],
    ]
    return _scene_music(74.0, 4, 8, progression, melody, "bell")


def main() -> None:
    human_layer_targets = {
        "amb_human_thin_wall.wav": lambda: _human_layer("thin_wall"),
        "amb_human_street.wav": lambda: _human_layer("street"),
        "amb_human_public_interior.wav": lambda: _human_layer("public_interior"),
        "amb_human_cafe.wav": lambda: _human_layer("cafe"),
        "amb_human_casino.wav": lambda: _human_layer("casino"),
        "amb_human_racetrack.wav": lambda: _human_layer("racetrack"),
        "amb_human_wedding.wav": lambda: _human_layer("wedding"),
        "amb_human_transit.wav": lambda: _human_layer("transit"),
        "amb_human_leisure.wav": lambda: _human_layer("leisure"),
    }
    if "--human-only" in sys.argv[1:]:
        for name, build in human_layer_targets.items():
            _write(AUDIO_DIR / name, build())
        print("AUDIO_P1_HUMAN_LAYERS_GENERATED", len(human_layer_targets))
        return

    targets = {
        "amb_goshiwon_room.wav": ambience_goshiwon,
        "amb_seoul_rain.wav": ambience_rain,
        "amb_hangang_riverside.wav": ambience_hangang,
        "amb_office_room.wav": ambience_office,
        "amb_casino_floor.wav": ambience_casino,
        "sfx_ending_stinger_good.wav": stinger_good,
        "sfx_ending_stinger_bad.wav": stinger_bad,
        "sfx_ending_stinger_legend.wav": stinger_legend,
        "amb_subway_platform.wav": ambience_subway,
        "amb_racetrack_crowd.wav": ambience_racetrack,
        "amb_cafe_room.wav": ambience_cafe,
        "amb_pc_bang.wav": ambience_pc_bang,
        "amb_gym_room.wav": ambience_gym,
        "amb_convenience_store.wav": ambience_convenience,
        "amb_hagwon_street.wav": ambience_hagwon_street,
        "amb_school_hall.wav": ambience_school_hall,
        "amb_public_office.wav": ambience_public_office,
        "amb_jjimjilbang.wav": ambience_jjimjilbang,
        "amb_cherry_blossom.wav": ambience_cherry_blossom,
        "amb_saju_cafe.wav": ambience_saju_cafe,
        "amb_military_gate.wav": ambience_military_gate,
        "amb_seoul_street.wav": ambience_seoul_street,
        "amb_company_dinner.wav": ambience_company_dinner,
        "amb_heatwave_city.wav": ambience_heatwave_city,
        "amb_fine_dust_city.wav": ambience_fine_dust_city,
        "amb_highway_traffic.wav": ambience_highway_traffic,
        "amb_open_chat_room.wav": ambience_open_chat_room,
        "amb_library_room.wav": ambience_library_room,
        "sfx_civil_defense_siren.wav": sfx_civil_defense_siren,
        "sfx_monsoon_rain.wav": sfx_monsoon_rain,
        "amb_oneroom_room.wav": ambience_oneroom_room,
        "amb_apartment_room.wav": ambience_apartment_room,
        "amb_summer_night.wav": ambience_summer_night,
        "amb_winter_wind.wav": ambience_winter_wind,
        "amb_wedding_hall.wav": ambience_wedding_hall,
        "amb_hospital_room.wav": ambience_hospital_room,
        "amb_seaside.wav": ambience_seaside,
        "amb_amusement_park.wav": ambience_amusement_park,
        "amb_car_interior.wav": ambience_car_interior,
        "amb_night_bus.wav": ambience_night_bus,
        "amb_train_interior.wav": ambience_train_interior,
        "sfx_wedding_applause.wav": sfx_wedding_applause,
        "sfx_wedding_cheer.wav": sfx_wedding_cheer,
        "sfx_distant_fireworks.wav": sfx_distant_fireworks,
    }
    for name, build in targets.items():
        _write(AUDIO_DIR / name, build())
    physical_sfx_targets = {
        "sfx_card_shuffle.wav": sfx_card_shuffle,
        "sfx_card_deal.wav": sfx_card_deal,
        "sfx_card_flip.wav": sfx_card_flip,
        "sfx_chip_place.wav": sfx_chip_place,
        "sfx_chip_collect.wav": sfx_chip_collect,
        "sfx_dice_cup_shake.wav": sfx_dice_cup_shake,
        "sfx_dice_roll.wav": sfx_dice_roll,
        "sfx_roulette_wheel.wav": sfx_roulette_wheel,
        "sfx_roulette_ball.wav": sfx_roulette_ball,
        "sfx_roulette_land.wav": sfx_roulette_land,
        "sfx_slot_start.wav": sfx_slot_start,
        "sfx_slot_reel_stop.wav": sfx_slot_reel_stop,
        "sfx_big_wheel_tick.wav": sfx_big_wheel_tick,
        "sfx_race_gate.wav": sfx_race_gate,
        "sfx_horse_gallop.wav": sfx_horse_gallop,
        "sfx_race_crowd_rise.wav": sfx_race_crowd_rise,
        "sfx_race_finish.wav": sfx_race_finish,
    }
    for name, build in physical_sfx_targets.items():
        _write(AUDIO_DIR / name, build(), fade_edges=False)
    music_targets = {
        "bgm_wedding_processional.ogg": bgm_wedding_processional,
        "bgm_intimate.ogg": bgm_intimate,
        "bgm_reckoning.ogg": bgm_reckoning,
        "bgm_grief.ogg": bgm_grief,
        "bgm_wonder.ogg": bgm_wonder,
    }
    for name, build in music_targets.items():
        _write_ogg(AUDIO_DIR / name, build())
    # Keep these after the established targets so adding a new moral layer never
    # changes the deterministic masters for existing scene or physical sounds.
    for name, build in human_layer_targets.items():
        _write(AUDIO_DIR / name, build())
    print(
        "AUDIO_P1_ASSETS_GENERATED",
        len(targets) + len(physical_sfx_targets) + len(music_targets) + len(human_layer_targets),
    )


if __name__ == "__main__":
    main()
