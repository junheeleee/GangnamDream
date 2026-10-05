#!/usr/bin/env python3
"""Focused actual-object and adversarial tests for the exact470 successor."""
from __future__ import annotations

import copy
import contextlib
import json
import sys
import time
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
    memo_failures, memo_cases, profile = run_memo_checks()
    failures.extend(memo_failures)
    cases += memo_cases
    print("ORDER470_SEMANTIC_MEMO_PROFILE " + json.dumps(profile, sort_keys=True))
    return failures, cases


def run_memo_checks():
    """Real-object reuse measurements plus failures after a warmed proof."""
    failures, cases, profile = [], 0, {}

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER470 semantic memo: " + label)

    def reject(operation, label):
        try:
            operation()
        except (OSError, ValueError, TypeError, KeyError):
            check(True, label)
        else:
            check(False, label)

    product, receipt, git, disk = history.product_inverse, history._receipt_semantics, history._git, history._disk_bytes
    for scoped in (False, True):
        with (mock.patch.object(history, "product_inverse", wraps=product) as products,
              mock.patch.object(history, "_receipt_semantics", wraps=receipt) as receipts,
              mock.patch.object(history, "_git", wraps=git) as git_calls):
            started = time.perf_counter()
            if scoped:
                with history.fresh_validation_proof() as proof:
                    raw = proof["current"][history.KO_PATH]
                    check(history.predecessor_bytes(raw, history.KO_PATH) == proof["before"][history.KO_PATH],
                          "nested actual result equals immutable predecessor")
                    saved_memo = history._SEMANTIC_MEMO.get()
                    check(all(type(v) is bytes or (type(v) is tuple and all(type(s) is str for s in v))
                              for v in saved_memo[1].values()), "memo values expose no mutable aliases")
            else:
                for _ in range(4):
                    history._read_proof(history.ROOT)
            profile["scoped" if scoped else "unscoped"] = {
                "seconds": round(time.perf_counter() - started, 6), "proof_edges": 4,
                "product_semantic_calls": products.call_count, "receipt_semantic_calls": receipts.call_count,
                "git_calls": git_calls.call_count,
                "typed_batches": sum(c.args[1:3] == ("cat-file", "--batch") for c in git_calls.call_args_list),
            }
            check(products.call_count == (9 if scoped else 36), "exact pure product calculation count " + str(scoped))
            check(receipts.call_count == (1 if scoped else 4), "exact pure receipt calculation count " + str(scoped))
        check(history._ACTIVE.get() is None and history._SEMANTIC_MEMO.get() is None,
              "no active state between invocations " + str(scoped))
    check(profile["scoped"]["git_calls"] == profile["unscoped"]["git_calls"]
          and profile["scoped"]["typed_batches"] == profile["unscoped"]["typed_batches"],
          "every Git and typed-object edge remains fresh")
    check(not saved_memo[1], "successful outer exit erases retained memo reference")

    # Install stable reader identities before entry. Toggling their responses
    # exercises actual warm evidence checks, not merely function-identity drift.
    mode = {"value": "good", "ko_reads": 0}
    def live_git(root, *args, **kwargs):
        result = git(root, *args, **kwargs)
        if args[:2] == ("cat-file", "--batch"):
            if mode["value"] == "objects missing":
                return b"missing missing\n"
            if mode["value"] == "object bytes":
                return result[:-2] + b"X\n"
            if mode["value"] == "object type":
                return result.replace(b" commit ", b" blob ", 1)
        if mode["value"] == "HEAD" and args[:2] == ("rev-parse", "--verify"):
            return ("0" * 40 + "\n").encode()
        return result
    def live_disk(path):
        result = disk(path)
        if path == history.ROOT / history.KO_PATH:
            mode["ko_reads"] += 1
            if mode["value"] == "disk" or (mode["value"] == "final disk" and mode["ko_reads"] == 2):
                return result + b"\n"
        if mode["value"] == "module" and path == Path(history.__file__).resolve():
            return result + b"\n"
        return result
    with (mock.patch.object(history, "_git", live_git), mock.patch.object(history, "_disk_bytes", live_disk),
          mock.patch.object(history, "_receipt_semantics", wraps=receipt) as receipts):
        with history.fresh_validation_proof() as proof:
            raw = proof["current"][history.KO_PATH]
            memo = history._SEMANTIC_MEMO.get()
            for label in ("objects missing", "object bytes", "object type", "HEAD", "disk", "module"):
                mode["value"], mode["ko_reads"] = label, 0
                reject(lambda: history.predecessor_bytes(raw, history.KO_PATH), "warm " + label)
                check(not memo[1], "failed warm guard erases success " + label)
                mode["value"] = "good"
                before_count = receipts.call_count
                check(history.predecessor_bytes(raw, history.KO_PATH) == proof["before"][history.KO_PATH]
                      and receipts.call_count == before_count + 1, "fresh calculation after caught failure " + label)
            with mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT):
                reject(lambda: history.predecessor_bytes(raw, history.KO_PATH), "warm pin configuration")
            check(not memo[1], "configuration failure clears success")
            history.predecessor_bytes(raw, history.KO_PATH)
            reject(lambda: history.predecessor_bytes(raw + b"\n", history.KO_PATH), "warm forged raw claim")
            check(not memo[1], "claim rejection clears success")
            # The next attempt computes pure semantics successfully, then
            # fails the final physical-disk guard. A caught failure cannot keep it.
            mode["value"], mode["ko_reads"] = "final disk", 0
            before_count = receipts.call_count
            reject(lambda: history.predecessor_bytes(raw, history.KO_PATH), "failure after successful semantics")
            check(receipts.call_count == before_count + 1 and not memo[1], "late guard clears newly successful semantics")
            mode["value"] = "good"
            history.predecessor_bytes(raw, history.KO_PATH)
            reject(lambda: history.predecessor_bytes(raw, history.KO_PATH, history.ROOT / "unowned"), "warm wrong root")
            check(not memo[1], "wrong root clears success")
            history.predecessor_bytes(raw, history.KO_PATH)
            old = proof["before"][history.KO_PATH]
            proof["before"][history.KO_PATH] = old + b"\n"
            reject(lambda: history.predecessor_bytes(raw, history.KO_PATH), "mutated returned proof alias")
            check(not memo[1], "returned alias cannot alter immutable memo evidence")
            proof["before"][history.KO_PATH] = old
            history.predecessor_bytes(raw, history.KO_PATH)
            mode["value"] = "objects missing"
            reject(lambda: history._validate_receipts(proof["after"], proof["receipts"], proof["before"], history.ROOT),
                   "direct receipt API still reads typed export objects")
            check(not memo[1], "direct receipt Git failure clears success")
            mode["value"] = "good"
        check(history._SEMANTIC_MEMO.get() is None and not memo[1], "warm scope has no surviving cache")
    for exception in (ValueError, KeyboardInterrupt):
        retained = None
        try:
            with history.fresh_validation_proof():
                retained = history._SEMANTIC_MEMO.get()
                raise exception("fixture consumer escape")
        except exception:
            pass
        check(retained is not None and not retained[1] and history._SEMANTIC_MEMO.get() is None
              and history._ACTIVE.get() is None, "exception escape clears state " + exception.__name__)
    with mock.patch.object(history, "_receipt_semantics", wraps=receipt) as receipts:
        for _ in range(2):
            with history.fresh_validation_proof():
                pass
        check(receipts.call_count == 2, "separate invocations never reuse success")
    return failures, cases, profile


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


