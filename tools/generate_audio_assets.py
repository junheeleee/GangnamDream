#!/usr/bin/env python3
"""Generate Gangnam Dream placeholder-production audio assets.

This script creates deterministic lo-fi BGM loops and short UI/game SFX without
requiring external music services. BGM is rendered as temporary WAV and encoded
to Ogg Vorbis through a local ffmpeg binary when available.
"""

from __future__ import annotations

import math
import shutil
import struct
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
AUDIO_DIR = ROOT / "assets" / "audio"
SR = 44100
RNG = np.random.default_rng(20260613)
FFMPEG_CANDIDATES = [
    shutil.which("ffmpeg"),
    "/Applications/CapCut.app/Contents/Resources/ffmpeg",
]


def _ffmpeg() -> str:
    try:
        import imageio_ffmpeg  # type: ignore

        exe = imageio_ffmpeg.get_ffmpeg_exe()
        if exe and Path(exe).exists():
            return str(exe)
    except Exception:
        pass
    for candidate in FFMPEG_CANDIDATES:
        if candidate and Path(candidate).exists():
            return str(candidate)
    raise RuntimeError("ffmpeg not found; install ffmpeg or update FFMPEG_CANDIDATES")


def note(name: str) -> float:
    names = {"C": -9, "C#": -8, "Db": -8, "D": -7, "D#": -6, "Eb": -6, "E": -5,
             "F": -4, "F#": -3, "Gb": -3, "G": -2, "G#": -1, "Ab": -1, "A": 0,
             "A#": 1, "Bb": 1, "B": 2}
    pitch = name[:-1]
    octave = int(name[-1])
    semitone = names[pitch] + (octave - 4) * 12
    return 440.0 * (2.0 ** (semitone / 12.0))


def stereo(seconds: float) -> np.ndarray:
    return np.zeros((int(SR * seconds), 2), dtype=np.float32)


def env(length: int, attack: float = 0.01, release: float = 0.08) -> np.ndarray:
    e = np.ones(length, dtype=np.float32)
    a = min(length, max(1, int(SR * attack)))
    r = min(length, max(1, int(SR * release)))
    e[:a] *= np.linspace(0.0, 1.0, a, dtype=np.float32)
    e[-r:] *= np.linspace(1.0, 0.0, r, dtype=np.float32)
    return e


def pan(sample: np.ndarray, pos: float) -> np.ndarray:
    pos = max(-1.0, min(1.0, pos))
    left = math.cos((pos + 1.0) * math.pi / 4.0)
    right = math.sin((pos + 1.0) * math.pi / 4.0)
    return np.column_stack((sample * left, sample * right)).astype(np.float32)


def add(arr: np.ndarray, start: float, sound: np.ndarray) -> None:
    i = int(start * SR)
    if i >= len(arr):
        return
    end = min(len(arr), i + len(sound))
    arr[i:end] += sound[: end - i]


def tone(freq: float, seconds: float, amp: float, kind: str = "sine", position: float = 0.0,
         attack: float = 0.005, release: float = 0.08, detune: float = 0.0) -> np.ndarray:
    n = int(SR * seconds)
    t = np.arange(n, dtype=np.float32) / SR
    f = freq * (1.0 + detune)
    if kind == "tri":
        s = (2.0 / math.pi) * np.arcsin(np.sin(2.0 * math.pi * f * t))
    elif kind == "soft_square":
        s = np.tanh(2.2 * np.sin(2.0 * math.pi * f * t))
    elif kind == "saw":
        s = 2.0 * ((f * t) % 1.0) - 1.0
    else:
        s = np.sin(2.0 * math.pi * f * t)
    s *= env(n, attack, release) * amp
    return pan(s.astype(np.float32), position)


def pluck(freq: float, seconds: float, amp: float, position: float = 0.0) -> np.ndarray:
    n = int(SR * seconds)
    t = np.arange(n, dtype=np.float32) / SR
    body = (
        np.sin(2 * math.pi * freq * t)
        + 0.35 * np.sin(2 * math.pi * freq * 2.01 * t)
        + 0.12 * np.sin(2 * math.pi * freq * 3.02 * t)
    )
    decay = np.exp(-5.5 * t / max(seconds, 0.001))
    attack = np.minimum(1.0, t / 0.008)
    s = body * decay * attack * amp
    return pan(s.astype(np.float32), position)


