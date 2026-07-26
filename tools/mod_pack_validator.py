#!/usr/bin/env python3
"""Validate Gangnam Dream data mods without launching Godot."""

from __future__ import annotations

import argparse
import glob
import json
import re
import sys
import tempfile
from pathlib import Path
from typing import Any

from event_schedule import DeferredFollowUpError, deferred_follow_ups


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
THEME_DIR = ROOT / "content" / "themes"

EVENT_ROOT_KEYS = {
    "id", "title", "description", "category", "rarity", "weight", "hidden",
    "conditions", "tags", "cooldown", "choices", "portrait", "portrait_if_known",
    "portrait_reveal_paragraph", "background", "paragraph_backgrounds", "cg",
    "cg_if_known", "cg_reveal_paragraph", "speaker", "one_time", "result_cg",
    "result_cg_reveal_paragraph", "result_background", "timed", "timer_seconds",
    "timer_default_choice", "description_orthodox", "description_unorthodox",
    "description_low_mental", "description_long_gosiwon", "description_if_known",
    "description_memory_if_known", "description_if_moral", "direction", "living_scene",
    "year_scene_year", "override",
}
CHOICE_KEYS = {
    "text", "text_if_moral", "effects", "flags", "follow_up_event", "result_text",
    "result_cg", "result_cg_reveal_paragraph", "result_background", "result_ambience",
    "opportunity", "cast_effects", "relationship_effects", "investment_effects",
    "tendency", "route", "grant_job", "conditions_note", "deferred_follow_up",
    "deferred_delay", "foreshadow", "bridge_summary", "clues", "give_items",
    "requires_item", "housing_keepsake", "year_scene",
}
THEME_KEYS = {
    "main": {
        "panel_bg", "panel_border", "chip_bg", "choice_bg", "choice_hover",
        "disabled_bg", "text", "dim", "brand", "focus",
    },
    "story": {
        "panel_bg", "panel_border", "hud_bg", "choice_bg", "choice_hover",
        "text", "dim", "dead", "focus", "line",
    },
}
BANDS = {"black", "gray", "white"}
CATALOG_FILES = {
    "jobs": ROOT / "content" / "jobs.json",
    "assets": ROOT / "content" / "assets.json",
    "items": ROOT / "content" / "items.json",
    "news_templates": ROOT / "content" / "news_templates.json",
}
SCRIPT_EXTENSIONS = {".gd", ".gdshader", ".tscn", ".pck", ".so", ".dll", ".dylib"}
SAFE_ID = re.compile(r"^[a-z0-9_]{1,96}$")
SAFE_MOD_ID = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
HTML_COLOR = re.compile(r"^#[0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?$")


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.event_files = 0
        self.events = 0
        self.preset_files = 0
        self.themes = 0

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)


def load_json(path: Path, report: Report) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        report.error(f"{path}: invalid JSON ({exc})")
        return None


def load_builtin_events() -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for name in glob.glob(str(EVENT_DIR / "*.json")):
        raw = json.loads(Path(name).read_text(encoding="utf-8"))
        rows = raw.get("items", []) if isinstance(raw, dict) else raw
        for row in rows:
            if isinstance(row, dict) and row.get("id"):
                result[str(row["id"])] = row
    return result


def produced_flags(choice: dict[str, Any]) -> set[str]:
    result = {str(value) for value in choice.get("flags", []) if str(value)}
    opportunity = choice.get("opportunity", {})
    if isinstance(opportunity, dict):
        result.update(
            str(opportunity[key])
            for key in ("win_flag", "lose_flag")
            if str(opportunity.get(key, ""))
        )
    cast_effects = choice.get("cast_effects", {})
    if isinstance(cast_effects, dict):
        for value in cast_effects.values():
            if isinstance(value, dict):
                result.update(str(flag) for flag in value.get("flags", []) if str(flag))
    return result


def validate_choice(
    choice: Any,
    label: str,
    report: Report,
    allowed_core_flags: set[str],
    pack_ids: set[str],
) -> None:
    if not isinstance(choice, dict):
        report.error(f"{label}: choice must be an object")
        return
    unknown = set(choice) - CHOICE_KEYS
    if unknown:
        report.error(f"{label}: unsupported choice keys {sorted(unknown)}")
    if not str(choice.get("text", "")).strip():
        report.error(f"{label}: choice text is empty")
    if not str(choice.get("result_text", "")).strip():
        report.error(f"{label}: result_text is empty")
    for flag in produced_flags(choice):
        if not flag.startswith("mod_") and flag not in allowed_core_flags:
            report.error(f"{label}: produced flag '{flag}' must use the mod_ prefix")
    target = str(choice.get("follow_up_event", ""))
    if target and pack_ids and target not in pack_ids:
        report.error(f"{label}: follow_up_event target '{target}' is outside this pack")
    try:
        delayed_links = deferred_follow_ups(choice)
    except DeferredFollowUpError as exc:
        report.error(f"{label}: {exc}")
        delayed_links = []
    for target, _delay in delayed_links:
        if pack_ids and target not in pack_ids:
            report.error(
                f"{label}: deferred_follow_up target '{target}' is outside this pack"
            )


