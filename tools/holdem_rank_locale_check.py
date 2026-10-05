#!/usr/bin/env python3
"""Exact Chinese poker rank UI contract; fresh collectors, no historical suite."""
from __future__ import annotations

from dataclasses import replace
import json
from pathlib import Path
import re
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
import full_game_localization as exchange
import ja_translation_pipeline as ja
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]
SOURCES = ("하이카드", "원페어", "투페어", "트리플", "스트레이트", "플러시",
           "풀하우스", "포카드", "스트레이트 플러시")
TARGETS = {
    "zh-CN": ("高牌", "一对", "两对", "三条", "顺子", "同花", "葫芦", "四条", "同花顺"),
    "zh-TW": ("高牌", "一對", "兩對", "三條", "順子", "同花", "葫蘆", "四條", "同花順"),
}


def check() -> tuple[list[str], int]:
    errors: list[str] = []
    count = 0

    def expect(name: str, condition: bool, detail: object = "") -> None:
        nonlocal count
        count += 1
        if not condition:
            errors.append(f"{name}: {detail}")

    # Observe the real collector used by the exchange, retaining its exact UI
    # inventory for the legacy UI validation caller. Do not fabricate entries.
    inventories = []
    collect_ui = ja.collect_ui_inventory

    def observe_inventory(*args, **kwargs):
        result = collect_ui(*args, **kwargs)
        inventories.append(result)
        return result

    with patch.object(ja, "collect_ui_inventory", side_effect=observe_inventory):
        collected = exchange.collect()
    expect("collector UI calls", len(inventories) == 1, len(inventories))
    if len(inventories) != 1:
        return errors, count
    inventory = inventories[0]
    expect("collector errors", not inventory.errors, inventory.errors)
    leaves = {leaf.source: leaf for leaf in collected["leaves"] if leaf.group == "ui"
              and leaf.source in SOURCES and leaf.owner == leaf.source}
    entries = {entry.source: entry for entry in inventory.legacy_entries if entry.source in SOURCES}
    expect("nine source leaves", set(leaves) == set(entries) == set(SOURCES), list(leaves))
    if set(leaves) != set(SOURCES) or set(entries) != set(SOURCES):
        return errors, count
    rank_source = (ROOT / "systems/TexasHoldem.gd").read_text(encoding="utf-8")
    rank_body = rank_source.split("static func rank_name(rank: int) -> String:\n", 1)[1].split("\nstatic func ", 1)[0]
    mapping = [(int(rank), json.loads(source)) for rank, source in re.findall(
        r'^\s*([0-8]): return LocaleManager\.ui\(("(?:\\.|[^"\\])*")\s*,', rank_body, re.M)]
    expect("runtime ordered rank mapping", mapping == list(enumerate(SOURCES)), mapping)
    print("HOLDEM_RANK_SOURCE " + json.dumps({
        "source_manifest_sha256": collected["source_manifest_sha256"],
        "rank_source_sha256": exchange.sha_file(ROOT / "systems/TexasHoldem.gd"),
        "collector_calls": len(inventories), "ranks": mapping,
    }, ensure_ascii=False))

    def paths(locale, leaf, target):
        return (
            zh.validate_text(locale, leaf.id, leaf.source, target),
            exchange.translation_errors(leaf, locale, target),
            zh._legacy_ui_text_errors(locale, leaf.id, leaf.source, target,
                                      inventory, entries.get(leaf.source)),
        )

    for rank, source in enumerate(SOURCES):
        leaf = leaves[source]
        expect(f"identity/{rank}", leaf.id == f"ui:{source}:/{source}"
               and leaf.source_path == "runtime:static_ui" and not leaf.format_template,
               repr(leaf))
        calls = [call for call in inventory.calls if call.korean == source
                 and call.path == "systems/TexasHoldem.gd" and call.function == "rank_name"]
        expect(f"runtime call/{rank}", len(calls) == 1, calls)
        for locale, targets in TARGETS.items():
            target = targets[rank]
            label = f"{locale}/{rank}"
            adapted = zh._ui_holdem_rank_numbers(locale, leaf.id, source, target)
            expect(label + "/ordinal", adapted == (str(rank), str(rank), []), adapted)
            result = paths(locale, leaf, target)
            expect(label + "/nominal three callers", not any(result), result)
            with patch.object(zh, "_ui_holdem_rank_numbers", return_value=None):
                original = paths(locale, leaf, target)
            if rank == 3:
                expect(label + "/original false positive", all(any(
                    "unmatched target entity quantity invented: 3" in error for error in part
                ) for part in original), original)
            for wrong_rank, wrong in enumerate(targets):
                if wrong_rank != rank:
                    result = paths(locale, leaf, wrong)
                    expect(label + f"/wrong rank {wrong_rank}", all(result), result)
            other_locale = "zh-TW" if locale == "zh-CN" else "zh-CN"
            if TARGETS[other_locale][rank] != target:
                result = paths(locale, leaf, TARGETS[other_locale][rank])
                expect(label + "/wrong regional script", all(result), result)
            variants = [target + suffix for suffix in (
                "3", "三条", "+3", "-3", "3%", "３", " ", "\n", "\n\n",
                "%s", "[b]", "韩元", "韓元", "￥2", "한글", "カナ", " High Card",
            )] + [" " + target, "\t" + target, "", None, 3, [target], {"text": target}]
            for number, wrong in enumerate(variants):
                result = paths(locale, leaf, wrong)
                adapted = zh._ui_holdem_rank_numbers(locale, leaf.id, source, wrong)
                expect(label + f"/mutation {number}", all(result) and adapted is not None
                       and bool(adapted[2]), (adapted, result))
            # Out-of-scope identity must neither acquire the adapter nor change
            # the original validators' outcome (including pre-existing errors).
            boundaries = [
                replace(leaf, owner="other_rank"), replace(leaf, path=("other_rank",)),
                replace(leaf, group="events"), replace(leaf, group="catalog"),
                replace(leaf, source=source + " "), replace(leaf, source=" " + source),
                replace(leaf, source=SOURCES[(rank + 1) % len(SOURCES)]),
            ]
            for number, outside in enumerate(boundaries):
                adapted = zh._ui_holdem_rank_numbers(locale, outside.id, outside.source, target)
                result = paths(locale, outside, target)
                with patch.object(zh, "_ui_holdem_rank_numbers", return_value=None):
                    original = paths(locale, outside, target)
                expect(label + f"/boundary {number}", adapted is None and result == original,
                       (adapted, result, original))

    # Require independent diagnostics, not just the new exact-name rejection.
    for locale in TARGETS:
        leaf = leaves["트리플"]
        target = TARGETS[locale][3]
        for suffix, diagnostic in (
            (" %s", "placeholder/BBCode mismatch"), ("[b]", "placeholder/BBCode mismatch"),
            ("\n", "newline mismatch"), ("\n\n", "paragraph mismatch"),
            ("한글", "Hangul remains"), ("カナ", "Japanese kana remains"),
            (" ￥2", "Korean won was relabeled as yen/yuan/Taiwan dollar"),
        ):
            result = paths(locale, leaf, target + suffix)
            expect(locale + "/preserve " + diagnostic, all(any(diagnostic in error
                   for error in part) for part in result), result)
        for source, translated, passed in (
            ("커피 두 잔", "两杯咖啡" if locale == "zh-CN" else "兩杯咖啡", True),
            ("커피 두 잔", "两次咖啡" if locale == "zh-CN" else "兩次咖啡", False),
            ("트리플", target + " 3", False),
        ):
            leaf = exchange.Leaf("ui", source, "runtime:static_ui", (source,), source, "ui_static_context")
            result = paths(locale, leaf, translated)
            expect(locale + "/neighbor " + translated, all(bool(part) != passed for part in result), result)
    for locale in ("ja", "en", "zh", "zh-Hans", "zh-Hant"):
        leaf = leaves["트리플"]
        target = TARGETS["zh-TW"][3]
        adapted = zh._ui_holdem_rank_numbers(locale, leaf.id, leaf.source, target)
        result = paths(locale, leaf, target)
        with patch.object(zh, "_ui_holdem_rank_numbers", return_value=None):
            original = paths(locale, leaf, target)
        expect("locale boundary/" + locale, adapted is None and result == original,
               (adapted, result, original))
    return errors, count


if __name__ == "__main__":
    failures, total = check()
    for failure in failures:
        print("HOLDEM_RANK_LOCALE_ERROR " + failure)
    print(f"HOLDEM_RANK_LOCALE_{'FAIL' if failures else 'OK'} cases={total} historical_cases=0")
    raise SystemExit(int(bool(failures)))
