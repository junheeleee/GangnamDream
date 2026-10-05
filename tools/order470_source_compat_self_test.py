#!/usr/bin/env python3
"""Focused actual-object and adversarial tests for the exact470 successor."""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path
from unittest import mock

import order470_source_compat as history


def run():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER470: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    proof = history._read_proof(history.ROOT)
    before, after = proof["before"], proof["after"]
    check(len(history.PRODUCT_PATHS) == len(history.RAW_SHA256) == len(history.RAW_PATCHES) == 9,
          "source9 exact independent pin and patch populations")
    check(before[history.LEDGER_PATH] == after[history.LEDGER_PATH], "draft adds zero receipts")
    for path in history.PRODUCT_PATHS:
        check(history.product_inverse(before[path], after[path], path) == before[path], "exact inverse " + path)
        for label, raw in (("rollback", before[path]), ("whitespace", after[path] + b"\n"),
                           ("nonbytes", after[path].decode())):
            reject(lambda p=path, r=raw: history.product_inverse(before[p], r, p), label + " " + path)
        reject(lambda p=path: history.product_inverse(before[p], after[p], "./" + p), "path alias " + path)
        mutant = after[path] + b"\n"
        with mock.patch.dict(history.RAW_SHA256, {path: (history._sha(before[path]), history._sha(mutant))}):
            reject(lambda p=path, r=mutant: history.product_inverse(before[p], r, p),
                   "independent hunk inverse rejects repinned whitespace " + path)
    for path in history.ARC_PATHS:
        old, new = (json.loads(raw) for raw in (before[path], after[path]))
        unaffected = lambda rows: [r for r in rows if r["id"] not in history.EVENT_IDS]
        check(unaffected(old) == unaffected(new), "every unowned event preserved " + path)
        mutated = copy.deepcopy(new)
        mutated[0]["title"] += "!"
        reject(lambda p=path, r=json.dumps(mutated, ensure_ascii=False).encode():
               history._arc_inverse(before[p], r, p), "structural neighbor mutation " + path)
    old, new = (json.loads(raw) for raw in (before[history.KO_PATH], after[history.KO_PATH]))
    for label, change in (
        ("neutral reward", lambda row: row["choices"][3].update(effects={"money": 1})),
        ("neutral invented fact", lambda row: row["choices"][3].update(flags=["jaehyuk_reported"])),
        ("wrong delay", lambda row: row["choices"][3].update(deferred_delay=True)),
        ("wrong marker", lambda row: row["choices"][0].update(requires_story_fact="crossed_line")),
        ("old effect drift", lambda row: row["choices"][0].update(effects={"money": 999})),
    ):
        mutant = copy.deepcopy(new)
        change(next(r for r in mutant if r["id"] == history.EVENT_IDS[0]))
        reject(lambda r=json.dumps(mutant, ensure_ascii=False).encode():
               history._arc_inverse(before[history.KO_PATH], r, history.KO_PATH), label)
    check(len(history.changed_text_selectors(before[history.KO_PATH], after[history.KO_PATH])) == 14,
          "actual exact14 Korean changed/new text selectors")

    real_git = history._git
    def broken(kind):
        def git(root, *args, **kwargs):
            if args[:2] == ("cat-file", "--batch") and kind == "missing":
                return b"missing missing\n"
            result = real_git(root, *args, **kwargs)
            if args[:2] == ("cat-file", "--batch") and kind == "bytes":
                return result[:-2] + b"X\n"
            if args[:3] == ("diff", "--name-status", "-z") and kind == "paths":
                return result + b"M\0project.godot\0"
            if args[:2] == ("cat-file", "--batch") and kind == "type":
                return result.replace(b" commit ", b" blob ", 1)
            return result
        return git
    for kind in ("missing", "bytes", "paths", "type"):
        with mock.patch.object(history, "_git", broken(kind)):
            reject(lambda: history._read_proof(history.ROOT), "immutable proof " + kind)
    with mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT):
        reject(lambda: history._read_proof(history.ROOT), "wrong direct parent")
    read = history._disk_bytes
    def changed_disk(path):
        return before[history.KO_PATH] if path == history.ROOT / history.KO_PATH else read(path)
    for label, fixture in (
        ("disk rollback", lambda: mock.patch.object(history, "_disk_bytes", changed_disk)),
        ("lost objects", lambda: mock.patch.object(history, "_git", broken("missing"))),
        ("changed configuration", lambda: mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT)),
    ):
        def nested():
            with history.fresh_validation_proof():
                with fixture():
                    history.predecessor_bytes(after[history.KO_PATH], history.KO_PATH)
        reject(nested, "nested fresh binding rejects " + label)
        check(history._ACTIVE.get() is None, "failed proof clears invocation " + label)
    with history.fresh_validation_proof():
        check(history.predecessor_bytes(after[history.KO_PATH], history.KO_PATH) == before[history.KO_PATH],
              "fresh recovery after adversarial fixtures")
        reject(lambda: history.predecessor_bytes(before[history.KO_PATH], history.KO_PATH),
               "historical raw cannot claim current")
    import main_game_locale_history as ui_history
    for method, path in ((ui_history.new_run_log_project_byte_hash, history.RUNTIME_PATHS[0]),
                         (ui_history.inventory_display_project_byte_hash, history.RUNTIME_PATHS[1])):
        check(method("forged", "unowned.gd", after[path]) == "forged",
              "unowned UI hash claim is never replaced " + path)
    if proof["receipts"] is not None:
        accepted = proof["receipts"]
        selectors = history.changed_text_selectors(before[history.KO_PATH], after[history.KO_PATH])
        history._validate_receipts(after, accepted, before, history.ROOT)
        check(True, "actual42 official leaves: six first and36 corrected")
        for path in history.ARC_PATHS[2:]:
            check(history.receipt_overlay_inverse(after[path], accepted[path], path, selectors) == after[path],
                  "twelve literal-only target inverses " + path)
            raw = accepted[path] + b"\n"
            with mock.patch.dict(history.RECEIPT_RAW_SHA256, {path: (history._sha(after[path]), history._sha(raw))}):
                reject(lambda p=path, r=raw: history.receipt_overlay_inverse(after[p], r, p, selectors),
                       "repinned target formatting drift " + path)
        ledger = json.loads(accepted[history.LEDGER_PATH])
        for label, mutation in (
            ("old batch dropped", lambda d: d["batches"].pop(0)),
            ("old accepted dropped", lambda d: d["accepted"]["ja"].pop(next(iter(d["accepted"]["ja"])))),
            ("source hash forged", lambda d: d["accepted"]["ja"][next(iter(d["accepted"]["ja"]))].update(source_sha256="0" * 64)),
        ):
            document = copy.deepcopy(ledger)
            mutation(document)
            document["accepted_sha256"] = history._digest(document["accepted"])
            raw = (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()
            with mock.patch.dict(history.RECEIPT_RAW_SHA256,
                                 {history.LEDGER_PATH: (history._sha(after[history.LEDGER_PATH]), history._sha(raw))}):
                reject(lambda r=raw: history._validate_receipts(after, {**accepted, history.LEDGER_PATH: r}, before, history.ROOT),
                       "rehashed receipt " + label)
        for label, mutate in (("native false claim", lambda b: b.update(native_review="PASS")),
                              ("export source forged", lambda b: next(iter(b["official_receipt_headers_by_locale"].values())).update(source_manifest_sha256="0" * 64))):
            document = copy.deepcopy(ledger)
            batch = document["batches"][-1]
            locale = next(iter(batch["official_receipt_headers_by_locale"]))
            mutate(batch)
            raw = (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()
            with (mock.patch.dict(history.RECEIPT_RAW_SHA256,
                                  {history.LEDGER_PATH: (history._sha(after[history.LEDGER_PATH]), history._sha(raw))}),
                  mock.patch.dict(history.RECEIPT_BATCH_SHA256, {locale: history._digest(batch)})):
                reject(lambda r=raw: history._validate_receipts(after, {**accepted, history.LEDGER_PATH: r}, before, history.ROOT),
                       "repinned official batch " + label)
    return failures, cases


def run_receipt_consumer_checks():
    """Use the real365 boundary; callers may share its fresh outer proof.

    This is deliberately separate from the cheap source test. It neither mocks
    admission nor labels a source-only result as global translation proof.
    """
    import order365_ui_receipt_compat as receipts
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER470 receipt consumer: " + label)

    with history.fresh_validation_proof() as proof, receipts.fresh_validation_proof():
        for path in history.ARC_PATHS:
            raw = proof["current"][path]
            claim = history._sha(raw)
            check(receipts.observed_byte_hash(path, claim, raw) == (claim, []),
                  "actual current hash retained " + path)
            observed, errors = receipts.observed_byte_hash(path, "0" * 64, raw)
            check(observed == "0" * 64 and bool(errors), "forged hash claim stays rejected " + path)
            mutant = raw + b"\n"
            observed, errors = receipts.observed_byte_hash(path, history._sha(mutant), mutant)
            check(observed == history._sha(mutant) and bool(errors), "rehashed raw mutation " + path)
            old = proof["before"][path]
            check(bool(receipts.source_errors(old, path)), "comparison rollback cannot be current " + path)
            check(bool(receipts.source_errors(raw, "unowned/" + path)), "unowned current path " + path)
    return failures, cases


def main():
    failures, cases = run()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"ORDER470_SOURCE_COMPAT_{'FAIL' if failures else 'OK'} cases={cases} source_paths=9")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
