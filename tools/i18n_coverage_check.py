#!/usr/bin/env python3
"""Validate localized event/ending overlays without requiring translations early.

EN is always strict because it is a shipping language. Prepared languages validate
every row they contain, but may remain empty until content freeze. Pass --strict to
turn a prepared language into a complete coverage gate.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import sys
from typing import Any


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVENTS_KO = os.path.join(ROOT, "content", "events")
ENDINGS_KO = os.path.join(ROOT, "content", "endings.json")
PREPARED_LANGUAGES = ("ja", "zh-CN", "zh-TW")
ALL_LANGUAGES = ("en",) + PREPARED_LANGUAGES
VARIANTS = (
    "description_orthodox",
    "description_unorthodox",
    "description_low_mental",
    "description_long_gosiwon",
)
TEXT_EVENT_KEYS = {
    "id",
    "title",
    "description",
    "description_if_known",
    "description_if_moral",
    "description_orthodox",
    "description_unorthodox",
    "description_low_mental",
    "description_long_gosiwon",
    "choices",
}
TEXT_CHOICE_KEYS = {"text", "result_text", "text_if_moral"}
TEXT_ENDING_KEYS = {
    "id",
    "title",
    "subtitle",
    "description",
    "description_if_known",
    "detailed_description",
    "epilogue",
    "condition",
}
# Existing EN rows predate the text-only contract. Keep their exact exceptions
# visible and bounded instead of silently allowing gameplay keys in new locales.
EN_LEGACY_EVENT_KEYS = {
    ("kx_us_korea_news", "conditions"),
    ("military_007", "background"),
}


def load_json(path: str) -> Any:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def load_rows(path: str, errors: list[str]) -> list[dict[str, Any]]:
    try:
        data = load_json(path)
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: invalid JSON ({exc})")
        return []
    if not isinstance(data, list):
        errors.append(f"{path}: expected JSON array")
        return []
    rows: list[dict[str, Any]] = []
    for index, row in enumerate(data):
        if not isinstance(row, dict):
            errors.append(f"{path}[{index}]: expected object")
            continue
        rows.append(row)
    return rows


def load_event_directory(path: str, errors: list[str]) -> dict[str, dict[str, Any]]:
    rows: dict[str, dict[str, Any]] = {}
    for filename in sorted(glob.glob(os.path.join(path, "*.json"))):
        for row in load_rows(filename, errors):
            event_id = str(row.get("id", ""))
            if not event_id:
                errors.append(f"{filename}: overlay row has no id")
                continue
            if event_id in rows:
                errors.append(f"{filename}: duplicate id {event_id}")
                continue
            rows[event_id] = row
    return rows


def load_endings(path: str, errors: list[str]) -> dict[str, dict[str, Any]]:
    rows: dict[str, dict[str, Any]] = {}
    for row in load_rows(path, errors):
        ending_id = str(row.get("id", ""))
        if not ending_id:
            errors.append(f"{path}: overlay row has no id")
            continue
        if ending_id in rows:
            errors.append(f"{path}: duplicate id {ending_id}")
            continue
        rows[ending_id] = row
    return rows


def key_parity(base: Any, overlay: Any) -> bool:
    if not isinstance(base, dict) or not base:
        return True
    return isinstance(overlay, dict) and set(base) == set(overlay)


def validate_event(
    lang: str,
    event_id: str,
    base: dict[str, Any],
    overlay: dict[str, Any],
    errors: list[str],
) -> None:
    for key in overlay:
        if key in TEXT_EVENT_KEYS:
            continue
        if lang == "en" and (event_id, key) in EN_LEGACY_EVENT_KEYS:
            continue
        errors.append(f"{lang}:{event_id}: non-text event key {key}")
    for variant in VARIANTS:
        if variant in base and variant not in overlay:
            errors.append(f"{lang}:{event_id}: missing {variant}")
    for field in ("description_if_known", "description_if_moral"):
        if not key_parity(base.get(field), overlay.get(field)):
            errors.append(f"{lang}:{event_id}: {field} key mismatch")

    base_choices = base.get("choices", [])
    overlay_choices = overlay.get("choices", [])
    if not isinstance(base_choices, list):
        base_choices = []
    if not isinstance(overlay_choices, list):
        errors.append(f"{lang}:{event_id}: choices must be an array")
        overlay_choices = []
    if len(overlay_choices) < len(base_choices):
        errors.append(
            f"{lang}:{event_id}: fewer choices {len(overlay_choices)}<{len(base_choices)}"
        )
        return
    for index, base_choice in enumerate(base_choices):
        if not isinstance(base_choice, dict):
            continue
        choice = overlay_choices[index]
        if not isinstance(choice, dict):
            errors.append(f"{lang}:{event_id}: choice {index} is not an object")
            continue
        extra = set(choice) - TEXT_CHOICE_KEYS
        if extra:
            errors.append(
                f"{lang}:{event_id}: choice {index} has non-text keys {sorted(extra)}"
            )
        if not key_parity(base_choice.get("text_if_moral"), choice.get("text_if_moral")):
            errors.append(f"{lang}:{event_id}: choice {index} moral key mismatch")


def check_language(lang: str, strict: bool) -> tuple[list[str], str]:
    errors: list[str] = []
    base_events = load_event_directory(EVENTS_KO, errors)
    overlay_events = load_event_directory(
        os.path.join(ROOT, "content", f"events_{lang}"), errors
    )
    base_endings = load_endings(ENDINGS_KO, errors)
    overlay_endings = load_endings(
        os.path.join(ROOT, "content", f"endings_{lang}.json"), errors
    )

    for event_id in sorted(set(overlay_events) - set(base_events)):
        errors.append(f"{lang}:{event_id}: dead event overlay")
    required_event_ids = {
        event_id
        for event_id, event in base_events.items()
        if "description" in event
    }
    if strict:
        for event_id in sorted(required_event_ids - set(overlay_events)):
            errors.append(f"{lang}:{event_id}: missing event overlay")
    for event_id, overlay in overlay_events.items():
        if event_id in base_events:
            validate_event(lang, event_id, base_events[event_id], overlay, errors)

    for ending_id in sorted(set(overlay_endings) - set(base_endings)):
        errors.append(f"{lang}:ending:{ending_id}: dead ending overlay")
    if strict:
        for ending_id in sorted(set(base_endings) - set(overlay_endings)):
            errors.append(f"{lang}:ending:{ending_id}: missing ending overlay")
    for ending_id, overlay in overlay_endings.items():
        extra = set(overlay) - TEXT_ENDING_KEYS
        if extra:
            errors.append(
                f"{lang}:ending:{ending_id}: non-text keys {sorted(extra)}"
            )
        base = base_endings.get(ending_id, {})
        if not key_parity(
            base.get("description_if_known"), overlay.get("description_if_known")
        ):
            errors.append(f"{lang}:ending:{ending_id}: dik key mismatch")

    mode = "strict" if strict else "skeleton"
    summary = (
        f"{lang} {mode}: {len(overlay_events)}/{len(required_event_ids)} events, "
        f"{len(overlay_endings)}/{len(base_endings)} endings"
    )
    return errors, summary


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--lang", choices=("all",) + ALL_LANGUAGES, default="all")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="require complete event and ending coverage for selected prepared languages",
    )
    args = parser.parse_args()
    languages = ALL_LANGUAGES if args.lang == "all" else (args.lang,)
    all_errors: list[str] = []
    summaries: list[str] = []
    for lang in languages:
        strict = lang == "en" or args.strict
        errors, summary = check_language(lang, strict)
        all_errors.extend(errors)
        summaries.append(summary)
    if all_errors:
        print(f"I18N coverage errors: {len(all_errors)}")
        for error in all_errors:
            print(f"  {error}")
        return 1
    print("I18N coverage: clean (" + "; ".join(summaries) + ")")
    return 0


if __name__ == "__main__":
    sys.exit(main())
