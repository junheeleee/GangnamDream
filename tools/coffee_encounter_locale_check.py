#!/usr/bin/env python3
"""One coffee encounter's four corrected targets; no historical suite or engine.

The semantic cases use the actual title and one parsed Main consumer. The
receipt section is deliberately unbound until the five-file product commit is
observed. Captured Git replay faults never claim fresh historical executions.
"""
from __future__ import annotations

import copy
import hashlib
import sys
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import coffee_encounter_locale_contract as contract
import full_game_localization as full
import ja_translation_pipeline as pipeline
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = "0987e966ee1843dff2fe0cfba6a624affe44721d"
EXPECTED_PRODUCT_COMMIT = None  # Bound only after the actual product is committed.
CASES: list[str] = []


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def rejects(name, operation):
    try:
        operation()
    except (ValueError, OSError):
        pass
    else:
        raise AssertionError(name + ": unexpectedly admitted")
    CASES.append(name)


def semantic_checks():
    events = full.read_json(ROOT / contract.EVENT_SOURCE_PATH)
    selected = [event for event in events if event.get("id") == contract.EVENT_ID]
    check("one actual Korean event title", len(selected) == 1 and selected[0]["title"] == contract.EVENT_SOURCE)
    calls, errors = pipeline.parse_ui_calls("scenes/MainGame.gd", (ROOT / "scenes/MainGame.gd").read_text())
    owners = [c for c in calls if c.korean == contract.RECALL_SOURCE]
    check("one actual recollection consumer without full collection", not errors and len(owners) == 1
          and owners[0].function == "_contact_flavor" and owners[0].line == 17223
          and owners[0].english == "After the second coffee, Sangchul started telling the real stories — ones holding 30 years of seeing.")
    event = full.Leaf("events", contract.EVENT_ID, contract.EVENT_SOURCE_PATH, ("title",),
                      contract.EVENT_SOURCE, "event_standard", lifecycle="shipping")
    recall = full.Leaf("ui", contract.RECALL_SOURCE, contract.RECALL_SOURCE_PATH, (contract.RECALL_SOURCE,),
                       contract.RECALL_SOURCE, "ui_static_context")
    check("exact two Korean Leaf identities", (event.id, event.source_sha256)
          == (contract.EVENT_KEY, contract.EVENT_SOURCE_SHA256)
          and (recall.id, recall.source_sha256) == (contract.RECALL_KEY, contract.RECALL_SOURCE_SHA256))
    rows = [(event, locale, text) for locale, text in contract.EVENT_TARGETS.items()]
    rows.append((recall, "ja", contract.RECALL_TARGET))
    for leaf, locale, text in rows:
        label = locale + " " + leaf.id
        result = contract.coffee_encounter_numbers(locale, leaf.id, leaf.source, text,
                    source_path=leaf.source_path, source_sha256=leaf.source_sha256)
        check("owned canonical numeric view " + label, result is not None and not result[2])
        check("official leaf validation " + label, not full.translation_errors(leaf, locale, text))
        if locale != "ja":
            check("actual Chinese validator " + label, not zh.validate_text(locale, leaf.id, leaf.source, text))
        old = contract.RECALL_BEFORE_TARGET if leaf is recall else contract.EVENT_BEFORE_TARGETS[locale]
        check("original cup misreading rejected " + label, bool(full.translation_errors(leaf, locale, old)))
        replacements = (("二度目", "一度目"), ("二度目", "三度目")) if locale == "ja" else (
                       ("第二次", "第一次"), ("第二次", "第三次"))
        for before, after in replacements:
            changed = text.replace(before, after, 1)
            check("first or third occasion rejected " + label + after, changed != text
                  and bool(full.translation_errors(leaf, locale, changed)))
        for name, changed in (("extra quantity", text + " 2"), ("newline", text + "\n"),
                              ("placeholder", text + "%s"), ("BBCode", "[b]" + text + "[/b]")):
            check(name + " rejected " + label, bool(full.translation_errors(leaf, locale, changed)))
        for field, changed in (("source", replace(leaf, source=leaf.source + " ")),
                               ("origin", replace(leaf, source_path="unowned.json"))):
            check("owned Leaf drift rejected " + label + field, bool(full.translation_errors(changed, locale, text)))
        check("wrong supplied source digest rejected " + label, bool(contract.coffee_encounter_numbers(
            locale, leaf.id, leaf.source, text, source_sha256="0" * 64)[2]))
    for name, text in (
        ("lost thirty years", contract.RECALL_TARGET.replace("三十年", "")),
        ("twenty years", contract.RECALL_TARGET.replace("三十年", "二十年")),
        ("after to before", contract.RECALL_TARGET.replace("の後、", "の前、")),
        ("altered unchanged tail", contract.RECALL_TARGET.replace("本題", "真実")),
    ):
        check("recollection " + name + " rejected", bool(full.translation_errors(recall, "ja", text)))
    check("recollection is exactly one opening repair", contract.RECALL_TARGET
          == contract.RECALL_BEFORE_TARGET.replace("二杯目", "二度目", 1))
    for locale, key, source, text in (
        ("en", event.id, event.source, "The Second Coffee"),
        ("ja", "events:other:/title", event.source, contract.EVENT_TARGETS["ja"]),
        ("zh-CN", "events:" + contract.EVENT_ID + ":/description", event.source, contract.EVENT_TARGETS["zh-CN"]),
        ("ja", "ui:두 번째 커피:/두 번째 커피", event.source, "二度目のコーヒー"),
        ("zh-CN", recall.id, recall.source, "第二次喝咖啡后"),
        ("zh-TW", recall.id, recall.source, "喝過第二次咖啡後"),
    ):
        check("unowned address locale stays outside " + locale + key,
              contract.coffee_encounter_numbers(locale, key, source, text) is None)
    # A genuine second cup elsewhere is not reclassified as a meeting.
    for locale, text in (("ja", "二杯目のコーヒー"), ("zh-CN", "第二杯咖啡"), ("zh-TW", "第二杯咖啡")):
        leaf = replace(event, owner="other_coffee")
        normal = full.translation_errors(leaf, locale, text)
        with patch.object(contract, "coffee_encounter_numbers", return_value=None):
            original = full.translation_errors(leaf, locale, text)
        check("off-scope original verdict unchanged " + locale, normal == original)
    return {"leaves": [event, recall]}