def pad_chord(freqs: list[float], seconds: float, amp: float, position: float = 0.0) -> np.ndarray:
    n = int(SR * seconds)
    t = np.arange(n, dtype=np.float32) / SR
    s = np.zeros(n, dtype=np.float32)
    for idx, f in enumerate(freqs):
        det = (idx - len(freqs) / 2.0) * 0.002
        s += np.sin(2 * math.pi * f * (1 + det) * t + idx * 0.9)
        s += 0.25 * np.sin(2 * math.pi * f * 0.5 * t + idx * 1.7)
    s /= max(1, len(freqs))
    lfo = 0.72 + 0.28 * np.sin(2 * math.pi * 0.08 * t)
    s *= lfo * env(n, 0.35, 0.45) * amp
    return pan(s.astype(np.float32), position)


def noise(seconds: float, amp: float, color: str = "white", position: float = 0.0) -> np.ndarray:
    n = int(SR * seconds)
    raw = RNG.normal(0, 1, n).astype(np.float32)
    if color == "dark":
        for _ in range(4):
            raw = np.convolve(raw, np.ones(11, dtype=np.float32) / 11.0, mode="same")
    if color == "vinyl":
        pops = np.zeros(n, dtype=np.float32)
        for _ in range(max(2, int(seconds * 2))):
            j = RNG.integers(0, n)
            w = min(n - j, RNG.integers(40, 220))
            pops[j:j + w] += np.linspace(1.0, 0.0, w, dtype=np.float32) * RNG.uniform(0.2, 0.9)
        raw = raw * 0.28 + pops
    raw *= amp
    return pan(raw, position)


def kick() -> np.ndarray:
    n = int(SR * 0.42)
    t = np.arange(n, dtype=np.float32) / SR
    f = 48 + 80 * np.exp(-18 * t)
    phase = np.cumsum(2 * math.pi * f / SR)
    s = np.sin(phase) * np.exp(-8 * t) * 0.55
    return pan(s.astype(np.float32), 0.0)


def snare(amp: float = 0.18) -> np.ndarray:
    n = int(SR * 0.18)
    t = np.arange(n, dtype=np.float32) / SR
    s = RNG.normal(0, 1, n).astype(np.float32) * np.exp(-18 * t)
    s += 0.25 * np.sin(2 * math.pi * 185 * t) * np.exp(-12 * t)
    return pan(s * amp, 0.05)


def hat(amp: float = 0.055) -> np.ndarray:
    n = int(SR * 0.07)
    t = np.arange(n, dtype=np.float32) / SR
    s = RNG.normal(0, 1, n).astype(np.float32)
    s -= np.convolve(s, np.ones(24, dtype=np.float32) / 24.0, mode="same")
    s *= np.exp(-45 * t) * amp
    return pan(s, -0.15)


def normalize(arr: np.ndarray, peak: float = 0.85) -> np.ndarray:
    m = float(np.max(np.abs(arr))) if arr.size else 0.0
    if m > peak:
        arr = arr * (peak / m)
    return np.tanh(arr * 1.05).astype(np.float32)


