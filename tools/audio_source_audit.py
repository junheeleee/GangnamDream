#!/usr/bin/env python3
"""Audit that every shipping sound comes from recordings or real instruments."""

from __future__ import annotations

import array
import hashlib
import json
import math
import re
import wave
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
AUDIO = ROOT / "assets" / "audio"
MANIFEST = AUDIO / "AUDIO_SOURCE_MANIFEST.json"
NOTICES = AUDIO / "AUDIO_THIRD_PARTY_NOTICES.md"

EXPECTED_COUNTS = {"bgm": 20, "ambience": 47, "sfx": 67}
ALLOWED_PROVENANCE = {
    "field_recording",
    "object_recording",
    "real_instrument_sample",
    "sample_derived_mix",
}
ALLOWED_SOURCE_TYPES = {
    "field_recording",
    "object_recording",
    "real_instrument_sample",
}
REQUIRED_LIBRARY_FIELDS = {
    "provider",
    "title",
    "source_type",
    "license",
    "license_url",
    "source_url",
    "attribution_required",
}
HASH_RE = re.compile(r"^[0-9a-f]{64}$")

SYNTHESIS_SURFACES = (
    ROOT / "autoloads/BGMPlayer.gd",
    ROOT / "autoloads/AudioManager.gd",
    ROOT / "tools/generate_audio_assets.py",
    ROOT / "tools/generate_audio_p1_assets.py",
    ROOT / "tools/generate_gangnam_ui_sfx.py",
    ROOT / "tools/generate_launch_audio.py",
    ROOT / "tools/build_sample_audio_assets.py",
)
FORBIDDEN_SYNTH_PATTERNS = {
    "_bake_procedural": "runtime music synthesis",
    "_procedural_stream": "runtime generated fallback",
    "func _tone(": "runtime oscillator fallback",
    "func _chord(": "runtime oscillator fallback",
    "_add_tone": "offline oscillator renderer",
    "_add_noise": "offline generated-noise renderer",
    "band_noise(": "offline generated-noise renderer",
    "math.sin(": "offline oscillator renderer",
    "np.sin(": "offline oscillator renderer",
    "AudioStreamGenerator": "runtime waveform generator",
}

DEMO_LONG_BEDS = set(
    """
amb_goshiwon_room.wav amb_family_home.wav amb_seoul_rain.wav
amb_hangang_riverside.wav amb_office_room.wav amb_seoul_street.wav
amb_cafe_room.wav amb_convenience_store.wav amb_public_office.wav
amb_winter_wind.wav
""".split()
)

HUMAN_BEDS = set(
    """
amb_human_thin_wall.wav amb_human_street.wav amb_human_public_interior.wav
amb_human_cafe.wav amb_human_casino.wav amb_human_racetrack.wav
amb_human_wedding.wav amb_human_transit.wav amb_human_leisure.wav
""".split()
)

STORY_FOLEY = set(
    """
sfx_phone_vibrate.wav sfx_phone_notification.wav sfx_paper_handle.wav
sfx_document_stamp.wav sfx_door_latch.wav sfx_footsteps_hall.wav
sfx_register_scan.wav sfx_keyboard_short.wav sfx_cup_set.wav
sfx_bicycle_impact.wav sfx_traffic_pass.wav sfx_kettle_pour.wav
sfx_bus_arrival.wav sfx_queue_chime.wav
""".split()
)

