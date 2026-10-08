#!/usr/bin/env python3
"""Current coffee-encounter semantics and source-bound machine receipts.

Checks use the live title, Main consumer, translated targets and accepted
ledger. They do not require a past Git transition or run an engine.
"""
from __future__ import annotations

import copy
import json
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
          and owners[0].function == "_contact_flavor" and owners[0].api == "legacy"
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


def receipt_errors(ledger, rows):
    """Check actual accepted source/target identities, not a historical count."""
    failures = []
    if not isinstance(ledger, dict) or ledger.get("schema_version") != full.SCHEMA_VERSION \
            or ledger.get("prompt_version") != full.PROMPT_VERSION \
            or ledger.get("native_review") != "OPEN":
        return ["machine receipt schema/prompt/native evidence state differs"]
    accepted = ledger.get("accepted")
    if not isinstance(accepted, dict) or set(accepted) != set(full.LOCALES) \
            or ledger.get("accepted_sha256") != full.digest(accepted):
        return ["accepted locale/checksum differs"]
    for leaf, locale, target in rows:
        receipt = accepted.get(locale, {}).get(leaf.id)
        if not isinstance(receipt, dict) or set(receipt) != {"source_sha256", "target_sha256"} \
                or receipt.get("source_sha256") != leaf.source_sha256 \
                or receipt.get("target_sha256") != full.digest(target):
            failures.append(locale + ":" + leaf.id + ": actual source/target receipt differs")
    return failures


def current_receipt_checks(inventory):
    event, recall = inventory["leaves"]
    rows = []
    for locale, expected in contract.EVENT_TARGETS.items():
        filename = "content/events_" + locale + "/arc_events.json"
        targets = full.read_json(ROOT / filename)
        found = [row for row in targets if row.get("id") == contract.EVENT_ID]
        check("one current target event " + locale,
              len(found) == 1 and found[0].get("title") == expected)
        target = found[0]["title"]
        check("actual target semantic validation " + locale,
              not full.translation_errors(event, locale, target))
        rows.append((event, locale, target))
    dictionary = full.read_json(ROOT / "locale/ui_ja.json")
    target = dictionary.get(contract.RECALL_SOURCE)
    check("current Japanese recollection target", target == contract.RECALL_TARGET)
    check("current Japanese recollection validation",
          not full.translation_errors(recall, "ja", target))
    rows.append((recall, "ja", target))
    ledger = full.read_json(ROOT / "content/meta/full_game_localization.json")
    check("four current source/target accepted receipts", not receipt_errors(ledger, rows))
    for leaf, locale, _target in rows:
        for field in ("source_sha256", "target_sha256"):
            changed = copy.deepcopy(ledger)
            changed["accepted"][locale][leaf.id][field] = "0" * 64
            changed["accepted_sha256"] = full.digest(changed["accepted"])
            check("rechecksummed receipt mutation rejected " + locale + leaf.id + field,
                  bool(receipt_errors(changed, rows)))
    changed = copy.deepcopy(ledger)
    del changed["accepted"]["ja"][recall.id]
    changed["accepted_sha256"] = full.digest(changed["accepted"])
    check("missing current recollection receipt rejected", bool(receipt_errors(changed, rows)))
    changed = copy.deepcopy(ledger)
    changed["accepted_sha256"] = "0" * 64
    check("receipt checksum mutation rejected", bool(receipt_errors(changed, rows)))


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
    current_receipt_checks(inventory)
    check("owned and protected bytes unchanged", all((ROOT / path).read_bytes() == raw for path, raw in observed.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"COFFEE_ENCOUNTER_LOCALE_CHECK_OK cases={len(CASES)} current_receipts=4")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