def run_coffee_consumer_checks():
    """Exercise448's real current boundary without the expensive365 admission.

    The historical448 pair is read and proved once, then reused only as an
    explicit fixture in negative cases. The470 scope and current Git objects
    remain real except at the particular adversarial edge named by each case.
    """
    import coffee_encounter_receipt_history as coffee
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER470 coffee consumer: " + label)

    def reject(operation, label):
        try:
            operation()
        except (OSError, ValueError, TypeError, KeyError, IndexError):
            check(True, label)
        else:
            check(False, label)

    before, after = coffee._read_pair(history.ROOT)
    real_scope, real_git, read, source_git = (history.fresh_validation_proof, coffee._git,
                                             Path.read_bytes, history._git)
    mode = {"value": "good", "head_reads": 0, "raws": None}

    def coffee_git(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        if args[:2] == ("cat-file", "--batch"):
            if mode["value"] == "missing":
                return b"missing missing\n"
            if mode["value"] == "type":
                return result.replace(b" blob ", b" tree ", 1)
            if mode["value"] == "bytes":
                return result[:-2] + b"X\n"
        if args[:2] == ("rev-parse", "--verify"):
            mode["head_reads"] += 1
            if mode["value"] == "final HEAD" and mode["head_reads"] == 2:
                return ("0" * 40 + "\n").encode()
        if args[0] == "rev-parse" and len(args) == 4 and mode["raws"] is not None:
            return b"".join((history.hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
                              + "\n").encode() for raw in mode["raws"])
        return result

    def live_source_git(root, *args, **kwargs):
        if mode["value"] == "470 missing" and args[:2] == ("cat-file", "--batch"):
            return b"missing missing\n"
        return source_git(root, *args, **kwargs)

    with mock.patch.object(history, "_git", live_source_git), mock.patch.object(coffee, "_git", coffee_git):
        with real_scope() as proof, coffee.previous.fresh_validation_proof():
            expected = {p: proof["current"][p] for p in coffee.EVENT_PATHS}
            actual = coffee.coffee_encounter_current_events()
            check(actual == expected, "real448/470 admission returns actual current3")
            check(set(actual) == set(coffee.EVENT_PATHS), "exact current3 return population")
            for path in coffee.EVENT_PATHS:
                check(actual[path] != after[path] == proof["before"][path], "comparison is not returned " + path)
                old, current = (json.loads(raw) for raw in (after[path], actual[path]))
                row = lambda values: next(r for r in values if r["id"] == coffee.contract.EVENT_ID)
                check(row(old) == row(current), "complete coffee event remains unchanged " + path)

            with mock.patch.object(coffee, "_read_pair", return_value=(before, after)):
                with mock.patch.object(history, "fresh_validation_proof", return_value=contextlib.nullcontext(dict(proof))):
                    reject(coffee.coffee_encounter_current_events, "detached forged successor proof")
                for label, paths in (("wrong path", (*coffee.EVENT_PATHS[:2], history.KO_PATH)),
                                     ("aliased path", (*coffee.EVENT_PATHS[:2], "./" + coffee.EVENT_PATHS[2]))):
                    with mock.patch.object(coffee, "EVENT_PATHS", paths):
                        reject(coffee.coffee_encounter_current_events, label)

                # Alter a yielded active view only after its real entry proof;
                # restore before exit to isolate this consumer's own guards.
                @contextlib.contextmanager
                def changed_view(path, field, raw):
                    @contextlib.contextmanager
                    def scope(root):
                        with real_scope(root) as live:
                            saved = live[field][path]
                            live[field][path] = raw
                            try:
                                yield live
                            finally:
                                live[field][path] = saved
                    with mock.patch.object(history, "fresh_validation_proof", scope):
                        yield

                for path in coffee.EVENT_PATHS:
                    with changed_view(path, "before", after[path] + b"\n"):
                        reject(coffee.coffee_encounter_current_events, "forged comparison " + path)
                    with changed_view(path, "current", after[path]):
                        reject(coffee.coffee_encounter_current_events, "historical rollback " + path)
                    rows = json.loads(expected[path])
                    rows[0]["title"] += "!"
                    mutant = (json.dumps(rows, ensure_ascii=False, indent=2) + "\n").encode()
                    mode["raws"] = [mutant if p == path else expected[p] for p in coffee.EVENT_PATHS]
                    try:
                        with changed_view(path, "current", mutant):
                            reject(coffee.coffee_encounter_current_events, "rehashed neighbor/HEAD claim " + path)
                    finally:
                        mode["raws"] = None
                    def changed_disk(candidate, p=path):
                        return expected[p] + b"\n" if candidate == history.ROOT / p else read(candidate)
                    with mock.patch.object(Path, "read_bytes", changed_disk):
                        reject(coffee.coffee_encounter_current_events, "current disk mutation " + path)
                for label in ("missing", "type", "bytes", "final HEAD", "470 missing"):
                    mode["value"], mode["head_reads"] = label, 0
                    reject(coffee.coffee_encounter_current_events, "warm " + label)
                    mode["value"] = "good"
                check(not history._SEMANTIC_MEMO.get()[1], "caught warm failure clears semantic memo")
                check(coffee.coffee_encounter_current_events() == expected, "fresh recovery after negative fixtures")
            mode["value"] = "missing"
            reject(coffee.coffee_encounter_current_events, "original448 typed objects remain mandatory")
            mode["value"] = "good"
    check(history._ACTIVE.get() is None and history._SEMANTIC_MEMO.get() is None,
          "no proof/cache survives the dedicated invocation")
    return failures, cases


def main():
    coffee_only = sys.argv[1:] == ["--coffee-self-test"]
    failures, cases = run_coffee_consumer_checks() if coffee_only else run()
    for failure in failures:
        print(failure, file=sys.stderr)
    label = "COFFEE_CONSUMER" if coffee_only else "SOURCE_COMPAT"
    print(f"ORDER470_{label}_{'FAIL' if failures else 'OK'} cases={cases} source_paths=9")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
