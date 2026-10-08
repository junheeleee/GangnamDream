#!/usr/bin/env python3
"""Current ledger/span preservation cases, without fixed history projections.

The old correction-cache/reference-commit tests have no current product reader.
Their generic receipt integrity, strict JSON and exact raw-boundary mutants stay.
"""
from __future__ import annotations

import copy
import hashlib
from pathlib import Path

import ui_translation_append as append
from ui_append_value_parse_check import fixture, raw

ROOT = Path(__file__).resolve().parents[1]


def check_all():
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def rejected(call, label):
        try:
            call()
        except (ValueError, OSError, KeyError, TypeError, IndexError):
            check(True, label)
        else:
            check(False, label)

    paths = (*append.CURRENT_PATHS, "tools/ui_translation_append.py")
    original_raw = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in paths}
    for locales, four in ((append.CURRENT_LOCALES, True), (append.LOCALES, False), (("ja",), True)):
        before, after, inventory = fixture(locales, four)
        originals = copy.deepcopy((before, after, inventory))
        ledger = append.LEDGER_PATH
        value = append._loads(after[ledger])
        leaf = inventory["leaves"][0]
        check(append.validate_append(before, after, inventory)["receipts"] == len(locales),
              "exact current official append " + str(locales))
        for label, change, checksum in (
            ("accepted checksum", lambda v: v.update(accepted_sha256="0" * 64), False),
            ("old receipt target", lambda v: v["accepted"][locales[0]]["ui:old:/old"].update(target_sha256="0" * 64), True),
            ("old receipt source", lambda v: v["accepted"][locales[0]]["ui:old:/old"].update(source_sha256="0" * 64), True),
            ("receipt absence", lambda v: v["accepted"][locales[0]].pop(leaf.id), True),
            ("unrelated locale receipt", lambda v: v["accepted"]["zh-TW"].update(orphan={}), True),
            ("new receipt target", lambda v: v["accepted"][locales[0]][leaf.id].update(target_sha256="9" * 64), True),
            ("old batch value", lambda v: v["batches"][0].update(order="changed"), True),
            ("batch absence", lambda v: v["batches"].pop(), True),
            ("batch order", lambda v: v["batches"].reverse(), True),
            ("native verdict forgery", lambda v: v["batches"][-1].update(native_review="GO"), True),
        ):
            changed = copy.deepcopy(value)
            change(changed)
            if checksum:
                changed["accepted_sha256"] = append.exchange.digest(changed["accepted"])
            rejected(lambda v=changed: append.validate_append(before, {**after, ledger: raw(v)}, inventory),
                     str(locales) + " " + label)
        for path in before:
            check(append._raw_inverse(before[path], after[path], path) is None, "exact raw inverse " + path)
            rejected(lambda p=path: append.validate_append(before, {**after, p: after[p] + b" "}, inventory),
                     "same-value raw whitespace " + path)
            rejected(lambda p=path: append.validate_append(before, {k: v for k, v in after.items() if k != p}, inventory),
                     "missing snapshot path " + path)
        doc = append._Document(after[ledger])
        start, end = doc.spans[("metadata", "float")]
        changed = (doc.text[:start] + "1e0" + doc.text[end:]).encode()
        rejected(lambda: append.validate_append(before, {**after, ledger: changed}, inventory),
                 "same-value unowned scalar spelling")
        ui = f"locale/ui_{locales[0]}.json"
        for payload in (b'{"duplicate":1,"duplicate":2}', b'{"invalid":NaN}', b'{"invalid":1e999}', b'{}{}'):
            rejected(lambda p=payload: append.validate_append(before, {**after, ui: p}, inventory),
                     "strict malformed current input " + repr(payload))
        check(append.validate_append(before, after, inventory)["receipts"] == len(locales),
              "fresh recovery after rejection")
        check((before, after, inventory) == originals, "caller dictionaries remain unchanged")
    check(all(hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest
              for path, digest in original_raw.items()), "actual source/UI/ledger unchanged")
    return failures, cases


def main():
    failures, cases = check_all()
    for failure in failures:
        print("UI_FIXED_LEDGER_PROJECTION_ERROR " + failure)
    print(f"UI_FIXED_LEDGER_PROJECTION_{'FAIL' if failures else 'OK'} cases={cases}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
