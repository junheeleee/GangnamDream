#!/usr/bin/env python3
"""Strict source-to-overlay gate for the Japanese beta localization."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import sys
from typing import Any

from ja_translation_pipeline import (
    ROOT,
    Entry,
    collect_catalog,
    collect_endings,
    collect_events,
    collect_ui_inventory,
    exact_translation_for_entry,
    premature_context_dictionary_keys,
    validate_translation,
)


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
    exact = exact_translation_for_entry(entry)
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


def _demo_runtime(errors: list[str]) -> tuple[dict[str, Any], dict[str, Any]]:
    import demo_localization_scope as demo_scope

    observed, runtime, scope_errors = demo_scope.build_scope()
    manifest = read_json(ROOT / "content/meta/demo_localization_scope.json")
    scope_errors.extend(demo_scope.compare_contract(
        manifest.get("source_contract"), observed
    ))
    scope_errors.extend(demo_scope.boundary_errors(
        runtime["event_ids"], manifest
    ))
    errors.extend(f"demo source: {error}" for error in scope_errors)
    return observed, runtime


def check_ui_scope(actual: Any, errors: list[str]) -> int:
    """Keep retail UI exact while recognizing separately owned demo surfaces."""
    inventory = collect_ui_inventory()
    rows, blueprint = inventory.entries, inventory.blueprint
    entries = {entry.key: entry for entry in rows}
    before = len(errors)
    errors.extend(f"ui source: {error}" for error in inventory.errors)
    if not isinstance(actual, dict):
        errors.append("ui: expected object")
        actual = {}
    required_actual = {
        key: actual[key] for key in blueprint if key in actual
    }
    walk_blueprint("ui", blueprint, required_actual, entries, errors)

    _observed, runtime = _demo_runtime(errors)
    dynamic_keys = set(runtime["merged_pairs"])
    static_keys = set(blueprint)
    extra_keys = set(actual) - static_keys
    # ORDER-126's isolated M01-M06 controller is not part of the retail UI
    # denominator.  Its exact source/key count and target coverage belong to
    # story_demo_localization_audit; reuse that fail-closed source collector
    # here instead of copying its strings into a second allowlist.
    import story_demo_localization_audit as story_demo

    story_demo_pairs, story_demo_errors, _story_demo_counts = story_demo.ui_pairs()
    errors.extend(
        f"story demo UI source: {error}" for error in story_demo_errors
    )
    story_demo_keys = set(story_demo_pairs)
    story_demo_exclusive_keys = story_demo_keys - static_keys - dynamic_keys
    premature_context = set(premature_context_dictionary_keys(actual, inventory))
    if premature_context:
        errors.append(
            "ui: planned context rows appeared before implementation "
            f"{sorted(premature_context)[:8]}"
        )
    unknown_extra = (
        extra_keys - dynamic_keys - story_demo_exclusive_keys
        - premature_context
    )
    if unknown_extra:
        errors.append(
            f"ui: unknown extra keys count={len(unknown_extra)} "
            f"preview={sorted(unknown_extra)[:8]}"
        )
    for korean in sorted(extra_keys & dynamic_keys):
        entry = Entry(
            f"demo-ui::{hashlib.sha1(korean.encode()).hexdigest()[:12]}",
            korean,
            "24-week dynamic UI",
        )
        check_text(entry, actual[korean], errors)
    for korean in sorted(extra_keys & story_demo_exclusive_keys):
        pair = story_demo_pairs[korean]
        entry = Entry(
            f"story-demo-ui::{hashlib.sha1(korean.encode()).hexdigest()[:12]}",
            korean,
            pair.owner,
            format_template=pair.format_template,
        )
        check_text(entry, actual[korean], errors)
    dynamic_present = len(dynamic_keys & set(actual))
    story_demo_exclusive_present = len(
        story_demo_exclusive_keys & set(actual)
    )
    legacy_present = len(set(inventory.legacy_blueprint) & set(actual))
    context_present = len(set(inventory.planned_context_blueprint) & set(actual))
    stats = inventory.stats
    print(
        "JA_AUDIT_SCOPE name=ui "
        f"legacy={legacy_present}/{len(inventory.legacy_blueprint)} "
        f"context={context_present}/{len(inventory.planned_context_blueprint)} "
        f"migrated={stats['migrated_context_ids']}/"
        f"{stats['planned_context_ids']} "
        f"demo_dynamic={dynamic_present}/{len(dynamic_keys)} "
        f"story_demo_extra={story_demo_exclusive_present}/"
        f"{len(story_demo_exclusive_keys)} "
        f"errors={len(errors)-before}"
    )
    return len(rows)


def check_demo_scope(strict: bool, errors: list[str]) -> int:
    import demo_localization_scope as demo_scope

    observed, runtime = _demo_runtime(errors)
    before = len(errors)
    result, scope_errors = demo_scope.language_coverage("ja", runtime, strict)
    errors.extend(scope_errors)
    print(
        "JA_AUDIT_SCOPE name=demo "
        f"events={result['events']}/{result['total_events']} "
        f"strings={result['event_strings']}/{result['total_event_strings']} "
        f"dynamic={result['dynamic']}/{result['total_dynamic']} "
        f"catalog={result['catalog']}/{result['total_catalog']} "
        f"mode={'strict' if strict else 'skeleton'} "
        f"errors={len(errors)-before}"
    )
    return (
        observed["event_text_count"]
        + observed["dynamic_unique_keys"]
        + len(observed["catalog_asset_name_ids"])
    )


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
        choices=("all", "demo", "events", "endings", "ui", "catalog"),
        default="all",
    )
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors: list[str] = []
    total = 0
    if args.strict and args.scope != "demo":
        parser.error("--strict is available only with --scope demo")
    scopes = ("events", "endings", "ui", "catalog") if args.scope == "all" else (args.scope,)
    if "demo" in scopes:
        total += check_demo_scope(args.strict, errors)
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
        total += check_ui_scope(read_json(ROOT / "locale/ui_ja.json"), errors)
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