def history_checks(inventory):
    import coffee_encounter_receipt_history as history
    if EXPECTED_PRODUCT_COMMIT is None:
        raise ValueError("ORDER-448 focused product pins are not bound yet")
    check("observed product commit bound", history.COFFEE_AFTER_COMMIT == EXPECTED_PRODUCT_COMMIT)
    before_ui, after_ui, change = history.coffee_encounter_proof(ROOT, inventory)
    # The full history proof owns current source/HEAD and official receipt
    # validation. Only the observed five-path delta is inverted below.
    before = {path: history._git(ROOT, "show", history.COFFEE_BEFORE_COMMIT + ":" + path)
              for path in history.PRODUCT_PATHS}
    after = {path: history._git(ROOT, "show", history.COFFEE_AFTER_COMMIT + ":" + path)
             for path in history.PRODUCT_PATHS}
    check("whole five-path raw inverse", len(before) == 5
          and history.coffee_product_inverse(after, before) == before)
    check("four current UI comparison paths restored", len(before_ui) == len(after_ui) == 4
          and history.coffee_encounter_comparison(after_ui, before_ui, after_ui) == before_ui)
    check("current events are exactly the three corrected overlays", history.coffee_encounter_current_events(ROOT)
          == {path: after[path] for path in history.EVENT_PATHS})
    for path in history.EVENT_PATHS:
        rejects("mixed old event rejected " + path, lambda path=path: history.coffee_product_inverse(
            {**after, path: before[path]}, before))
    for path in history.PRODUCT_PATHS:
        rejects("unowned raw bytes rejected " + path, lambda path=path: history.coffee_product_inverse(
            {**after, path: after[path] + b"\n"}, before))
    ledger = "content/meta/full_game_localization.json"
    a, b = full.loads(before[ledger].decode()), full.loads(after[ledger].decode())
    check("three existing event receipts plus one first Japanese UI receipt",
          sum(map(len, a["accepted"].values())) == 41740
          and sum(map(len, b["accepted"].values())) == 41741
          and len(a["batches"]) == 220 and len(b["batches"]) == 224
          and contract.RECALL_KEY not in a["accepted"]["ja"]
          and contract.RECALL_KEY in b["accepted"]["ja"]
          and all(contract.EVENT_KEY in a["accepted"][locale] for locale in full.LOCALES)
          and b["batches"][:220] == a["batches"])
    check("pure correction matches actual proof", history.validate_coffee_correction(before, after, inventory) == change)


def main():
    protected = ("content/events/arc_events.json", "content/events_en/arc_events.json",
                 "content/events_ja/arc_events.json", "content/events_zh-CN/arc_events.json",
                 "content/events_zh-TW/arc_events.json", "locale/ui_ja.json",
                 "locale/ui_zh-CN.json", "locale/ui_zh-TW.json",
                 "content/meta/full_game_localization.json", "scenes/MainGame.gd",
                 "tools/coffee_encounter_locale_contract.py", "tools/full_game_localization.py",
                 "tools/zh_translation_audit.py", "tools/coffee_encounter_locale_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    inventory = semantic_checks()
    history_checks(inventory)
    check("owned and protected bytes unchanged", all((ROOT / path).read_bytes() == raw for path, raw in observed.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"COFFEE_ENCOUNTER_LOCALE_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