def write_wav(path: Path, arr: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    arr = normalize(arr, 0.92)
    pcm = np.clip(arr, -1.0, 1.0)
    pcm16 = (pcm * 32767.0).astype("<i2")
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(2 if pcm16.ndim == 2 else 1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(pcm16.tobytes())


def write_sfx(path: Path, arr: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    arr = normalize(arr, 0.9)
    if arr.ndim == 2:
        mono = arr.mean(axis=1)
    else:
        mono = arr
    pcm16 = (np.clip(mono, -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(pcm16.tobytes())


def encode_ogg(wav_path: Path, ogg_path: Path) -> None:
    subprocess.run(
        [_ffmpeg(), "-y", "-loglevel", "error", "-i", str(wav_path),
         "-c:a", "libvorbis", "-q:a", "4", str(ogg_path)],
        check=True,
    )


def render_loop(filename: str, bpm: float, bars: int, progression: list[list[str]],
                mood: str, beat: str = "light") -> None:
    bar_len = 60.0 / bpm * 4.0
    dur = bar_len * bars
    arr = stereo(dur)
    add(arr, 0.0, noise(dur, 0.010 if mood != "crisis" else 0.018, "vinyl" if mood != "crisis" else "dark", -0.25))
    if mood in {"menu", "gosiwon"}:
        add(arr, 0.0, tone(60.0, dur, 0.012, "sine", 0.0, 0.8, 0.8))
    if mood == "crisis":
        add(arr, 0.0, tone(43.0, dur, 0.11, "sine", 0.0, 1.2, 1.2))
        add(arr, 0.0, tone(47.5, dur, 0.075, "saw", -0.2, 1.0, 1.0))
    for bar in range(bars):
        chord_names = progression[bar % len(progression)]
        start = bar * bar_len
        freqs = [note(n) for n in chord_names]
        add(arr, start, pad_chord(freqs[1:], bar_len * 1.02, 0.12 if mood != "gosiwon" else 0.07, -0.05))
        add(arr, start, tone(freqs[0] / 2.0, bar_len * 0.82, 0.10 if mood != "crisis" else 0.16, "soft_square", -0.18, 0.02, 0.22))
        if mood != "crisis":
            melody = [freqs[-1], freqs[-2], freqs[1], freqs[-1] * 1.125]
            for j, mf in enumerate(melody):
                if mood == "gosiwon" and j % 2 == 1:
                    continue
                add(arr, start + (j * 0.75 + 0.15) * bar_len / 4.0,
                    pluck(mf, 0.9 if mood != "apartment" else 0.65,
                          0.10 if mood in {"main", "apartment"} else 0.065,
                          -0.25 + j * 0.13))
        else:
            if bar % 2 == 0:
                add(arr, start + bar_len * 0.42, pluck(freqs[-1] * 1.01, 1.4, 0.07, 0.25))
            add(arr, start + bar_len * 0.72, tone(freqs[1] * 0.97, 0.22, 0.08, "tri", 0.18, 0.002, 0.18))
        if beat != "none":
            beats = 4
            for b in range(beats):
                bt = start + b * bar_len / 4.0
                if beat in {"full", "up"} and b in {0, 2}:
                    add(arr, bt, kick())
                elif beat == "light" and b == 0:
                    add(arr, bt, kick() * 0.55)
                if beat in {"full", "up"} and b in {1, 3}:
                    add(arr, bt, snare(0.14 if mood != "apartment" else 0.17))
                if beat in {"full", "up", "light"}:
                    add(arr, bt + bar_len / 8.0, hat(0.035 if mood != "apartment" else 0.05))
                    if beat in {"full", "up"}:
                        add(arr, bt + bar_len / 16.0 * 3.0, hat(0.025))
    if mood == "ending":
        for bar in range(0, bars, 2):
            add(arr, bar * bar_len + 0.2, pluck(note("Eb5"), 1.2, 0.08, 0.18))
            add(arr, bar * bar_len + bar_len * 0.55, pluck(note("Bb4"), 1.3, 0.07, -0.18))
    with tempfile.TemporaryDirectory() as td:
        wav_path = Path(td) / f"{filename}.wav"
        write_wav(wav_path, arr)
        encode_ogg(wav_path, AUDIO_DIR / filename)


def render_victory() -> None:
    dur = 8.2
    arr = stereo(dur)
    chords = [["C3", "E4", "G4"], ["F3", "A4", "C5"], ["G3", "B4", "D5"], ["C4", "E4", "G4", "C5"]]
    for i, chord in enumerate(chords):
        start = i * 1.6
        add(arr, start, pad_chord([note(n) for n in chord], 2.0, 0.18, 0.0))
        for j, n in enumerate(chord[1:]):
            add(arr, start + 0.12 + j * 0.18, pluck(note(n), 1.0, 0.15, -0.15 + j * 0.2))
    add(arr, 0.05, tone(note("C3"), 0.8, 0.12, "soft_square", 0.0, 0.01, 0.2))
    add(arr, 3.2, tone(note("G3"), 0.8, 0.12, "soft_square", 0.0, 0.01, 0.2))
    add(arr, 6.3, pluck(note("C5"), 1.5, 0.18, 0.1))
    with tempfile.TemporaryDirectory() as td:
        wav_path = Path(td) / "bgm_victory.wav"
        write_wav(wav_path, arr)
        encode_ogg(wav_path, AUDIO_DIR / "bgm_victory.ogg")


def sweep(start_freq: float, end_freq: float, seconds: float, amp: float) -> np.ndarray:
    n = int(SR * seconds)
    t = np.arange(n, dtype=np.float32) / SR
    freqs = np.linspace(start_freq, end_freq, n, dtype=np.float32)
    phase = np.cumsum(2 * math.pi * freqs / SR)
    s = np.sin(phase) * env(n, 0.002, seconds * 0.45) * amp
    return pan(s, 0.0)


def chord_sfx(freqs: list[float], seconds: float, amp: float, up: bool = True) -> np.ndarray:
    arr = stereo(seconds)
    spacing = seconds * 0.18
    order = freqs if up else list(reversed(freqs))
    for i, f in enumerate(order):
        add(arr, i * spacing, pluck(f, seconds * 0.75, amp, -0.2 + 0.2 * i))
    return arr


def mix(*sounds: np.ndarray) -> np.ndarray:
    length = max(len(sound) for sound in sounds)
    out = np.zeros((length, 2), dtype=np.float32)
    for sound in sounds:
        out[: len(sound)] += sound
    return out


def render_sfx() -> None:
    sfx: dict[str, np.ndarray] = {}
    sfx["sfx_click.wav"] = mix(sweep(950, 680, 0.055, 0.18), noise(0.055, 0.018))
    sfx["sfx_close.wav"] = sweep(520, 290, 0.12, 0.18)
    sfx["sfx_open_modal.wav"] = chord_sfx([note("C5"), note("G5")], 0.18, 0.14)
    sfx["sfx_tab_open.wav"] = chord_sfx([note("E4"), note("A4")], 0.14, 0.12)
    sfx["sfx_choice_made.wav"] = sweep(560, 760, 0.12, 0.12) + chord_sfx([note("D5")], 0.12, 0.08)
    sfx["sfx_event_new.wav"] = chord_sfx([note("A4"), note("C5"), note("E5")], 0.32, 0.10)
    sfx["sfx_month.wav"] = mix(noise(0.35, 0.035, "dark"), sweep(360, 520, 0.23, 0.08))
    sfx["sfx_money_gain.wav"] = chord_sfx([note("E5"), note("G5"), note("B5")], 0.28, 0.12)
    sfx["sfx_money_loss.wav"] = mix(chord_sfx([note("C4"), note("A3")], 0.34, 0.14, up=False), sweep(260, 150, 0.34, 0.09))
    sfx["sfx_money_big.wav"] = chord_sfx([note("C5"), note("E5"), note("G5"), note("C6")], 0.65, 0.14)
    sfx["sfx_stat_up.wav"] = chord_sfx([note("G4"), note("B4")], 0.18, 0.11)
    sfx["sfx_stat_down.wav"] = sweep(430, 260, 0.22, 0.13)
    sfx["sfx_housing_up.wav"] = chord_sfx([note("C4"), note("G4"), note("C5"), note("E5")], 0.55, 0.12)
    sfx["sfx_game_over.wav"] = mix(sweep(160, 72, 0.95, 0.22), noise(0.95, 0.012, "dark"))
    sfx["sfx_success.wav"] = chord_sfx([note("C4"), note("E4"), note("G4"), note("C5"), note("E5")], 0.82, 0.13)
    sfx["sfx_buy.wav"] = mix(chord_sfx([note("A4"), note("C5")], 0.16, 0.11), sweep(500, 650, 0.12, 0.04))
    sfx["sfx_sell.wav"] = mix(chord_sfx([note("C5"), note("A4")], 0.16, 0.11, up=False), sweep(640, 430, 0.13, 0.05))
    for filename, data in sfx.items():
        write_sfx(AUDIO_DIR / filename, data)


def main() -> None:
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    render_loop("bgm_menu.ogg", 70.0, 16, [["C3", "Eb4", "G4", "Bb4"], ["Ab2", "Eb4", "G4", "C5"],
             ["Eb3", "G4", "Bb4", "Eb5"], ["Bb2", "D4", "F4", "Ab4"]], "menu", "light")
    render_loop("bgm_gosiwon.ogg", 72.0, 16, [["C3", "Eb4", "G4"], ["Ab2", "C4", "Eb4"],
             ["F2", "C4", "Eb4"], ["Bb2", "D4", "F4"]], "gosiwon", "light")
    render_loop("bgm_main.ogg", 82.0, 16, [["F2", "Ab3", "C4", "Eb4"], ["Db3", "F4", "Ab4"],
             ["Ab2", "C4", "Eb4", "G4"], ["Eb3", "G4", "Bb4"]], "main", "full")
    render_loop("bgm_apartment.ogg", 90.0, 16, [["Ab2", "C4", "Eb4", "G4"], ["Eb3", "G4", "Bb4"],
             ["F3", "Ab4", "C5"], ["Db3", "F4", "Ab4"]], "apartment", "up")
    render_loop("bgm_crisis.ogg", 68.0, 12, [["C2", "Db4", "G4"], ["B1", "D4", "F4"],
             ["C2", "Eb4", "Gb4"], ["Ab1", "C4", "E4"]], "crisis", "none")
    render_victory()
    render_loop("bgm_ending.ogg", 76.0, 20, [["C3", "Eb4", "G4", "Bb4"], ["Ab2", "C4", "Eb4", "G4"],
             ["Eb3", "G4", "Bb4", "D5"], ["Bb2", "D4", "F4", "Ab4"]], "ending", "light")
    render_sfx()
    print("AUDIO_ASSETS_GENERATED")


if __name__ == "__main__":
    main()
