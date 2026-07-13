#!/usr/bin/env python3
"""Schema and Korean-leak audit for prepared locale surface dictionaries."""

from __future__ import annotations

import glob
import json
import os
import re
import sys
from typing import Any, Iterable


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANGUAGES = ("ja", "zh-CN", "zh-TW")
CATALOG_SECTIONS = {
    "assets",
    "jobs",
    "items",
    "achievements",
    "clues",
    "thoughts",
    "news",
}
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")


def strings(value: Any) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)
    elif isinstance(value, dict):
        for child in value.values():
            yield from strings(child)


def read_json(path: str, errors: list[str]) -> Any:
    try:
        with open(path, encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: invalid JSON ({exc})")
        return None


def check_no_hangul(path: str, value: Any, errors: list[str]) -> None:
    for text in strings(value):
        if HANGUL.search(text):
            errors.append(f"{path}: Korean leaked into translated value: {text[:60]!r}")


def main() -> int:
    errors: list[str] = []
    for lang in LANGUAGES:
        ui_path = os.path.join(ROOT, "locale", f"ui_{lang}.json")
        ui = read_json(ui_path, errors)
        if not isinstance(ui, dict):
            errors.append(f"{ui_path}: expected object")
        else:
            for key, value in ui.items():
                if not isinstance(key, str) or not isinstance(value, str) or not value.strip():
                    errors.append(f"{ui_path}: UI entries must be non-empty string pairs")
            check_no_hangul(ui_path, list(ui.values()), errors)

        catalog_path = os.path.join(ROOT, "locale", f"catalog_{lang}.json")
        catalog = read_json(catalog_path, errors)
        if not isinstance(catalog, dict):
            errors.append(f"{catalog_path}: expected object")
        else:
            unknown = set(catalog) - CATALOG_SECTIONS
            missing = CATALOG_SECTIONS - set(catalog)
            if unknown:
                errors.append(f"{catalog_path}: unknown sections {sorted(unknown)}")
            if missing:
                errors.append(f"{catalog_path}: missing sections {sorted(missing)}")
            for section, rows in catalog.items():
                if section in CATALOG_SECTIONS and not isinstance(rows, dict):
                    errors.append(f"{catalog_path}:{section}: expected object")
            check_no_hangul(catalog_path, catalog, errors)

        ending_path = os.path.join(ROOT, "content", f"endings_{lang}.json")
        endings = read_json(ending_path, errors)
        if not isinstance(endings, list):
            errors.append(f"{ending_path}: expected array")
        else:
            check_no_hangul(ending_path, endings, errors)

        event_dir = os.path.join(ROOT, "content", f"events_{lang}")
        if not os.path.isdir(event_dir):
            errors.append(f"{event_dir}: missing directory")
        for path in sorted(glob.glob(os.path.join(event_dir, "*.json"))):
            rows = read_json(path, errors)
            if not isinstance(rows, list):
                errors.append(f"{path}: expected array")
            else:
                check_no_hangul(path, rows, errors)

    if errors:
        print(f"Multilingual surface errors: {len(errors)}")
        for error in errors:
            print(f"  {error}")
        return 1
    print("Multilingual surface: clean (ja/zh-CN/zh-TW skeletons and values)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
