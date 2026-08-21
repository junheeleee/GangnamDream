#!/usr/bin/env python3
"""Lock every shipping event and rendered background to an audio intent.

The catalog is intentionally explicit. New events and backgrounds fail this
gate until a developer regenerates/reviews the index; runtime prose is never
used to guess a place.
"""

from __future__ import annotations

import argparse
import glob
import json
import re
import sys
from pathlib import Path
from typing import Any

from event_lifecycle import audit_author_only


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "assets" / "scene_audio_manifest.json"
IMAGE_REGISTRY_PATH = ROOT / "autoloads" / "ImageRegistry.gd"
EVENT_DIR = ROOT / "content" / "events"
EVENT_EN_DIR = ROOT / "content" / "events_en"
INTENT_GROUPS = {
    "event_contract",
    "cg_contract",
    "rendered_profile",
    "intentional_silence",
}


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def load_events(directory: Path) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for raw_path in sorted(glob.glob(str(directory / "*.json"))):
        payload = load_json(Path(raw_path))
        if not isinstance(payload, list):
            continue
        for event in payload:
            if not isinstance(event, dict) or not event.get("id"):
                continue
            events[str(event["id"])] = event
    return events


def background_ids() -> set[str]:
    source = IMAGE_REGISTRY_PATH.read_text(encoding="utf-8")
    try:
        block = source.split("const BACKGROUNDS = {", 1)[1].split("\n}", 1)[0]
    except IndexError as exc:
        raise ValueError("ImageRegistry BACKGROUNDS could not be parsed") from exc
    return set(re.findall(r'^\s*"([^"]+)"\s*:', block, re.M))


def build_intents(
    events: dict[str, dict[str, Any]],
    event_contracts: dict[str, Any],
    cg_contracts: dict[str, Any],
) -> dict[str, list[str]]:
    intents: dict[str, list[str]] = {key: [] for key in INTENT_GROUPS}
    for event_id in sorted(events):
        event = events[event_id]
        if event_id in event_contracts:
            intents["event_contract"].append(event_id)
            continue
        cg_id = str(event.get("cg", "")).strip()
        if cg_id and cg_id in cg_contracts:
            intents["cg_contract"].append(event_id)
            continue
        intents["rendered_profile"].append(event_id)
    return intents


def format_string_list(values: list[str], indent: str = "    ") -> str:
    if not values:
        return "[]"
    lines = ["["]
    for offset in range(0, len(values), 4):
        chunk = values[offset : offset + 4]
        suffix = "," if offset + 4 < len(values) else ""
        lines.append(
            indent + "  " + ", ".join(json.dumps(item) for item in chunk) + suffix
        )
    lines.append(indent + "]")
    return "\n".join(lines)


def write_intents(
    manifest: dict[str, Any],
    events: dict[str, dict[str, Any]],
) -> None:
    event_contracts = manifest.get("events", {})
    cg_contracts = manifest.get("cg", {})
    if not isinstance(event_contracts, dict) or not isinstance(cg_contracts, dict):
        raise ValueError("scene manifest events/cg must be objects")
    generated = build_intents(events, event_contracts, cg_contracts)
    existing = manifest.get("event_intents", {})
    manual_silence = (
        existing.get("intentional_silence", [])
        if isinstance(existing, dict)
        else []
    )
    if isinstance(manual_silence, list):
        silence = sorted(
            event_id for event_id in manual_silence if event_id in events
        )
        generated["intentional_silence"] = silence
        generated["rendered_profile"] = [
            event_id
            for event_id in generated["rendered_profile"]
            if event_id not in set(silence)
        ]

    block_lines = ['  "event_intents": {']
    group_order = [
        "event_contract",
        "cg_contract",
        "rendered_profile",
        "intentional_silence",
    ]
    for index, group in enumerate(group_order):
        formatted = format_string_list(generated[group])
        formatted = formatted.replace("\n", "\n    ")
        comma = "," if index < len(group_order) - 1 else ""
        block_lines.append(f'    "{group}": {formatted}{comma}')
    block_lines.append("  },")
    block = "\n".join(block_lines) + "\n"

    raw = MANIFEST_PATH.read_text(encoding="utf-8")
    if '"event_intents"' in raw:
        raw = re.sub(
            r'  "event_intents": \{.*?\n  \},\n(?=  "cg": \{)',
            block,
            raw,
            count=1,
            flags=re.S,
        )
    else:
        raw = raw.replace('  "cg": {', block + '  "cg": {', 1)
    MANIFEST_PATH.write_text(raw, encoding="utf-8")


