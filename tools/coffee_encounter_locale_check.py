#!/usr/bin/env python3
"""One coffee encounter's four corrected targets; no historical suite or engine.

The semantic cases use the actual title and one parsed Main consumer. One
observed product proof and one current event admission supply the captured
replay faults; those faults never claim fresh historical executions.
"""
from __future__ import annotations

import copy
import json
import sys
from contextlib import nullcontext
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
EXPECTED_PRODUCT_COMMIT = "5ff1e8e72e7de5ef11212bd84d682a94c39e8487"
EXPECTED_PARENT = "f4e44326b56cb76188de6278625f14181ed190e6"
EXPECTED_TREES = ("283a54d359f62e86584695197accbfa0309bae3a", "82b9b8c4e251e594b3f94f0a130522caef8190ee")
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
    check("observed product parent and trees bound", history.COFFEE_AFTER_COMMIT == EXPECTED_PRODUCT_COMMIT
          and history.COFFEE_BEFORE_COMMIT == EXPECTED_PARENT and history.COFFEE_TREES == EXPECTED_TREES)
    actual_git, actual_objects, actual_pair = history._git, history._objects, history._read_pair
    product_git, product_objects, pairs = [], [], []

    def record_git(destination):
        def invoke(root, *args, input=None):
            output = actual_git(root, *args, input=input)
            destination.append((args, input, output))
            return output
        return invoke

    def record_objects(root, requests):
        result = actual_objects(root, requests)
        product_objects.append((list(requests), result))
        return result

    def record_pair(root):
        result = actual_pair(root)
        pairs.append(result)
        return result

    # The only actual product-object/receipt proof. No old self-test is called.
    with patch.object(history, "_git", side_effect=record_git(product_git)), \
         patch.object(history, "_objects", side_effect=record_objects), \
         patch.object(history, "_read_pair", side_effect=record_pair):
        before_ui, after_ui, change = history.coffee_encounter_proof(ROOT, inventory)
    check("one actual 18-request product proof", len(pairs) == len(product_objects) == 1
          and len(product_objects[0][0]) == 18 and len(product_git) == 2)
    before_all, after_all = pairs[0]
    before = {path: before_all[path] for path in history.PRODUCT_PATHS}
    after = {path: after_all[path] for path in history.PRODUCT_PATHS}
    check("whole five-path raw inverse", len(before) == 5
          and history.coffee_product_inverse(after, before) == before)
    check("four current UI comparison paths restored", len(before_ui) == len(after_ui) == 4
          and history.coffee_encounter_comparison(after_ui, before_ui, after_ui) == before_ui)
    expected_events = {path: after[path] for path in history.EVENT_PATHS}
    current_git, predecessor_verdicts = [], {}
    actual_source_errors = history.previous.source_errors

    def record_source_errors(raw, path):
        result = actual_source_errors(raw, path)
        predecessor_verdicts[path] = (raw, list(result))
        return result

    # Fresh HEAD/three current blobs/disk plus the retained predecessor proof;
    # only the already-proved immutable product pair is reused here.
    with patch.object(history, "_read_pair", return_value=pairs[0]), \
         patch.object(history, "_git", side_effect=record_git(current_git)), \
         patch.object(history.previous, "source_errors", side_effect=record_source_errors):
        check("one actual current event admission", history.coffee_encounter_current_events(ROOT) == expected_events)
    check("actual predecessor source verdicts captured", set(predecessor_verdicts) == set(history.EVENT_PATHS)
          and all(raw == before[path] and not errors for path, (raw, errors) in predecessor_verdicts.items())
          and len(current_git) == 5)
    ledger = history.LEDGER_PATH
    a, b = full.loads(before[ledger].decode()), full.loads(after[ledger].decode())
    check("three existing event receipts plus one first Japanese UI receipt",
          sum(map(len, a["accepted"].values())) == 41740
          and sum(map(len, b["accepted"].values())) == 41741
          and len(a["batches"]) == 220 and len(b["batches"]) == 224
          and contract.RECALL_KEY not in a["accepted"]["ja"]
          and contract.RECALL_KEY in b["accepted"]["ja"]
          and all(contract.EVENT_KEY in a["accepted"][locale] for locale in full.LOCALES)
          and b["batches"][:220] == a["batches"])
    check("corrections are not new UI coverage", change["corrections"] == change["correction_batches"] == 4
          and change["first_receipts"] == 1 and change["receipts"] == change["batches"] == 0
          and not any(change["ui_by_locale"].values()))

    def replay_git(records):
        pending = iter(records)
        def invoke(root, *args, input=None):
            expected_args, expected_input, output = next(pending)
            if root != ROOT or args != expected_args or input != expected_input:
                raise AssertionError("captured Git request differs")
            if isinstance(output, Exception):
                raise output
            return output
        return invoke

    def changed_output(records, index, output):
        result = list(records)
        args, data, _ = result[index]
        result[index] = (args, data, output)
        return result

    for label, packet in (("truncated", product_git[0][2][:-1]),
                          ("trailing", product_git[0][2] + b"x")):
        with patch.object(history, "_git", side_effect=replay_git(changed_output(product_git, 0, packet))):
            rejects("captured Git packet " + label, lambda: history._read_pair(ROOT))
    with patch.object(history, "_git", side_effect=replay_git(changed_output(
            product_git, 1, product_git[1][2] + b"M\0unowned.json\0"))):
        rejects("captured product path population", lambda: history._read_pair(ROOT))
    # These three faults begin after object decoding, explicitly not fake
    # cryptographic Git objects. They exercise the subsequent binding guards.
    for label, index, old, new in (
        ("parent", 1, b"parent " + EXPECTED_PARENT.encode(), b"parent " + b"0" * 40),
        ("tree", 1, b"tree " + EXPECTED_TREES[1].encode(), b"tree " + b"0" * 40),
        ("whole raw", 4, before[history.EVENT_PATHS[0]], before[history.EVENT_PATHS[0]] + b"\n"),
    ):
        values = list(product_objects[0][1])
        if old not in values[index]:
            raise AssertionError("fault token missing: " + label)
        values[index] = values[index].replace(old, new, 1)
        with patch.object(history, "_objects", return_value=values), \
             patch.object(history, "_git", side_effect=replay_git(product_git[1:])):
            rejects("captured decoded-object " + label, lambda: history._read_pair(ROOT))

    original_read = Path.read_bytes
    absolute_events = {ROOT / path: path for path in history.EVENT_PATHS}

    def current_replay(*, disk=None, records=None, unreadable=None, source_fault=False):
        disk = expected_events if disk is None else disk
        def read(path):
            if path in absolute_events:
                relative = absolute_events[path]
                if relative == unreadable:
                    raise OSError("captured current read failure")
                return disk[relative]
            return original_read(path)
        def source_errors(raw, path):
            previous_raw, errors = predecessor_verdicts[path]
            if raw != previous_raw:
                raise AssertionError("captured predecessor input differs")
            return ["captured predecessor failure"] if source_fault else list(errors)
        with patch.object(history, "_read_pair", return_value=pairs[0]), \
             patch.object(history, "_git", side_effect=replay_git(current_git if records is None else records)), \
             patch.object(history.previous, "fresh_validation_proof", side_effect=nullcontext), \
             patch.object(history.previous, "source_errors", side_effect=source_errors), \
             patch.object(Path, "read_bytes", read):
            return history.coffee_encounter_current_events(ROOT)

    for mask in range(8):
        disk = {path: (after if mask & (1 << index) else before)[path]
                for index, path in enumerate(history.EVENT_PATHS)}
        if mask == 7:
            check("captured event combination 111 current only", current_replay(disk=disk) == expected_events)
        else:
            rejects(f"captured event combination {mask:03b} rejected", lambda disk=disk: current_replay(disk=disk))
    for label, index, output in (
        ("invalid HEAD", 0, b"invalid\n"),
        ("HEAD changed during admission", 4, b"0" * 40 + b"\n"),
        ("current blob ids differ", 2, b"0" * 40 + b"\n"),
        ("ancestry unavailable", 1, ValueError("captured Git ancestry failure")),
        ("current blob packet truncated", 3, current_git[3][2][:-1]),
    ):
        records = changed_output(current_git, index, output)
        rejects("captured " + label, lambda records=records: current_replay(records=records))
    rejects("captured current source read failure", lambda: current_replay(unreadable=history.EVENT_PATHS[0]))
    rejects("captured historical predecessor verdict failure", lambda: current_replay(source_fault=True))
    check("captured fresh invocation recovers after failures", current_replay() == expected_events)

    for path in (history.EVENT_PATHS[0], history.JA_PATH, ledger):
        rejects("outside exact raw inverse rejected " + path, lambda path=path: history.coffee_product_inverse(
            {**after, path: after[path] + b"\n"}, before))
    for path in (history.JA_PATH, ledger):
        rejects("current comparison rollback rejected " + path, lambda path=path: history.coffee_encounter_comparison(
            {**after_ui, path: before_ui[path]}, before_ui, after_ui))

    # Token-local mutations retain every other raw byte. Receipt mutations
    # recompute the checksum, so failures are not merely checksum failures.
    ledger_doc = history._Document(after[ledger])
    def ledger_mutant(path, value):
        start, end = ledger_doc.spans[path]
        edits = [(start, end, json.dumps(value, ensure_ascii=False))]
        if path[0] == "accepted":
            accepted = copy.deepcopy(b["accepted"])
            cursor = accepted
            for key in path[1:-1]:
                cursor = cursor[key]
            cursor[path[-1]] = value
            start, end = ledger_doc.spans[("accepted_sha256",)]
            edits.append((start, end, json.dumps(full.digest(accepted))))
        return {**after, ledger: history._apply(ledger_doc, edits)}

    for label, path, value in (
        ("old event receipt target", ("accepted", "zh-CN", contract.EVENT_KEY, "target_sha256"),
         a["accepted"]["zh-CN"][contract.EVENT_KEY]["target_sha256"]),
        ("first Japanese receipt source", ("accepted", "ja", contract.RECALL_KEY, "source_sha256"), "0" * 64),
        ("previous target header", ("batches", 220, "before_target_sha256_by_locale", "ja", contract.EVENT_KEY), "0" * 64),
        ("false existing Japanese receipt", ("batches", 223, "prior_acceptance"), "existing"),
        ("official export revision", ("batches", 220, history.HEADERS_FIELD, "ja", "source_revision"), "0" * 40),
    ):
        mutated = ledger_mutant(path, value)
        rejects("receipt mutation " + label, lambda mutated=mutated: history.validate_coffee_correction(before, mutated, inventory))
    for label, altered in (("missing", inventory["leaves"][:1]),
                           ("duplicate", inventory["leaves"] + inventory["leaves"][:1]),
                           ("source drift", [replace(inventory["leaves"][0], source="다른 커피"), inventory["leaves"][1]])):
        rejects("current two-leaf identity " + label, lambda altered=altered:
                history.validate_coffee_correction(before, after, {"leaves": altered}))


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