def validate_catalog_value(base: Any, patch: Any, label: str, report: Report) -> None:
    if isinstance(base, dict):
        if not isinstance(patch, dict):
            report.error(f"{label}: expected an object")
            return
        unknown = set(patch) - set(base)
        if unknown:
            report.error(f"{label}: unknown nested fields {sorted(unknown)}")
        for key in set(patch) & set(base):
            validate_catalog_value(base[key], patch[key], f"{label}.{key}", report)
        return
    if isinstance(base, list):
        if not isinstance(patch, list):
            report.error(f"{label}: expected an array")
            return
        if patch and not base:
            report.error(f"{label}: cannot infer item type from an empty built-in array")
            return
        for index, value in enumerate(patch):
            validate_catalog_value(base[0], value, f"{label}[{index}]", report)
        return
    base_is_number = isinstance(base, (int, float)) and not isinstance(base, bool)
    patch_is_number = isinstance(patch, (int, float)) and not isinstance(patch, bool)
    if base_is_number and patch_is_number:
        return
    if type(base) is not type(patch):
        report.error(
            f"{label}: type mismatch, expected {type(base).__name__} "
            f"but received {type(patch).__name__}"
        )


def validate_event_file(path: Path, builtins: dict[str, dict[str, Any]], report: Report) -> None:
    raw = load_json(path, report)
    if raw is None:
        return
    metadata = raw if isinstance(raw, dict) else {}
    if metadata and metadata.get("id") and not SAFE_MOD_ID.fullmatch(str(metadata["id"])):
        report.error(f"{path}: pack id must contain only letters, numbers, '_' or '-'")
    rows = metadata.get("events", []) if isinstance(raw, dict) else raw
    if not isinstance(rows, list):
        report.error(f"{path}: expected an array or an object with an events array")
        return
    report.event_files += 1
    pack_ids = {str(row.get("id", "")) for row in rows if isinstance(row, dict)}
    if len(pack_ids) != len(rows):
        report.error(f"{path}: duplicate, missing, or non-object event ids")
    for index, event in enumerate(rows):
        label = f"{path}:{index}"
        if not isinstance(event, dict):
            report.error(f"{label}: event must be an object")
            continue
        event_id = str(event.get("id", ""))
        if not SAFE_ID.fullmatch(event_id):
            report.error(f"{label}: unsafe event id '{event_id}'")
            continue
        unknown = set(event) - EVENT_ROOT_KEYS
        if unknown:
            report.error(f"{label}: unsupported event keys {sorted(unknown)}")
        choices = event.get("choices", [])
        if not isinstance(choices, list) or not choices:
            report.error(f"{label}: event must have at least one choice")
            continue
        base = builtins.get(event_id)
        if base is not None:
            if not event.get("override", False):
                report.error(f"{label}: built-in id collision requires override=true")
                continue
            base_choices = base.get("choices", [])
            if len(choices) != len(base_choices):
                report.error(f"{label}: override must preserve the built-in choice count")
            for choice_index, choice in enumerate(choices):
                allowed = produced_flags(base_choices[choice_index]) if choice_index < len(base_choices) else set()
                validate_choice(choice, f"{label}.choices[{choice_index}]", report, allowed, set())
        else:
            if not str(event.get("title", "")).strip() or not str(event.get("description", "")).strip():
                report.error(f"{label}: new events require non-empty title and description")
            if event.get("hidden", False) or event.get("category") == "story" \
                    or event.get("rarity") == "story" or float(event.get("weight", 1.0)) <= 0:
                report.error(f"{label}: new events must be visible, positive-weight random events")
            if not isinstance(event.get("conditions", {}), dict):
                report.error(f"{label}: conditions must be an object")
            if not isinstance(event.get("tags", []), list):
                report.error(f"{label}: tags must be an array")
            if int(event.get("cooldown", 3)) < 3:
                report.warn(f"{label}: cooldown will be clamped to 3 at runtime")
            for choice_index, choice in enumerate(choices):
                validate_choice(choice, f"{label}.choices[{choice_index}]", report, set(), pack_ids)
        report.events += 1


def catalog_index(path: Path) -> dict[str, dict[str, Any]]:
    return {str(row["id"]): row for row in json.loads(path.read_text(encoding="utf-8"))}


