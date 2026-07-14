#!/usr/bin/env python3
"""Strict source-to-overlay gate for the Japanese beta localization."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
from typing import Any

from ja_translation_pipeline import (
    EXACT_TRANSLATIONS,
    ROOT,
    Entry,
    collect_catalog,
    collect_endings,
    collect_events,
    collect_ui,
    validate_translation,
)


JAPANESE = re.compile(r"[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]")
TERM_REQUIREMENTS = {
    "강남": "カンナム",
    "고시원": "コシウォン",
    "전세": "チョンセ",
    "오빠": "オッパ",
    "한PD건설": "ハンPD建設",
    "정선 카지노": "チョンソン・カジノ",
    "한성전자": "ハンソン電子",
    "대현차": "テヒョン自動車",
    "코어코인": "コアコイン",
    "노바코인": "ノヴァコイン",
}
FORBIDDEN_OUTPUT = (
    "コスピ",
    "ダエン",
    "ジヨンヌ",
    "お兄さん",
    "ヴィラ",
    "ギャンリング",
    "トライフル",
    "トライプル",
    "カンナム入城",
)


def read_json(path: pathlib.Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def actual_events() -> dict[str, Any]:
    return {
        path.name: read_json(path)
        for path in sorted((ROOT / "content/events_ja").glob("*.json"))
    }


def check_text(entry: Entry, translated: Any, errors: list[str]) -> None:
    for error in validate_translation(entry, translated):
        errors.append(f"{entry.key}: {error}")
    if not isinstance(translated, str):
        return
    exact = EXACT_TRANSLATIONS.get(entry.source)
    if exact is not None and translated != exact:
        errors.append(f"{entry.key}: exact-canon mismatch {translated!r} != {exact!r}")
    for korean, japanese in TERM_REQUIREMENTS.items():
        if korean in entry.source and japanese not in translated:
            errors.append(f"{entry.key}: {korean!r} must remain {japanese!r}")
    for term in FORBIDDEN_OUTPUT:
        if term in translated:
            errors.append(f"{entry.key}: forbidden Japanese term {term!r}")
    if "트리플" in entry.source and "トリプル" not in translated:
        errors.append(f"{entry.key}: dice triple must use 'トリプル'")
    if "잠금" in entry.source and "解除" in translated:
        errors.append(f"{entry.key}: lock polarity reversed by '解除'")
    if "해금" in entry.source and "解除" in translated:
        errors.append(f"{entry.key}: game unlock must use '解放' or 'アンロック'")
    if "강남드림" not in entry.source and "カンナム・ドリーム" in translated:
        errors.append(f"{entry.key}: place name '강남' was expanded into the game title")
    if exact is None and re.search(r"[가-힣]", entry.source) and len(entry.source) >= 4:
        if not JAPANESE.search(translated):
            errors.append(f"{entry.key}: no Japanese glyphs in translated Korean source")


def walk_blueprint(
    path: str,
    blueprint: Any,
    actual: Any,
    entries: dict[str, Entry],
    errors: list[str],
) -> None:
    if isinstance(blueprint, dict) and set(blueprint) == {"$entry"}:
        entry_key = blueprint["$entry"]
        entry = entries.get(entry_key)
        if entry is None:
            errors.append(f"{path}: blueprint references unknown entry {entry_key}")
            return
        check_text(entry, actual, errors)
        return
    if isinstance(blueprint, dict):
        if not isinstance(actual, dict):
            errors.append(f"{path}: expected object, got {type(actual).__name__}")
            return
        expected_keys = set(blueprint)
        actual_keys = set(actual)
        if expected_keys != actual_keys:
            errors.append(
                f"{path}: key mismatch missing={sorted(expected_keys-actual_keys)[:8]} "
                f"extra={sorted(actual_keys-expected_keys)[:8]}"
            )
        for key in sorted(expected_keys & actual_keys):
            walk_blueprint(f"{path}.{key}", blueprint[key], actual[key], entries, errors)
        return
    if isinstance(blueprint, list):
        if not isinstance(actual, list):
            errors.append(f"{path}: expected array, got {type(actual).__name__}")
            return
        if len(blueprint) != len(actual):
            errors.append(f"{path}: array length {len(actual)} != {len(blueprint)}")
        for index, (expected, translated) in enumerate(zip(blueprint, actual)):
            walk_blueprint(f"{path}[{index}]", expected, translated, entries, errors)
        return
    if blueprint != actual:
        errors.append(f"{path}: literal mismatch {actual!r} != {blueprint!r}")


def check_scope(
    name: str,
    collector,
    actual: Any,
    errors: list[str],
) -> int:
    rows, blueprint = collector()
    entries = {entry.key: entry for entry in rows}
    before = len(errors)
    walk_blueprint(name, blueprint, actual, entries, errors)
    print(
        f"JA_AUDIT_SCOPE name={name} strings={len(rows)} errors={len(errors)-before}"
    )
    return len(rows)


def check_beta_visibility(errors: list[str]) -> None:
    source = (ROOT / "autoloads/LocaleManager.gd").read_text(encoding="utf-8")
    match = re.search(r"SHIPPING_LANGUAGES[^=]*=\s*\[([^\]]*)\]", source)
    if not match:
        errors.append("LocaleManager: SHIPPING_LANGUAGES declaration not found")
    elif re.search(r'["\']ja["\']', match.group(1)):
        errors.append("LocaleManager: Japanese exposed before native spotcheck approval")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--scope",
        choices=("all", "events", "endings", "ui", "catalog"),
        default="all",
    )
    args = parser.parse_args()
    errors: list[str] = []
    total = 0
    scopes = ("events", "endings", "ui", "catalog") if args.scope == "all" else (args.scope,)
    if "events" in scopes:
        total += check_scope("events", collect_events, actual_events(), errors)
    if "endings" in scopes:
        total += check_scope(
            "endings",
            collect_endings,
            read_json(ROOT / "content/endings_ja.json"),
            errors,
        )
    if "ui" in scopes:
        total += check_scope(
            "ui",
            collect_ui,
            read_json(ROOT / "locale/ui_ja.json"),
            errors,
        )
    if "catalog" in scopes:
        total += check_scope(
            "catalog",
            collect_catalog,
            read_json(ROOT / "locale/catalog_ja.json"),
            errors,
        )
    check_beta_visibility(errors)
    if errors:
        print(f"JA translation audit errors: {len(errors)}")
        for error in errors[:300]:
            print(f"  {error}")
        if len(errors) > 300:
            print(f"  ... {len(errors)-300} more")
        return 1
    print(f"JA translation audit: clean strings={total} status=beta")
    return 0


if __name__ == "__main__":
    sys.exit(main())