LONG_ACTION_SFX = {
    "sfx_civil_defense_siren.wav": 2.5,
    "sfx_monsoon_rain.wav": 2.5,
    "sfx_wedding_applause.wav": 2.4,
    "sfx_wedding_cheer.wav": 2.4,
    "sfx_distant_fireworks.wav": 3.0,
    "sfx_horse_gallop.wav": 1.5,
    "sfx_race_crowd_rise.wav": 2.2,
    "sfx_race_finish.wav": 2.4,
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def wav_metrics(path: Path) -> tuple[float, float, float]:
    with wave.open(str(path), "rb") as handle:
        channels = handle.getnchannels()
        sample_width = handle.getsampwidth()
        frame_rate = handle.getframerate()
        frames = handle.getnframes()
        payload = handle.readframes(frames)
    if channels not in {1, 2} or sample_width != 2 or frame_rate <= 0 or frames <= 0:
        raise ValueError(
            f"unsupported WAV format channels={channels} width={sample_width} "
            f"rate={frame_rate} frames={frames}"
        )
    samples = array.array("h")
    samples.frombytes(payload)
    if not samples:
        raise ValueError("empty WAV payload")
    energy = sum(float(sample) * float(sample) for sample in samples) / len(samples)
    rms = math.sqrt(energy) / 32768.0
    peak = max(abs(sample) for sample in samples) / 32768.0
    rms_db = 20.0 * math.log10(max(rms, 1.0e-12))
    return frames / frame_rate, rms_db, peak


def load_manifest(errors: list[str]) -> dict[str, Any]:
    if not MANIFEST.is_file():
        errors.append(f"missing provenance manifest: {MANIFEST.relative_to(ROOT)}")
        return {}
    try:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"cannot read provenance manifest: {exc}")
        return {}
    if payload.get("schema_version") != 1:
        errors.append("provenance manifest schema_version must be 1")
    policy = str(payload.get("policy", "")).lower()
    if "recorded" not in policy or "real-instrument" not in policy or "no generated" not in policy:
        errors.append("provenance manifest policy does not lock the no-synthesis rule")
    return payload


def check_libraries(payload: dict[str, Any], errors: list[str]) -> dict[str, Any]:
    libraries = payload.get("libraries", {})
    if not isinstance(libraries, dict) or not libraries:
        errors.append("provenance manifest has no source libraries")
        return {}
    for library_id, raw in sorted(libraries.items()):
        if not isinstance(raw, dict):
            errors.append(f"library {library_id}: entry is not an object")
            continue
        missing = sorted(REQUIRED_LIBRARY_FIELDS - set(raw))
        if missing:
            errors.append(f"library {library_id}: missing fields {', '.join(missing)}")
        source_type = str(raw.get("source_type", ""))
        if source_type not in ALLOWED_SOURCE_TYPES:
            errors.append(f"library {library_id}: forbidden source type {source_type!r}")
        for key in ("source_url", "license_url"):
            if not str(raw.get(key, "")).startswith("https://"):
                errors.append(f"library {library_id}: {key} must be an https URL")
        if not str(raw.get("license", "")).strip():
            errors.append(f"library {library_id}: empty license")
    return libraries


def check_assets(
    payload: dict[str, Any],
    libraries: dict[str, Any],
    actual: set[str],
    errors: list[str],
) -> None:
    assets = payload.get("assets", {})
    if not isinstance(assets, dict):
        errors.append("provenance manifest assets is not an object")
        return
    manifest_names = set(assets)
    unowned = sorted(actual - manifest_names)
    stale = sorted(manifest_names - actual)
    if unowned:
        errors.append("audio without provenance: " + ", ".join(unowned))
    if stale:
        errors.append("manifest references missing audio: " + ", ".join(stale))

    for name in sorted(actual & manifest_names):
        path = AUDIO / name
        entry = assets[name]
        if not isinstance(entry, dict):
            errors.append(f"{name}: provenance entry is not an object")
            continue
        provenance = str(entry.get("provenance", ""))
        if provenance not in ALLOWED_PROVENANCE:
            errors.append(f"{name}: forbidden provenance {provenance!r}")
        sources = entry.get("sources", [])
        if not isinstance(sources, list) or not sources:
            errors.append(f"{name}: no recorded/sample source")
        else:
            for index, source in enumerate(sources):
                if not isinstance(source, dict):
                    errors.append(f"{name}: source {index} is not an object")
                    continue
                pack = str(source.get("pack", ""))
                if pack not in libraries:
                    errors.append(f"{name}: source {index} uses unknown pack {pack!r}")
                source_type = str(source.get("source_type", ""))
                if source_type not in ALLOWED_SOURCE_TYPES:
                    errors.append(
                        f"{name}: source {index} has forbidden type {source_type!r}"
                    )
                if not str(source.get("original_file", "")).strip():
                    errors.append(f"{name}: source {index} has no original filename")
                if not HASH_RE.fullmatch(str(source.get("sha256", ""))):
                    errors.append(f"{name}: source {index} has invalid SHA-256")
        if not str(entry.get("transform", "")).strip():
            errors.append(f"{name}: empty edit history")
        expected_hash = str(entry.get("output_sha256", ""))
        if not HASH_RE.fullmatch(expected_hash):
            errors.append(f"{name}: invalid output SHA-256")
        elif expected_hash != sha256(path):
            errors.append(f"{name}: output hash drift")