def validate_preset(path: Path, report: Report) -> None:
    raw = load_json(path, report)
    if not isinstance(raw, dict):
        report.error(f"{path}: balance preset must be an object")
        return
    if raw.get("id") and not SAFE_MOD_ID.fullmatch(str(raw["id"])):
        report.error(f"{path}: preset id must contain only letters, numbers, '_' or '-'")
    known_meta = {"id", "name", "version", "author", "description"}
    unknown_sections = set(raw) - known_meta - set(CATALOG_FILES)
    if unknown_sections:
        report.error(f"{path}: unsupported preset sections {sorted(unknown_sections)}")
    for section, catalog_path in CATALOG_FILES.items():
        patches = raw.get(section, [])
        if not isinstance(patches, list):
            report.error(f"{path}: {section} must be an array")
            continue
        index = catalog_index(catalog_path)
        for row_index, patch in enumerate(patches):
            label = f"{path}:{section}[{row_index}]"
            if not isinstance(patch, dict):
                report.error(f"{label}: patch must be an object")
                continue
            row_id = str(patch.get("id", ""))
            if row_id not in index:
                report.error(f"{label}: unknown built-in id '{row_id}'")
                continue
            unknown_fields = set(patch) - set(index[row_id])
            if unknown_fields:
                report.error(f"{label}: unknown fields {sorted(unknown_fields)}")
            for key in set(patch) & set(index[row_id]) - {"id"}:
                validate_catalog_value(index[row_id][key], patch[key], f"{label}.{key}", report)
    report.preset_files += 1


def validate_theme(path: Path, report: Report) -> None:
    raw = load_json(path, report)
    if not isinstance(raw, dict):
        report.error(f"{path}: theme must be an object")
        return
    surfaces = raw.get("surfaces")
    if not isinstance(surfaces, dict) or set(surfaces) != set(THEME_KEYS):
        report.error(f"{path}: theme surfaces must be exactly {sorted(THEME_KEYS)}")
        return
    for surface, expected_keys in THEME_KEYS.items():
        bands = surfaces.get(surface)
        if not isinstance(bands, dict) or set(bands) != BANDS:
            report.error(f"{path}: {surface} bands must be exactly {sorted(BANDS)}")
            continue
        for band, colors in bands.items():
            if not isinstance(colors, dict) or set(colors) != expected_keys:
                report.error(f"{path}: {surface}.{band} must contain only the fixed palette keys")
                continue
            for key, value in colors.items():
                if not isinstance(value, str) or not HTML_COLOR.fullmatch(value):
                    report.error(f"{path}: {surface}.{band}.{key} is not #RRGGBB or #RRGGBBAA")
    report.themes += 1


def validate_target(target: Path, report: Report) -> None:
    if target.is_file():
        parent = target.parent.name.lower()
        if parent == "events":
            validate_event_file(target, load_builtin_events(), report)
        elif parent == "presets":
            validate_preset(target, report)
        elif parent == "themes":
            validate_theme(target, report)
        else:
            report.error(f"{target}: place the file under events/, presets/, or themes/")
        return
    if not target.is_dir():
        report.error(f"{target}: path does not exist")
        return
    for path in target.rglob("*"):
        if path.is_file() and path.suffix.lower() in SCRIPT_EXTENSIONS:
            report.error(f"{path}: executable/script resources are not supported")
    builtins = load_builtin_events()
    for path in sorted((target / "events").glob("*.json")):
        validate_event_file(path, builtins, report)
    for path in sorted((target / "presets").glob("*.json")):
        validate_preset(path, report)
    for path in sorted((target / "themes").glob("*.json")):
        validate_theme(path, report)


def run_self_test(report: Report) -> None:
    for path in sorted(THEME_DIR.glob("moral_ui_*.json")):
        validate_theme(path, report)
    with tempfile.TemporaryDirectory(prefix="gangnam-mod-validator-") as temp:
        root = Path(temp)
        (root / "events").mkdir()
        (root / "presets").mkdir()
        valid_event = [{
            "id": "mod_validator_event",
            "title": "Validator",
            "description": "A data-only test event.",
            "category": "daily_life",
            "rarity": "common",
            "weight": 1.0,
            "hidden": False,
            "conditions": {},
            "tags": ["daily"],
            "cooldown": 3,
            "choices": [{
                "text": "Continue",
                "effects": {"mental": 1},
                "flags": ["mod_validator_seen"],
                "result_text": "Done.",
            }],
        }]
        (root / "events" / "valid.json").write_text(json.dumps(valid_event), encoding="utf-8")
        valid_preset = {"id": "validator", "jobs": [{"id": "job_01", "base_salary": 1320001}]}
        (root / "presets" / "valid.json").write_text(json.dumps(valid_preset), encoding="utf-8")
        validate_target(root, report)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?", help="mod root or one JSON file")
    parser.add_argument("--self-test", action="store_true", help="validate bundled schemas and fixtures")
    args = parser.parse_args()
    report = Report()
    if args.self_test:
        run_self_test(report)
    elif args.path:
        validate_target(Path(args.path).expanduser().resolve(), report)
    else:
        parser.error("provide a mod path or --self-test")
    for warning in report.warnings:
        print(f"WARNING: {warning}")
    for error in report.errors:
        print(f"ERROR: {error}")
    if report.errors:
        print(f"MOD_PACK_VALIDATOR_FAIL errors={len(report.errors)} warnings={len(report.warnings)}")
        return 1
    print(
        "MOD_PACK_VALIDATOR_OK "
        f"event_files={report.event_files} events={report.events} "
        f"presets={report.preset_files} themes={report.themes} warnings={len(report.warnings)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
