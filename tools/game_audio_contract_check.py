#!/usr/bin/env python3
"""Lock physical sound stages, activity ambience, and direct pad control policy."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "game_audio_manifest.json"


def load_json(path: Path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def gd_map(source: str, constant: str) -> dict[str, str]:
    match = re.search(rf"const\s+{re.escape(constant)}\s*=\s*\{{(.*?)\n\}}", source, re.S)
    if not match:
        return {}
    return dict(re.findall(r'^\s*"([a-z0-9_]+)"\s*:\s*"([^"]+)"', match.group(1), re.M))


def gd_numeric_map(source: str, constant: str) -> dict[str, float]:
    match = re.search(rf"const\s+{re.escape(constant)}\s*=\s*\{{(.*?)\n\}}", source, re.S)
    if not match:
        return {}
    return {
        key: float(value)
        for key, value in re.findall(r"^\s*(-?\d+)\s*:\s*(-?[\d.]+)", match.group(1), re.M)
    }


def main() -> int:
    errors: list[str] = []
    manifest = load_json(MANIFEST)
    controller = manifest.get("controller", {})
    if controller.get("gameplay_navigation") != "direct_action_mapping":
        errors.append("gameplay_navigation must remain direct_action_mapping")
    if controller.get("focus_policy") != "settings_and_short_linear_menus_only":
        errors.append("focus policy drifted from last-resort menu use")
    if controller.get("focus_is_last_resort") is not True:
        errors.append("focus_is_last_resort must be true")

    audio_manager_source = (ROOT / "autoloads" / "AudioManager.gd").read_text(encoding="utf-8")
    bgm_player_source = (ROOT / "autoloads" / "BGMPlayer.gd").read_text(encoding="utf-8")
    mapped_sfx = gd_map(audio_manager_source, "_SFX_FILES")
    physical_sfx = manifest.get("physical_sfx", {})
    for key, resource_path in physical_sfx.items():
        if mapped_sfx.get(key) != resource_path:
            errors.append(f"{key}: AudioManager path mismatch")
        disk_path = ROOT / str(resource_path).removeprefix("res://")
        if not disk_path.is_file():
            errors.append(f"{key}: missing audio file {resource_path}")
        if not Path(str(disk_path) + ".import").is_file():
            errors.append(f"{key}: missing Godot import sidecar")

    moral_ambience = manifest.get("moral_ambience", {})
    human_profiles = moral_ambience.get("profiles", {})
    mapped_human = gd_map(bgm_player_source, "HUMAN_AMBIENCE_TRACKS")
    if mapped_human != human_profiles:
        errors.append("moral human ambience profile paths drifted from BGMPlayer")
    for key, resource_path in human_profiles.items():
        disk_path = ROOT / str(resource_path).removeprefix("res://")
        if not disk_path.is_file():
            errors.append(f"human ambience {key}: missing {resource_path}")
        if not Path(str(disk_path) + ".import").is_file():
            errors.append(f"human ambience {key}: missing Godot import sidecar")
    if moral_ambience.get("human_bus") != "GangnamDreamHumanAmbience":
        errors.append("moral human ambience must stay on its isolated bus")
    if 'const _HUMAN_BUS_NAME = "GangnamDreamHumanAmbience"' not in bgm_player_source:
        errors.append("BGMPlayer human ambience bus name drifted")
    expected_gain = {
        str(key): float(value) for key, value in moral_ambience.get("stage_gain_db", {}).items()
    }
    expected_cutoff = {
        str(key): float(value) for key, value in moral_ambience.get("stage_cutoff_hz", {}).items()
    }
    if gd_numeric_map(bgm_player_source, "_MORAL_HUMAN_DB") != expected_gain:
        errors.append("moral human gain stages drifted from manifest")
    if gd_numeric_map(bgm_player_source, "_MORAL_HUMAN_CUTOFFS") != expected_cutoff:
        errors.append("moral human low-pass stages drifted from manifest")

    source_cache: dict[str, str] = {}
    for contract in manifest.get("stage_contracts", []):
        file_name = str(contract.get("file", ""))
        key = str(contract.get("key", ""))
        source = source_cache.setdefault(
            file_name, (ROOT / file_name).read_text(encoding="utf-8")
        )
        if f'"{key}"' not in source:
            errors.append(
                f"{contract.get('system')}:{contract.get('stage')} lacks {key} call in {file_name}"
            )

    for activity, contract in manifest.get("activity_ambience", {}).items():
        file_name = str(contract.get("file", ""))
        key = str(contract.get("key", ""))
        source = source_cache.setdefault(
            file_name, (ROOT / file_name).read_text(encoding="utf-8")
        )
        if "BGMPlayer.enter_activity_ambience(" not in source:
            errors.append(f"{activity}: does not enter activity ambience")
        if "BGMPlayer.leave_activity_ambience(" not in source:
            errors.append(f"{activity}: does not restore idle ambience")
        if key != "dynamic" and f'enter_activity_ambience("{key}")' not in source:
            errors.append(f"{activity}: expected ambience key {key}")

    mapped_bgm = gd_map(bgm_player_source, "TRACKS")
    for activity, contract in manifest.get("activity_music", {}).items():
        file_name = str(contract.get("file", ""))
        source = source_cache.setdefault(
            file_name, (ROOT / file_name).read_text(encoding="utf-8")
        )
        floor_key = str(contract.get("floor_key", ""))
        table_key = str(contract.get("table_key", ""))
        for layer, key in (("floor", floor_key), ("table", table_key)):
            resource_path = str(contract.get(f"{layer}_path", ""))
            if mapped_bgm.get(key) != resource_path:
                errors.append(f"{activity}:{layer} BGMPlayer path mismatch")
            disk_path = ROOT / resource_path.removeprefix("res://")
            if not disk_path.is_file():
                errors.append(f"{activity}:{layer} missing music {resource_path}")
            if not Path(str(disk_path) + ".import").is_file():
                errors.append(f"{activity}:{layer} missing Godot import sidecar")
            else:
                import_text = Path(str(disk_path) + ".import").read_text(encoding="utf-8")
                if "loop=true" not in import_text:
                    errors.append(f"{activity}:{layer} music must loop")
                if f'bpm={int(contract.get("shared_bpm", 0))}' not in import_text:
                    errors.append(f"{activity}:{layer} BPM metadata drifted")
                expected_beats = int(contract.get("shared_bars", 0)) * 4
                if f"beat_count={expected_beats}" not in import_text:
                    errors.append(f"{activity}:{layer} beat metadata drifted")
            if f'enter_casino_music("{layer}")' not in source:
                errors.append(f"{activity}: missing {layer} music transition")
        if "BGMPlayer.leave_casino_music()" not in source:
            errors.append(f"{activity}: casino music does not return to ambient mode")
        if contract.get("phase_locked_crossfade") is not True:
            errors.append(f"{activity}: phase_locked_crossfade must remain true")
        if "_crossfade_to(target_key, true)" not in bgm_player_source:
            errors.append(f"{activity}: runtime no longer preserves motif phase")

    for ban in manifest.get("legacy_stage_bans", []):
        file_name = str(ban.get("file", ""))
        source = source_cache.setdefault(
            file_name, (ROOT / file_name).read_text(encoding="utf-8")
        )
        for key in ban.get("keys", []):
            if re.search(rf'AudioManager\.play(?:_delayed)?\("{re.escape(str(key))}"', source):
                errors.append(f"{file_name}: legacy stage sound still used: {key}")

    scene_by_class = {
        "JeongseonCasino": "scenes/JeongseonCasino.gd",
        "BlackjackTable": "scenes/BlackjackTable.gd",
        "BaccaratTable": "scenes/BaccaratTable.gd",
        "HoldemClub": "scenes/HoldemClub.gd",
        "RouletteTable": "scenes/RouletteTable.gd",
        "DaiSaiTable": "scenes/DaiSaiTable.gd",
        "SlotMachineGame": "scenes/SlotMachineGame.gd",
        "BigWheelGame": "scenes/BigWheelGame.gd",
        "RaceTrack": "scenes/RaceTrack.gd",
    }
    for class_name in controller.get("direct_control_scenes", []):
        file_name = scene_by_class.get(str(class_name), "")
        if not file_name:
            errors.append(f"unknown direct-control scene: {class_name}")
            continue
        source = source_cache.setdefault(
            file_name, (ROOT / file_name).read_text(encoding="utf-8")
        )
        if "func _unhandled_input(" not in source or "_pad_" not in source:
            errors.append(f"{class_name}: lacks direct controller state machine")
        if ".grab_focus(" in source:
            errors.append(f"{class_name}: gameplay regressed to focus traversal")

    if errors:
        for error in errors:
            print("GAME_AUDIO_CONTRACT_FAIL", error)
        return 1
    print(
        "GAME_AUDIO_CONTRACT_OK "
        f"physical={len(physical_sfx)} stages={len(manifest.get('stage_contracts', []))} "
        f"activities={len(manifest.get('activity_ambience', {}))} "
        f"activity_music={len(manifest.get('activity_music', {}))} "
        f"human_layers={len(human_profiles)} "
        f"direct_pad={len(controller.get('direct_control_scenes', []))}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