def check_release_wavs(errors: list[str]) -> None:
    for path in sorted(AUDIO.glob("*.wav")):
        try:
            duration, rms_db, peak = wav_metrics(path)
        except (ValueError, wave.Error) as exc:
            errors.append(f"{path.name}: cannot inspect WAV: {exc}")
            continue
        if duration < 0.08:
            errors.append(f"{path.name}: duration {duration:.3f}s is too short")
        if rms_db < -50.0:
            errors.append(f"{path.name}: effectively silent at {rms_db:.1f}dB RMS")
        if peak >= 0.999:
            errors.append(f"{path.name}: clipped peak {peak:.4f}")
        minimum = LONG_ACTION_SFX.get(path.name)
        if minimum is not None and duration < minimum:
            errors.append(
                f"{path.name}: action bed {duration:.2f}s < {minimum:.2f}s"
            )
        if path.name in DEMO_LONG_BEDS:
            if duration < 18.0:
                errors.append(f"{path.name}: demo ambience {duration:.2f}s < 18.0s")
            if not -40.0 <= rms_db <= -24.0:
                errors.append(
                    f"{path.name}: demo ambience RMS {rms_db:.1f}dB outside -40..-24"
                )
        elif path.name in HUMAN_BEDS:
            if duration < 16.0:
                errors.append(f"{path.name}: human ambience {duration:.2f}s < 16.0s")
            if not -43.0 <= rms_db <= -29.0:
                errors.append(
                    f"{path.name}: human ambience RMS {rms_db:.1f}dB outside -43..-29"
                )
        elif path.name in STORY_FOLEY:
            if not 0.18 <= duration <= 3.2:
                errors.append(
                    f"{path.name}: story foley duration {duration:.2f}s outside 0.18..3.2s"
                )
            if not -34.0 <= rms_db <= -14.0:
                errors.append(
                    f"{path.name}: story foley RMS {rms_db:.1f}dB outside -34..-14"
                )


def check_no_synthesis_code(errors: list[str]) -> None:
    for path in SYNTHESIS_SURFACES:
        if not path.is_file():
            errors.append(f"missing audited source surface: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        for pattern, description in FORBIDDEN_SYNTH_PATTERNS.items():
            if pattern in text:
                errors.append(
                    f"{path.relative_to(ROOT)}: {description} token {pattern!r}"
                )


def check_notices(libraries: dict[str, Any], errors: list[str]) -> None:
    if not NOTICES.is_file():
        errors.append(f"missing third-party notice: {NOTICES.relative_to(ROOT)}")
        return
    notice = NOTICES.read_text(encoding="utf-8")
    for library_id, raw in libraries.items():
        if not isinstance(raw, dict) or not raw.get("attribution_required", False):
            continue
        for expected in (str(raw.get("provider", "")), str(raw.get("license", ""))):
            if expected and expected not in notice:
                errors.append(
                    f"third-party notice missing {expected!r} for {library_id}"
                )


def main() -> int:
    actual = {
        path.name
        for path in AUDIO.iterdir()
        if path.suffix.lower() in {".wav", ".ogg"}
    }
    errors: list[str] = []
    counts = {
        "bgm": sum(name.startswith("bgm_") for name in actual),
        "ambience": sum(name.startswith("amb_") for name in actual),
        "sfx": sum(name.startswith("sfx_") for name in actual),
    }
    for kind, expected in EXPECTED_COUNTS.items():
        if counts[kind] != expected:
            errors.append(
                f"{kind} inventory {counts[kind]} does not match expected {expected}"
            )
    if len(actual) != sum(EXPECTED_COUNTS.values()):
        errors.append(f"release audio inventory must be 134, got {len(actual)}")

    payload = load_manifest(errors)
    libraries = check_libraries(payload, errors) if payload else {}
    if payload:
        check_assets(payload, libraries, actual, errors)
    check_release_wavs(errors)
    check_no_synthesis_code(errors)
    if libraries:
        check_notices(libraries, errors)

    if errors:
        for error in errors:
            print("AUDIO_SOURCE_AUDIT_FAIL", error)
        return 1

    print(
        "AUDIO_SOURCE_AUDIT_OK "
        f"assets={len(actual)} bgm={counts['bgm']} ambience={counts['ambience']} "
        f"sfx={counts['sfx']} source_libraries={len(libraries)} "
        f"recordings_or_samples={len(actual)} procedural=0"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