def validate(manifest: dict[str, Any], write: bool) -> list[str]:
    errors: list[str] = []
    all_events = load_events(EVENT_DIR)
    all_events_en = load_events(EVENT_EN_DIR)
    lifecycle = audit_author_only(ROOT)
    errors.extend(
        f"author-only lifecycle: {message}" for message in lifecycle.errors
    )
    if set(all_events) != set(all_events_en):
        missing_en = sorted(set(all_events) - set(all_events_en))
        stale_en = sorted(set(all_events_en) - set(all_events))
        if missing_en:
            errors.append("English event catalog missing: " + ", ".join(missing_en))
        if stale_en:
            errors.append("English event catalog stale: " + ", ".join(stale_en))

    events = {
        event_id: event
        for event_id, event in all_events.items()
        if event_id in lifecycle.product_event_ids
    }
    events_en = {
        event_id: event
        for event_id, event in all_events_en.items()
        if event_id in lifecycle.product_event_ids
    }

    # Never regenerate the shipping manifest from a lifecycle/parity-invalid
    # source corpus. Invalid declarations remain product events by design, but
    # accepting that enlarged set here would overwrite the reviewed contract.
    if write and errors:
        return errors
    if write:
        write_intents(manifest, events)
        manifest = load_json(MANIFEST_PATH)

    backgrounds = background_ids()
    profiles = manifest.get("background_profiles", {})
    if not isinstance(profiles, dict):
        return ["background_profiles must be an object"]
    missing_profiles = sorted(backgrounds - set(profiles))
    stale_profiles = sorted(set(profiles) - backgrounds)
    if missing_profiles:
        errors.append("backgrounds lack audio profile: " + ", ".join(missing_profiles))
    if stale_profiles:
        errors.append("stale background audio profiles: " + ", ".join(stale_profiles))
    for background_id, profile in profiles.items():
        if not isinstance(profile, str) or not profile.strip():
            errors.append(f"{background_id}: background profile must be a nonempty key")

    intents_raw = manifest.get("event_intents", {})
    if not isinstance(intents_raw, dict):
        return errors + ["event_intents must be an object"]
    unknown_groups = sorted(set(intents_raw) - INTENT_GROUPS)
    if unknown_groups:
        errors.append("unknown event-intent groups: " + ", ".join(unknown_groups))
    grouped: dict[str, list[str]] = {}
    for group in sorted(INTENT_GROUPS):
        values = intents_raw.get(group, [])
        if not isinstance(values, list) or any(not isinstance(item, str) for item in values):
            errors.append(f"event_intents.{group} must be a string array")
            grouped[group] = []
            continue
        grouped[group] = values
        if len(values) != len(set(values)):
            errors.append(f"event_intents.{group} contains duplicates")

    owners: dict[str, str] = {}
    for group, values in grouped.items():
        for event_id in values:
            if event_id in owners:
                errors.append(
                    f"{event_id}: audio intent appears in {owners[event_id]} and {group}"
                )
            owners[event_id] = group
    missing_intents = sorted(set(events) - set(owners))
    stale_intents = sorted(set(owners) - set(events))
    if missing_intents:
        errors.append("events lack audio intent: " + ", ".join(missing_intents))
    if stale_intents:
        errors.append("stale event audio intents: " + ", ".join(stale_intents))

    event_contracts = manifest.get("events", {})
    cg_contracts = manifest.get("cg", {})
    for event_id, source in owners.items():
        event = events.get(event_id, {})
        if source == "event_contract" and event_id not in event_contracts:
            errors.append(f"{event_id}: event-contract intent has no event contract")
        if source == "cg_contract":
            cg_id = str(event.get("cg", ""))
            if not cg_id or cg_id not in cg_contracts:
                errors.append(f"{event_id}: CG-contract intent has no contracted CG")

    for event_id in sorted(set(all_events) & set(all_events_en)):
        ko = all_events[event_id]
        en = all_events_en[event_id]
        for field in ("background", "cg"):
            if field in en and en.get(field) != ko.get(field):
                errors.append(
                    f"{event_id}: English {field} changes the Korean audio surface"
                )

    if errors:
        return errors
    print(
        "SCENE_AUDIO_CATALOG_OK "
        f"events={len(events)} backgrounds={len(backgrounds)} "
        f"authored={len(grouped.get('event_contract', [])) + len(grouped.get('cg_contract', []))} "
        f"profiled={len(grouped.get('rendered_profile', []))} "
        f"silence={len(grouped.get('intentional_silence', []))} parity=ko/en"
    )
    return []


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="regenerate the reviewed event-intent index before validating",
    )
    args = parser.parse_args()
    try:
        manifest = load_json(MANIFEST_PATH)
        errors = validate(manifest, args.write)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"SCENE_AUDIO_CATALOG_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        for error in errors:
            print(f"SCENE_AUDIO_CATALOG_FAIL {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
