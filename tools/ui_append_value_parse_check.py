#!/usr/bin/env python3
"""Strict JSON, current UI receipt and byte-preserving append regressions.

The value-loader reference is synthetic, not a fixed old implementation. Every
case uses real span reconstruction and refuses malformed or mismatched receipts.
"""
from __future__ import annotations

import copy
import hashlib
import json
import sys
from contextlib import nullcontext
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import ui_translation_append as append

ROOT = Path(__file__).resolve().parents[1]
PATH = "tools/ui_translation_append.py"
CASES: list[str] = []
REAL_DOCUMENT = append._Document
REAL_LOADS = append._loads
REAL_INVERSE = append._raw_inverse


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def raw(value):
    return (json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode()


def shape(value):
    """Preserve object order and scalar types, unlike ordinary dict equality."""
    if isinstance(value, dict):
        return ("dict", [(key, shape(item)) for key, item in value.items()])
    if isinstance(value, list):
        return ("list", [shape(item) for item in value])
    return (type(value).__name__, value)


def outcome(operation):
    try:
        return ("ok", shape(operation()))
    except Exception as error:
        return ("error", type(error).__name__, str(error))


def fixture(locales, four_paths=True):
    """One synthetic source leaf, real official header/digest, no Git fixture."""
    key = "검사 문구"
    leaf = append.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
    inventory = {"leaves": [leaf], "source_manifest_sha256": "2" * 64}
    old_receipt = {"source_sha256": "3" * 64, "target_sha256": "4" * 64}
    accepted = {loc: {"ui:old:/old": dict(old_receipt), "ui:older:/older": dict(old_receipt)}
                for loc in append.CURRENT_LOCALES}
    ledger = {"schema_version": 1, "native_review": "OPEN", "accepted": accepted,
              "accepted_sha256": append.exchange.digest(accepted), "batches": [{"order": "immutable synthetic base"}],
              "metadata": {"int": 1, "float": 1.0, "bool": True, "nested": [None, {}, []]}}
    paths = append.CURRENT_PATHS if four_paths else append.PATHS
    before_values = {path: {"old": "旧文", "older": "前文"} for path in paths if path != append.LEDGER_PATH}
    before_values[append.LEDGER_PATH] = ledger
    after_values = copy.deepcopy(before_values)
    current = after_values[append.LEDGER_PATH]
    targets = {"ja": "確認文", "zh-CN": "检查文字", "zh-TW": "檢查文字"}
    headers, hashes = {}, {}
    for locale in locales:
        text = targets[locale]
        after_values[f"locale/ui_{locale}.json"][key] = text
        receipt = {leaf.id: {"source_sha256": leaf.source_sha256,
                             "target_sha256": append.exchange.digest(text)}}
        current["accepted"][locale].update(receipt)
        header = append.exchange.make_batch(inventory, locale, [leaf], "1" * 40, {}, {})[0]
        headers[locale] = header
        hashes[locale] = append.exchange.digest({"batch": header, "state": "accepted_machine_validated",
            "native_review": "OPEN", "translations": receipt})
    current["accepted_sha256"] = append.exchange.digest(current["accepted"])
    current["batches"].append({"order": "synthetic433", "group": "ui", "roots": [key], "source_leaves": 1,
        "target_leaves_by_locale": {loc: int(loc in locales) for loc in append.CURRENT_LOCALES},
        "machine_validation": "PASS", "native_review": "OPEN", append.HEADERS_FIELD: headers,
        "receipt_sha256_by_locale": hashes})
    return ({path: raw(value) for path, value in before_values.items()},
            {path: raw(value) for path, value in after_values.items()}, inventory)


def run_transition(before, after, inventory, legacy):
    """Observe real Document work; never replace the raw inverse with a stub."""
    trace, in_inverse = [], False

    def document(value):
        trace.append(("document", "inverse" if in_inverse else "value", value))
        return REAL_DOCUMENT(value)

    def inverse(old, new, path):
        nonlocal in_inverse
        trace.append(("inverse", path, old, new))
        in_inverse = True
        try:
            return REAL_INVERSE(old, new, path)
        finally:
            in_inverse = False

    # Document.__init__ uses its defining module's strict loader, not append's
    # exported alias, so this old-value seam cannot recursively call itself.
    def old_value(value):
        return append._Document(value).value

    original = copy.deepcopy((before, after, inventory))
    with patch.object(append, "_Document", side_effect=document), \
            patch.object(append, "_raw_inverse", side_effect=inverse), \
            (patch.object(append, "_loads", side_effect=old_value) if legacy else nullcontext()):
        result = outcome(lambda: append.validate_append(before, after, inventory))
    if (before, after, inventory) != original:
        raise AssertionError("transition mutated caller snapshot/inventory")
    return result, trace


def compare(name, before, after, inventory, accepted, fragment=None):
    old, old_trace = run_transition(before, after, inventory, True)
    new, new_trace = run_transition(before, after, inventory, False)
    check(name + ": identical isolated outcome and unmodified inputs", old == new
          and (new[0] == "ok") == accepted
          and (fragment is None or new[0] == "error" and fragment in new[2]))
    check(name + ": original span inverse invocation sequence",
          [row for row in old_trace if row[0] == "inverse"] == [row for row in new_trace if row[0] == "inverse"])
    check(name + ": no value-only span creation", not any(row[:2] == ("document", "value") for row in new_trace))
    if accepted:
        count = len(before)
        expected_inverse = [("inverse", path, before[path], after[path]) for path in before]
        expected_documents = [("document", "inverse", value) for path in before for value in (before[path], after[path])]
        check(name + ": all paths reach real raw inverse", [row for row in new_trace if row[0] == "inverse"] == expected_inverse)

    return new


def main():
    protected = (PATH, "tools/ui_translation_append_self_test.py",
                 "tools/ui_append_value_parse_check.py", *append.CURRENT_PATHS)
    observed = {path: sha((ROOT / path).read_bytes()) for path in protected}
    valid_json = [b'{"z":1,"a":1.0,"flag":true,"none":null,"nested":[{},[],false]}',
                  ' \r\n{"文字":"旧文","escaped":"\\u65e7文","punct":"{}[],:/\\\\"}\t'.encode(),
                  b'[1,-2,0.0,1e2,"text"]', b'"scalar"', b'false', b'null']
    invalid_json = [("duplicate", b'{"a":1,"a":2}'), ("nested duplicate", b'{"outer":{"x":0,"x":1}}'),
        ("escaped duplicate", b'{"a":1,"\\u0061":2}'), ("NaN", b'{"a":NaN}'),
        ("Infinity", b'[Infinity]'), ("negative Infinity", b'[-Infinity]'),
        ("positive overflow", b'{"n":1e999}'), ("negative overflow", b'{"n":-1e999}'),
        ("invalid UTF8", b'"\xff"'), ("BOM", b'\xef\xbb\xbf{}'), ("trailing", b'{} true'),
        ("truncated", b'{"a":'), ("empty", b''), ("trailing comma", b'[1,]'), ("control", b'"a\x01b"')]
    for index, payload in enumerate(valid_json):
        a, b = outcome(lambda: REAL_DOCUMENT(payload).value), outcome(lambda: REAL_LOADS(payload))
        check("strict valid JSON types/order " + str(index), a == b and a[0] == "ok")
    for name, payload in invalid_json:
        a, b = outcome(lambda: REAL_DOCUMENT(payload).value), outcome(lambda: REAL_LOADS(payload))
        check("strict invalid JSON " + name, a == b and a[0] == "error")

    before, after, inventory = fixture(append.CURRENT_LOCALES)
    result = compare("four-path three-locale append", before, after, inventory, True)
    expected = {"ui_by_locale": {loc: 1 for loc in append.CURRENT_LOCALES}, "batches": 1, "receipts": 3,
                "source_manifests": {"1" * 40: "2" * 64}}
    check("official one-leaf admission counters", result == ("ok", shape(expected)))
    for name, fixture_args in (("three-path CN/TW append", (append.LOCALES, False)),
                               ("four-path JA-only append", (("ja",), True))):
        compare(name, *fixture(*fixture_args), True)
    compare("four-path unchanged", before, before, inventory, True)

    ui = "locale/ui_zh-CN.json"
    ledger = append.LEDGER_PATH
    leaf = inventory["leaves"][0]
    values = {path: REAL_LOADS(contents) for path, contents in after.items()}
    faults = []

    def mutation(name, path, change, fragment, resign=False):
        value = copy.deepcopy(values[path]);change(value)
        if resign:
            value["accepted_sha256"] = append.exchange.digest(value["accepted"])
        faults.append((name, {**after, path: raw(value)}, inventory, fragment))

    mutation("old UI value", ui, lambda v: v.update(old="別文"), "old UI member/order/value changed")
    reorder = {"older": values[ui]["older"], "old": values[ui]["old"], leaf.owner: values[ui][leaf.owner]}
    faults.append(("old UI order", {**after, ui: raw(reorder)}, inventory, "old UI member/order/value changed"))
    mutation("blank UI", ui, lambda v: v.update({leaf.owner: ""}), "blank/nontext UI addition")
    mutation("nontext UI", ui, lambda v: v.update({leaf.owner: None}), "blank/nontext UI addition")
    mutation("checksum", ledger, lambda v: v.update(accepted_sha256="0" * 64), "accepted checksum mismatch")
    for field in ("source_sha256", "target_sha256"):
        mutation("re-signed " + field, ledger, lambda v, f=field: v["accepted"]["zh-CN"][leaf.id].update({f: "0" * 64}),
                 "UI/receipt/source/target additions differ", True)
    mutation("missing receipt", ledger, lambda v: v["accepted"]["zh-CN"].pop(leaf.id), "UI/receipt/source/target additions differ", True)
    mutation("orphan receipt", ledger, lambda v: v["accepted"]["zh-CN"].update(orphan={}), "UI/receipt/source/target additions differ", True)
    mutation("old receipt order", ledger, lambda v: v["accepted"].update({"zh-CN": {
        "ui:older:/older": v["accepted"]["zh-CN"]["ui:older:/older"],
        "ui:old:/old": v["accepted"]["zh-CN"]["ui:old:/old"],
        leaf.id: v["accepted"]["zh-CN"][leaf.id]}}), "old receipt changed/deleted/reordered", True)
    mutation("missing batch", ledger, lambda v: v["batches"].pop(), "new receipts lack exactly one official unit batch")
    mutation("duplicate batch", ledger, lambda v: v["batches"].append(copy.deepcopy(v["batches"][-1])), "duplicate/orphan/out-of-batch receipt")
    mutation("boolean source count", ledger, lambda v: v["batches"][-1].update(source_leaves=True), "new batch roots/count mismatch")
    mutation("duplicate roots", ledger, lambda v: v["batches"][-1]["roots"].append(leaf.owner), "new batch roots/count mismatch")
    mutation("official header boolean count", ledger, lambda v: v["batches"][-1][append.HEADERS_FIELD]["zh-CN"].update(count=True), "official receipt header/selection differs")
    mutation("official header order", ledger, lambda v: v["batches"][-1][append.HEADERS_FIELD].update({
        "zh-CN": dict(reversed(list(v["batches"][-1][append.HEADERS_FIELD]["zh-CN"].items())))}), "official receipt header/selection differs")
    mutation("official receipt digest", ledger, lambda v: v["batches"][-1]["receipt_sha256_by_locale"].update({"zh-CN": "0" * 64}), "official receipt digest differs")
    faults.append(("duplicate current leaf", after, {**inventory, "leaves": [leaf, leaf]}, "duplicate current source leaf ID"))
    faults.append(("wrong snapshot population", {p: v for p, v in after.items() if p != ui}, inventory, "exact three- or four-path snapshot required"))
    for path in before:
        faults.append(("neighbor whitespace " + path, {**after, path: after[path] + b"\n"}, inventory, "bytes outside exact additions changed"))
    faults.append(("same-value old raw Unicode escape", {**after, ui: after[ui].replace("旧文".encode(), b"\\u65e7\\u6587", 1)}, inventory, "bytes outside exact additions changed"))
    faults.append(("same-value ledger raw spacing", {**after, ledger: after[ledger].replace(b'"schema_version": 1', b'"schema_version" : 1', 1)}, inventory, "bytes outside exact additions changed"))
    faults.append(("same-value float exponent spelling", {**after, ledger: after[ledger].replace(b'"float": 1.0', b'"float": 1e0', 1)}, inventory, "bytes outside exact additions changed"))
    for name, changed, inv, fragment in faults:
        compare(name, before, changed, inv, False, fragment)
    for name, payload in invalid_json:
        compare("append parser " + name, before, {**after, ui: payload}, inventory, False)
    compare("fresh admission after rejected inputs", before, after, inventory, True)
    check("strict loader binding restored after reference", append._loads is REAL_LOADS
          and append._Document is REAL_DOCUMENT and append._raw_inverse is REAL_INVERSE)
    check("all observed source, parsers, old suites, UI and ledger unchanged",
          all(sha((ROOT / path).read_bytes()) == digest for path, digest in observed.items()))
    check("no duplicate case names", len(CASES) == len(set(CASES)))
    print(f"UI_APPEND_VALUE_PARSE_OK cases={len(CASES)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
