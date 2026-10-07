#!/usr/bin/env python3
"""Bounded478 actual-source/first-receipt controls; no engine or old suite."""
from __future__ import annotations

import copy
import difflib
import json
import sys
from pathlib import Path
from unittest import mock

import market_cycle_label_history as history


def run_market_cycle_checks(root=history.ROOT, inventory=None):
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER478 market history: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    def rehashed_inverse(before, changed, path):
        # Both independent whole hashes and every hunk hash/coordinate are
        # rebuilt, so the semantic negative cannot pass on a stale checksum.
        old, new = before.splitlines(True), changed.splitlines(True)
        patches = tuple((tag, a, z, b, end, history._sha(b"".join(old[a:z])),
                         history._sha(b"".join(new[b:end])))
                        for tag, a, z, b, end in difflib.SequenceMatcher(None, old, new).get_opcodes()
                        if tag != "equal")
        with mock.patch.dict(history.RAW_SHA256, {path: (history._sha(before), history._sha(changed))}), \
                mock.patch.dict(history.RAW_PATCHES, {path: patches}):
            return history.product_inverse(before, changed, path)

    active = history._ACTIVE.get()
    with history.fresh_validation_proof(root) as proof:
        before, source, current = (proof[k] for k in ("before", "source", "current"))
        check({p for p in before if before[p] != source[p]} == set(history.SOURCE_PATHS), "exact source2")
        for path in history.SOURCE_PATHS:
            check(history.product_inverse(before[path], source[path], path) == before[path], "exact inverse " + path)
            for label, raw in (("rollback", before[path]), ("neighbor", source[path] + b"\n"),
                               ("nonbytes", bytearray(source[path]))):
                reject(lambda r=raw, p=path: history.product_inverse(before[p], r, p), label + " " + path)
        reject(lambda: history.product_inverse(before[history.INVESTMENT_PATH], source[history.INVESTMENT_PATH],
               history.LEDGER_PATH), "wrong owned path")
        investment = source[history.INVESTMENT_PATH]
        for label, raw in (("raw enum", investment.replace(history.NEW_LOG, history.OLD_LOG)),
                           ("neighbor gameplay", investment.replace(b"func _cycle_display_name", b"# extra\nfunc _cycle_display_name", 1)),
                           ("wrong key", investment.replace('"횡보장"'.encode(), '"횡보"'.encode(), 1)),
                           ("wrong English", investment.replace(b'"Sideways"', b'"Flat"', 1)),
                           ("unknown fallback", investment.replace(b"\t\t\treturn cycle\n", b'\t\t\treturn "neutral"\n')),
                           ("extra call", investment + b'\tLocaleManager.ui("x", "x")\n')):
            reject(lambda r=raw: rehashed_inverse(before[history.INVESTMENT_PATH], r, history.INVESTMENT_PATH),
                   "independently repinned " + label)
        doc = history._Document(source[history.JA_PATH])
        for key, text in ((history.SOURCE_KEY, history.OLD_JA), ("횡보", "横ばい")):
            a, z = doc.spans[(key,)]
            raw = (doc.text[:a] + json.dumps(text, ensure_ascii=False) + doc.text[z:]).encode()
            reject(lambda r=raw: rehashed_inverse(before[history.JA_PATH], r, history.JA_PATH), "repinned JA " + key)
        reject(lambda: rehashed_inverse(before[history.JA_PATH], source[history.JA_PATH] + b"\n", history.JA_PATH),
               "repinned JA outside layout")
        check(history.market_cycle_predecessor(investment, root) == before[history.INVESTMENT_PATH], "public actual Investment inverse")
        for label, raw in (("old", before[history.INVESTMENT_PATH]), ("neighbor", investment + b"\n"),
                           ("type", bytearray(investment)), ("wrong file", source[history.JA_PATH])):
            reject(lambda r=raw: history.market_cycle_predecessor(r, root), "public Investment " + label)
        actual4 = {p: current[p] for p in history.CURRENT_UI_PATHS}
        old4 = {p: before[p] for p in history.CURRENT_UI_PATHS}
        result = history.ui_predecessor(actual4, root)
        check(result == old4 and actual4 == {p: current[p] for p in actual4}, "actual four-raw inverse without mutation")
        result[history.JA_PATH] = b"forged"
        check(history.ui_predecessor(actual4, root) == old4, "returned comparison has no mutable alias")
        for label, rows in (("old", old4), ("missing", {k: v for k, v in actual4.items() if k != history.JA_PATH}),
                            ("extra", {**actual4, "extra": b"x"}), ("neighbor", {**actual4, history.JA_PATH: actual4[history.JA_PATH] + b"\n"}),
                            ("nonbytes", {**actual4, history.JA_PATH: bytearray(actual4[history.JA_PATH])})):
            reject(lambda r=rows: history.ui_predecessor(r, root), "four-raw " + label)
        source4 = {p: source[p] for p in history.CURRENT_UI_PATHS}
        check(history.ui_comparison(source4, old4, source4) == old4, "source-only UI seam")
        reject(lambda: history.ui_comparison(old4, old4, source4), "seam rejects historical claim")
        check(source[history.LEDGER_PATH] == before[history.LEDGER_PATH], "source2 means zero acceptance")
        receipts = proof["receipts"]
        if receipts is None:
            check(current == source and history.RECEIPT_COMMIT is None, "unbound receipt remains source-only")
            reject(lambda: history._receipt_semantics(source, source), "unbound acceptance cannot pass")
        else:
            check({p for p in source if source[p] != receipts[p]} == {history.LEDGER_PATH}, "separate ledger1 stage")
            check(history._receipt_semantics(source, receipts) == history.RECEIPT_PARENT, "exact official first1")
            check(history._ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH]) == source[history.LEDGER_PATH],
                  "old273 raw prefix and41848 accepted records remain")
            check(history.ui_comparison(actual4, source4, actual4) == source4, "first receipt UI seam")
            reject(lambda: history._receipt_semantics(source, source), "receipt rollback")
            reject(lambda: history._ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH] + b"\n"),
                   "receipt neighboring raw")
            ledger = history._loads(receipts[history.LEDGER_PATH])
            for label in ("existing receipt", "wrong target", "extra key", "native approval", "old prefix"):
                mutant = copy.deepcopy(ledger)
                if label == "existing receipt":
                    key = next(k for k in mutant["accepted"]["ja"] if k != history.RECEIPT_ID)
                    mutant["accepted"]["ja"][key]["target_sha256"] = "0" * 64
                elif label == "wrong target":
                    mutant["accepted"]["ja"][history.RECEIPT_ID]["target_sha256"] = "0" * 64
                elif label == "extra key":
                    mutant["accepted"]["ja"]["ui:extra:/extra"] = mutant["accepted"]["ja"][history.RECEIPT_ID]
                elif label == "native approval":
                    mutant["native_review"] = "PASS"
                else:
                    mutant["batches"][0]["order"] = "forged"
                mutant["accepted_sha256"] = history._digest(mutant["accepted"])
                raw = (json.dumps(mutant, ensure_ascii=False, indent=2) + "\n").encode()
                pairs = (history._sha(source[history.LEDGER_PATH]), history._sha(raw))
                with mock.patch.object(history, "RECEIPT_RAW_SHA256", pairs):
                    reject(lambda r=raw: history._receipt_semantics(source, {**receipts, history.LEDGER_PATH: r}),
                           "rehashed receipt " + label)
        # Editing the yielded dictionary cannot forge the hidden active proof.
        proof["current"][history.INVESTMENT_PATH] = before[history.INVESTMENT_PATH]
        check(history.market_cycle_predecessor(investment, root) == before[history.INVESTMENT_PATH], "yielded proof copy cannot alter admission")
    check(history._ACTIVE.get() is active, "outer identity restored")

    for label, attr, value in (("parent", "PRODUCT_PARENT", history.PRODUCT_COMMIT),
                               ("unbound", "PRODUCT_COMMIT", None), ("paths", "SOURCE_PATHS", (history.INVESTMENT_PATH,))):
        with mock.patch.object(history, attr, value):
            reject(lambda: history._read_proof(root), "exact stage rejects " + label)
    for response in (b"missing missing\n", b"0" * 40 + b" blob 0\n\n"):
        with mock.patch.object(history, "_git", return_value=response):
            reject(lambda: history._objects(root, [(history.PRODUCT_COMMIT, history.PRODUCT_COMMIT, "commit")]),
                   "typed object identity/type")
    original_git = history._git
    def extra_path(r, *args, **kwargs):
        raw = original_git(r, *args, **kwargs)
        return raw + b"M\0unowned.json\0" if args[:3] == ("diff", "--name-status", "-z") else raw
    with mock.patch.object(history, "_git", extra_path):
        reject(lambda: history._read_proof(root), "global changed pathset cannot grow")
    reject(lambda: history._read_proof(Path(root) / "tools"), "wrong root")
    for kind in ("Git", "configuration", "disk", "function", "HEAD"):
        def warm():
            with history.fresh_validation_proof(root):
                if kind == "Git":
                    patch = mock.patch.object(history, "_git", side_effect=ValueError("missing typed object"))
                elif kind == "configuration":
                    patch = mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT)
                elif kind == "function":
                    original = history.product_inverse
                    patch = mock.patch.object(history, "product_inverse", lambda *a: original(*a))
                elif kind == "HEAD":
                    original = history._git
                    patch = mock.patch.object(history, "_git", side_effect=lambda r, *a, **kw:
                                              (history.PRODUCT_PARENT + "\n").encode() if a[0] == "rev-parse" else original(r, *a, **kw))
                else:
                    original = history._disk_bytes
                    patch = mock.patch.object(history, "_disk_bytes", side_effect=lambda p:
                                              original(p) + b"\n" if p == Path(root) / history.JA_PATH else original(p))
                with patch:
                    history.market_cycle_predecessor(investment, root)
        reject(warm, "warm nested " + kind)
        check(history._ACTIVE.get() is active, "failed nested scope restores " + kind)
    with history.fresh_validation_proof(root) as real:
        forged = copy.deepcopy(real)
        forged["current"][history.INVESTMENT_PATH] = forged["before"][history.INVESTMENT_PATH]
        token = history._ACTIVE.set(forged)
        try:
            reject(lambda: history.market_cycle_predecessor(forged["current"][history.INVESTMENT_PATH], root), "forged cached proof")
        finally:
            history._ACTIVE.reset(token)
    try:
        with history.fresh_validation_proof(root):
            raise RuntimeError("consumer error")
    except RuntimeError:
        check(history._ACTIVE.get() is active, "consumer exception clears scope")
    for exceptional in (False, True):
        def late_change():
            original_read, armed = history._disk_bytes, [False]
            def read(path):
                raw = original_read(path)
                return raw + b"\n" if armed[0] and path == Path(root) / history.JA_PATH else raw
            # This control deliberately starts a separate invocation so an
            # enclosing runner's function binding cannot reject before entry.
            token = history._ACTIVE.set(None)
            try:
                with mock.patch.object(history, "_disk_bytes", read):
                    with history.fresh_validation_proof(root):
                        armed[0] = True
                        if exceptional:
                            raise RuntimeError("consumer exception cannot bypass exit guard")
            finally:
                history._ACTIVE.reset(token)
        reject(late_change, "late physical mutation on " + ("exception" if exceptional else "normal exit"))
        check(history._ACTIVE.get() is active, "late failure clears scope")
    if inventory is not None:
        unchanged = copy.deepcopy(inventory)
        compared = history.source_predecessor_inventory(root, inventory)
        check(compared["source_manifest_sha256"] == history.PREDECESSOR_SOURCE_MANIFEST_SHA256,
              "whole census exact477 predecessor")
        check(inventory == unchanged, "actual collector untouched")
        for label, path, value in (("rollback", history.INVESTMENT_PATH, history.RAW_SHA256[history.INVESTMENT_PATH][0]),
                                   ("neighbor", "systems/RelationshipSystem.gd", "0" * 64),
                                   ("extra", history.LEDGER_PATH, "0" * 64)):
            mutant = copy.deepcopy(inventory)
            mutant["source_hashes"][path] = value
            mutant["source_manifest_sha256"] = history._digest(mutant["source_hashes"])
            reject(lambda r=mutant: history.source_predecessor_inventory(root, r), "independently rehashed census " + label)
        reject(lambda: history.source_predecessor_inventory(root, compared), "comparison is never current")
    check(history._ACTIVE.get() is active, "no cross-invocation success cache")
    return failures, cases


def main():
    if sys.argv[1:] not in ([], ["--market-cycle-only"]):
        raise SystemExit("usage: market_cycle_label_history_self_test.py [--market-cycle-only]")
    failures, cases = run_market_cycle_checks()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"ORDER478_MARKET_CYCLE_{'FAIL' if failures else 'OK'} cases={cases} native_review=OPEN")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
