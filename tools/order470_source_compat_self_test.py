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


def run_person_checks():
    """Actual471 source/receipt deltas; no replay of the unrelated470 corpus."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER471: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, source = proof["person_before"], proof["person_source"]
        check(before is not None and source is not None, "actual authored source stage is bound")
        if before is None or source is None:
            return failures, cases
        check(set(history.PERSON_PRODUCT_PATHS) == set(history.PERSON_PATHS)
              and len(history.PERSON_PRODUCT_PATHS) == 5, "actual source5, not planned metadata edits")
        check(all(before[p] == proof["receipts"][p] for p in proof["receipts"]),
              "person predecessor preserves original470 R4 endpoint")
        check(all(before[p] == source[p] for p in before if p not in history.PERSON_PATHS),
              "source5 leaves ledger, runtime, arcs and inventory/rating unchanged")
        for path in history.PERSON_PATHS:
            check(history.person_product_inverse(before[path], source[path], path) == before[path],
                  "exact whole source inverse " + path)
            for label, raw, claimed_path in (
                ("rollback", before[path], path), ("whitespace", source[path] + b"\n", path),
                ("wrong path", source[path], "./" + path), ("nonbytes", source[path].decode(), path),
            ):
                reject(lambda r=raw, p=claimed_path, old=before[path]: history.person_product_inverse(old, r, p),
                       label + " " + path)
            neighbor = source[path] + b"\n"
            with mock.patch.dict(history.PERSON_RAW_SHA256,
                                 {path: (history._sha(before[path]), history._sha(neighbor))}):
                reject(lambda p=path: history.person_product_inverse(before[p], neighbor, p),
                       "independent raw hunks reject repinned whitespace " + path)
            rows = json.loads(source[path])
            for label, mutate in (
                ("DIK order", lambda row: row.update(description_if_known=dict(reversed(list(row["description_if_known"].items()))))),
                ("DIK missing", lambda row: row["description_if_known"].pop("daeun_divorced")),
                ("DIK extra", lambda row: row["description_if_known"].update(unowned="not admitted")),
                ("old label", lambda row: row["choices"][1].update(text="not admitted")),
            ):
                changed = copy.deepcopy(rows)
                mutate(next(row for row in changed if row["id"] == history.PERSON_EVENT_ID))
                raw = json.dumps(changed, ensure_ascii=False).encode()
                reject(lambda r=raw, p=path: history._person_arc_inverse(before[p], r, p),
                       "structural " + label + " " + path)
        path = history.PERSON_KO_PATH
        for label, mutate in (
            ("gameplay", lambda row: row["choices"][0].update(effects={"money": 1})),
            ("default differs from divorced", lambda row: row["description_if_known"].update(daeun_divorced="not the default")),
        ):
            changed = json.loads(source[path])
            mutate(next(row for row in changed if row["id"] == history.PERSON_EVENT_ID))
            reject(lambda r=json.dumps(changed, ensure_ascii=False).encode():
                   history._person_arc_inverse(before[path], r, path), label)
        for path in history.PERSON_PATHS[2:]:
            selected = (history.PERSON_EDITED_TEXT_LEAVES if path == history.PERSON_PATHS[2]
                        else history.PERSON_TEXT_LEAVES)
            document = history._Document(source[path])
            index = next(i for i, row in enumerate(document.value) if row["id"] == history.PERSON_EVENT_ID)

            def rewritten(selectors, neighbor=False):
                changes = []
                for _eid, keys in selectors:
                    a, z = document.spans[(index, *keys)]
                    changes.append((a, z, json.dumps(history._leaf(document.value[index], keys)
                                                    + " fixture", ensure_ascii=False)))
                if neighbor:
                    a, z = document.spans[(index, "choices", 1, "text")]
                    changes.append((a, z, json.dumps("unowned fixture")))
                text = document.text
                for a, z, value in sorted(changes, reverse=True):
                    text = text[:a] + value + text[z:]
                return text.encode()

            exact = rewritten(selected)
            with mock.patch.dict(history.PERSON_RECEIPT_RAW_SHA256,
                                 {path: (history._sha(source[path]), history._sha(exact))}):
                check(history.person_receipt_overlay_inverse(source[path], exact, path) == source[path],
                      "fixture exact changed-string count " + str(len(selected)) + " " + path)
            for label, raw in (("missing owned edit", rewritten(selected[:-1])),
                               ("unowned label", rewritten(selected, True)),
                               ("neighboring whitespace", exact + b"\n")):
                with mock.patch.dict(history.PERSON_RECEIPT_RAW_SHA256,
                                     {path: (history._sha(source[path]), history._sha(raw))}):
                    reject(lambda r=raw, p=path: history.person_receipt_overlay_inverse(source[p], r, p),
                           "repinned fixture " + label + " " + path)
        if proof["person_receipts"] is not None:
            accepted = proof["person_receipts"]
            history._validate_person_receipts(source, accepted, history.ROOT)
            check(True, "actual18 official leaves are separate from original42")
            old, new = (json.loads(snapshot[history.LEDGER_PATH]) for snapshot in (source, accepted))
            check(sum(map(len, new["accepted"].values())) - sum(map(len, old["accepted"].values())) == 6
                  and len(new["batches"]) - len(old["batches"]) == 3, "six first receipts and three official batches")
            for path in history.PERSON_PATHS[2:]:
                check(history.person_receipt_overlay_inverse(source[path], accepted[path], path) == source[path],
                      "exact locale-specific literal-only target corrections " + path)
                raw = accepted[path] + b"\n"
                with mock.patch.dict(history.PERSON_RECEIPT_RAW_SHA256,
                                     {path: (history._sha(source[path]), history._sha(raw))}):
                    reject(lambda r=raw, p=path: history.person_receipt_overlay_inverse(source[p], r, p),
                           "repinned receipt target neighboring raw " + path)
            for label, mutate in (
                ("old batch prefix", lambda doc: doc["batches"].pop(0)),
                ("old accepted row", lambda doc: doc["accepted"]["ja"].pop(next(iter(doc["accepted"]["ja"])))),
                ("new accepted source", lambda doc: doc["accepted"]["ja"]["events:" + history.PERSON_EVENT_ID
                    + ":/description_if_known/daeun_divorced"].update(source_sha256="0" * 64)),
                ("new accepted target", lambda doc: doc["accepted"]["ja"]["events:" + history.PERSON_EVENT_ID
                    + ":/description_if_known/daeun_divorced"].update(target_sha256="0" * 64)),
            ):
                document = copy.deepcopy(new)
                mutate(document)
                document["accepted_sha256"] = history._digest(document["accepted"])
                raw = (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()
                with mock.patch.dict(history.PERSON_RECEIPT_RAW_SHA256,
                                     {history.LEDGER_PATH: (history._sha(source[history.LEDGER_PATH]), history._sha(raw))}):
                    reject(lambda r=raw: history._person_receipt_semantics(source, {**accepted, history.LEDGER_PATH: r}),
                           "rehashed " + label)
        # A changed reader identity cannot borrow a warm proof.
        snapshot = history._snapshot
        def missing_person(root, revision, paths):
            if revision == history.PERSON_PRODUCT_COMMIT:
                raise ValueError("fixture lost person product")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing_person):
            reject(lambda: history.predecessor_bytes(proof["current"][history.KO_PATH], history.KO_PATH),
                   "warm scope refuses changed reader/object availability")
        check(not history._SEMANTIC_MEMO.get()[1], "failed nested proof clears successful semantic work")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "person test restores caller scope (or leaves no standalone invocation cache)")
    return failures, cases


def run_prose_checks():
    """472 actual source10/receipt16 only; previous42/18 are separate endpoints."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER472: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, source = proof["prose_before"], proof["prose_source"]
        check(before is not None and source is not None, "actual authored source stage is bound")
        if before is None or source is None:
            return failures, cases
        check(len(history.PROSE_SELECTORS) == 8 and len(set(history.PROSE_TEXT_LEAVES)) == 40
              and len(history.PROSE_PRODUCT_PATHS) == 10 and len(history.PROSE_RECEIPT_PATHS) == 16,
              "exact eight scenes/forty selectors/ten source/sixteen receipt paths")
        check(all(before[path] == proof["person_receipts"][path] for path in proof["person_receipts"]),
              "recall predecessor preserves immutable471 acceptance")
        check(all(before[path] == source[path] for path in before if path not in history.PROSE_PRODUCT_PATHS),
              "source stage changes no targets/ledger/runtime/inventory/rating")
        for path in history.PROSE_PRODUCT_PATHS:
            check(history.prose_product_inverse(before[path], source[path], path) == before[path],
                  "exact whole source inverse " + path)
            for label, raw, claimed in (("rollback", before[path], path),
                    ("raw neighbor", source[path] + b"\n", path),
                    ("nonbytes", source[path].decode(), path), ("path alias", source[path], "./" + path)):
                reject(lambda r=raw, p=claimed, old=before[path]: history.prose_product_inverse(old, r, p),
                       label + " " + path)
            mutant = source[path] + b"\n"
            with mock.patch.dict(history.PROSE_RAW_SHA256,
                                 {path: (history._sha(before[path]), history._sha(mutant))}):
                reject(lambda p=path, r=mutant: history.prose_product_inverse(before[p], r, p),
                       "raw hunk proof rejects repinned whitespace " + path)
            # Exercise the independent JSON-span boundary without relying on
            # the immutable whole-file hash to reject the structural mutant.
            selected = history.prose_selectors(path)
            document = history._Document(source[path])
            eid, keys = selected[0]
            index = next(i for i, row in enumerate(document.value) if row["id"] == eid)
            old_row = next(row for row in json.loads(before[path]) if row["id"] == eid)
            a, z = document.spans[(index, *keys)]
            rollback = (document.text[:a] + json.dumps(history._leaf(old_row, keys), ensure_ascii=False)
                        + document.text[z:]).encode()
            rows = copy.deepcopy(document.value)
            rows[index]["unowned_field"] = "mutation"
            neighbor = json.dumps(rows, ensure_ascii=False).encode()
            for label, raw in (("missing owned edit", rollback), ("extra field", neighbor),
                               ("raw layout", source[path] + b"\n")):
                pins = {path: (history._sha(before[path]), history._sha(raw))}
                reject(lambda r=raw, p=path, pins=pins, chosen=selected:
                       history._receipt_overlay_inverse(before[p], r, p, chosen,
                           history.PROSE_PRODUCT_PATHS, pins, (), len(chosen)), "repinned " + label + " " + path)
        if proof["prose_receipts"] is not None:
            accepted = proof["prose_receipts"]
            history._validate_prose_receipts(source, accepted, history.ROOT)
            check(True, "actual120 official corrections have fresh export/ancestor proof")
            old, new = (json.loads(snapshot[history.LEDGER_PATH]) for snapshot in (source, accepted))
            check(all(set(old["accepted"][locale]) == set(new["accepted"][locale]) for locale in history.LOCALES)
                  and sum(sum(value != new["accepted"][locale][key] for key, value in old["accepted"][locale].items())
                          for locale in history.LOCALES) == 120,
                  "exact120 corrections and zero first receipts")
            for path in history.PROSE_PATHS[10:]:
                check(history.prose_receipt_overlay_inverse(source[path], accepted[path], path) == source[path],
                      "exact literal-only target inverse " + path)
                raw = accepted[path] + b"\n"
                with mock.patch.dict(history.PROSE_RECEIPT_RAW_SHA256,
                                     {path: (history._sha(source[path]), history._sha(raw))}):
                    reject(lambda p=path, r=raw: history.prose_receipt_overlay_inverse(source[p], r, p),
                           "repinned target layout rejected " + path)
            identifier = "events:" + history.PROSE_TEXT_LEAVES[0][0] + ":/description"
            for label, mutate in (
                ("old batch prefix", lambda doc: doc["batches"].pop(0)),
                ("first receipt invention", lambda doc: doc["accepted"]["ja"].update(unowned={})),
                ("accepted source", lambda doc: doc["accepted"]["ja"][identifier].update(source_sha256="0" * 64)),
                ("accepted target", lambda doc: doc["accepted"]["ja"][identifier].update(target_sha256="0" * 64)),
            ):
                doc = copy.deepcopy(new)
                mutate(doc)
                doc["accepted_sha256"] = history._digest(doc["accepted"])
                raw = (json.dumps(doc, ensure_ascii=False, indent=2) + "\n").encode()
                with mock.patch.dict(history.PROSE_RECEIPT_RAW_SHA256,
                                     {history.LEDGER_PATH: (history._sha(source[history.LEDGER_PATH]), history._sha(raw))}):
                    reject(lambda r=raw: history._prose_receipt_semantics(source, {**accepted, history.LEDGER_PATH: r}),
                           "rehashed " + label)
        # Existing admission edges still reobserve typed Git/config/disk, even
        # when all pure semantic results have already been warmed in this scope.
        snapshot = history._snapshot
        def missing_source(root, revision, paths):
            if revision == history.PROSE_PRODUCT_COMMIT:
                raise ValueError("fixture lost recall source")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing_source):
            reject(lambda: history._read_proof(history.ROOT), "warm typed-object/reader change rejected")
        check(not history._SEMANTIC_MEMO.get()[1], "failed nested proof clears semantic success entries")
        with mock.patch.object(history, "PROSE_PRODUCT_PARENT", "0" * 40):
            reject(lambda: history._read_proof(history.ROOT), "warm parent/config change rejected")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "restores outer proof identity or leaves no standalone cache")
    return failures, cases


def run_prose_metadata_checks():
    """Actual separate metadata2 delta; never reclassifies source/receipts."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER472 metadata: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, after = proof["prose_current"], proof["prose_metadata"]
        check(after is not None and all(after[p] == proof["ending_before"][p] for p in after),
              "immutable metadata stage is the ending-source predecessor")
        if after is None:
            return failures, cases
        check(before == proof["prose_receipts"], "immutable472 receipt endpoint is not metadata")
        check(all(before[path] == after[path] for path in before if path not in history.PROSE_METADATA_PATHS),
              "every source/target/receipt/protected raw preserved")
        for path in history.PROSE_METADATA_PATHS:
            check(history.prose_metadata_inverse(before[path], after[path], path) == before[path],
                  "exact raw/hunk/literal inverse " + path)
            for label, raw, claimed in (("rollback", before[path], path), ("neighbor", after[path] + b"\n", path),
                                        ("path alias", after[path], "./" + path), ("type", after[path].decode(), path)):
                reject(lambda p=claimed, r=raw, old=before[path]: history.prose_metadata_inverse(old, r, p), label)
            raw = after[path] + b"\n"
            with mock.patch.dict(history.PROSE_METADATA_RAW_SHA256,
                                 {path: (history._sha(before[path]), history._sha(raw))}):
                reject(lambda p=path, r=raw: history.prose_metadata_inverse(before[p], r, p), "repinned raw neighbor")
            reject(lambda p=path: history._prose_metadata_semantics(before[p], after[p] + b"\n", p),
                   "independent literal boundary rejects layout " + path)
        path = history.INVENTORY_PATH
        for label, old, new in (("event census", b'"expected_event_count": 124', b'"expected_event_count": 125'),
                                ("file census", b'"expected_file_count": 26', b'"expected_file_count": 27'),
                                ("classification", b'"id": "sexuality"', b'"id": "unowned"'),
                                ("legal decision", b'"decision_boundary":', b'"unowned_decision_boundary":')):
            check(after[path].count(old) == 1, "fixture exact one field " + label)
            raw = after[path].replace(old, new)
            reject(lambda r=raw: history._prose_metadata_semantics(before[path], r, path), label)
        path = history.RATING_PATH
        raw = after[path].replace(b'124 / 26', b'125 / 26')
        reject(lambda: history._prose_metadata_semantics(before[path], raw, path), "report population changed")
        snapshot = history._snapshot
        def unavailable(root, revision, paths):
            if revision == history.PROSE_METADATA_COMMIT:
                raise ValueError("fixture missing metadata object")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", unavailable):
            reject(lambda: history._prose_metadata_stage(history.ROOT, proof["head"], before), "missing typed metadata object")
            reject(lambda: history._read_proof(history.ROOT), "warm reader/object change")
        check(not history._SEMANTIC_MEMO.get()[1], "failed warm admission clears semantic cache")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "outer context identity restored or standalone scope cleared")
    return failures, cases


def run_ending_facts_checks():
    """Only the changed473 source/receipt/metadata edges, never the old full suite."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER473 ending facts: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, initial, source = (proof[k] for k in ("ending_before", "ending_initial", "ending_source"))
        check(initial is not None and source is not None, "actual source and repaired endpoint bound")
        if initial is None or source is None:
            return failures, cases
        check(len(history.ENDING_PATHS) == 5 and len(history.ENDING_TEXT_LEAVES) == 21,
              "exact5 source files and21 existing selectors")
        check(all(before[p] == proof["prose_metadata"][p] for p in proof["prose_metadata"]),
              "immutable472 metadata/source/120 receipts retained")
        check(all(before[p] == source[p] for p in before if p not in history.ENDING_PATHS),
              "source does not accept receipts or change runtime/other prose")
        for path in history.ENDING_PATHS:
            check(history.ending_product_inverse(before[path], initial[path], path) == before[path],
                  "exact21 JSON literal/raw inverse " + path)
            for label, raw, owner in (("rollback", before[path], path), ("layout", initial[path] + b"\n", path),
                                      ("path alias", initial[path], "./" + path),
                                      ("type", initial[path].decode(), path)):
                reject(lambda a=before[path], b=raw, p=owner: history.ending_product_inverse(a, b, p), label)
            mutant = initial[path] + b"\n"
            pins = {path: (history._sha(before[path]), history._sha(mutant))}
            with mock.patch.dict(history.ENDING_RAW_SHA256, pins):
                reject(lambda p=path, r=mutant: history.ending_product_inverse(before[p], r, p),
                       "rehash cannot waive independent hunk seal")
                reject(lambda p=path, r=mutant: history._receipt_overlay_inverse(
                    before[p], r, p, history.ENDING_TEXT_LEAVES, history.ENDING_PATHS,
                    history.ENDING_RAW_SHA256, (), 21), "literal boundary rejects rehashed layout")
            document = history._Document(initial[path])
            index = next(i for i, row in enumerate(document.value) if row["id"] == "stable_success")
            for label, keys, value in (("neighbor title", (index, "title"), "unowned"),
                                       ("owned rollback", (index, "description"),
                                        history._loads(before[path])[index]["description"])):
                start, end = document.spans[keys]
                raw = (document.text[:start] + json.dumps(value, ensure_ascii=False) + document.text[end:]).encode()
                pins = {path: (history._sha(before[path]), history._sha(raw))}
                reject(lambda p=path, r=raw, q=pins: history._receipt_overlay_inverse(
                    before[p], r, p, history.ENDING_TEXT_LEAVES, history.ENDING_PATHS, q, (), 21),
                       "rehashed semantic " + label)
        path = history.ENDING_PATHS[1]
        check(history.ending_product_inverse(initial[path], source[path], path, repair=True) == initial[path],
              "separate EN12 grammar repair exact inverse")
        reject(lambda: history.ending_product_inverse(initial[path], initial[path], path, repair=True),
               "original EN defect cannot be current repair")
        reject(lambda: history.ending_product_inverse(initial[path], source[path], history.ENDING_PATHS[0], repair=True),
               "repair cannot claim Korean path")
        path = history.ENDING_KO_PATH
        physical = history._disk_bytes
        with mock.patch.object(history, "_disk_bytes", lambda p: physical(p) + b"\n" if p == history.ROOT / path else physical(p)):
            reject(lambda: history._read_proof_current(history.ROOT), "actual physical ending mutation")
            reject(lambda: history._read_proof(history.ROOT), "warm disk reader identity change")
        check(not history._SEMANTIC_MEMO.get()[1], "failed current observation clears pure successes")
        snapshot = history._snapshot
        def missing(root, revision, paths):
            if revision == history.ENDING_PRODUCT_COMMIT:
                raise ValueError("fixture unavailable typed ending object")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing):
            reject(lambda: history._ending_stages(history.ROOT, proof["head"], proof["prose_metadata"]),
                   "missing typed source object")
            reject(lambda: history._read_proof(history.ROOT), "warm reader/config change")
        with mock.patch.object(history, "ENDING_PRODUCT_PARENT", history.ENDING_PRODUCT_COMMIT):
            reject(lambda: history._ending_stages(history.ROOT, proof["head"], proof["prose_metadata"]),
                   "forged source direct parent")
        with mock.patch.object(history, "ENDING_PATHS", history.ENDING_PATHS[:-1]):
            reject(lambda: history._ending_stages(history.ROOT, proof["head"], proof["prose_metadata"]),
                   "incomplete source path population")
        receipts = proof["ending_receipts"]
        if receipts is None:
            check(history.ENDING_RECEIPT_COMMIT is None and proof["current"][history.LEDGER_PATH] == source[history.LEDGER_PATH],
                  "source-only stage claims no63 acceptance")
            reject(lambda: history._ending_receipt_semantics(source, source), "unbound receipts cannot pass")
        else:
            history._validate_ending_receipts(source, receipts, history.ROOT)
            check(history._ending_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH])
                  == source[history.LEDGER_PATH], "raw261 batch prefix and nonowned ledger bytes unchanged")
            for label, mutate in (
                ("old batch prefix", lambda data: data["batches"][0].update(order="forged")),
                ("native review", lambda data: data["batches"][-1].update(native_review="PASS")),
                ("source manifest", lambda data: next(iter(data["batches"][-1]["official_receipt_headers_by_locale"].values())).update(source_manifest_sha256="0" * 64)),
                ("first receipt", lambda data: data["accepted"]["ja"].pop(next(iter(data["accepted"]["ja"])))),
            ):
                data = history._loads(receipts[history.LEDGER_PATH])
                mutate(data)
                raw = (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()
                mutant = {**receipts, history.LEDGER_PATH: raw}
                with mock.patch.dict(history.ENDING_RECEIPT_RAW_SHA256, {history.LEDGER_PATH:
                    (history._sha(source[history.LEDGER_PATH]), history._sha(raw))}):
                    reject(lambda r=mutant: history._ending_receipt_semantics(source, r), label)
            reject(lambda: history._ending_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH] + b"\n"),
                   "rehash cannot waive ledger layout")
            with mock.patch.object(history, "_snapshot", side_effect=ValueError("missing export object")):
                reject(lambda: history._validate_ending_receipts(source, receipts, history.ROOT), "direct receipt API typed export loss")
        metadata = proof["ending_metadata"]
        if metadata is None:
            check(history.ENDING_METADATA_COMMIT is None, "metadata is not claimed before actual pin")
        else:
            check(all(receipts[p] == metadata[p] for p in receipts if p not in history.ENDING_METADATA_PATHS),
                  "metadata preserves source/target/receipt endpoint")
            for path in history.ENDING_METADATA_PATHS:
                check(history.ending_metadata_inverse(receipts[path], metadata[path], path) == receipts[path],
                      "exact ending metadata inverse")
                for label, raw in (("rollback", receipts[path]), ("neighbor", metadata[path] + b"\n")):
                    reject(lambda p=path, r=raw: history.ending_metadata_inverse(receipts[p], r, p), label)
                reject(lambda p=path: history._ending_metadata_semantics(receipts[p], metadata[p] + b"\n", p),
                       "independent metadata literal boundary rejects layout")
            path = history.INVENTORY_PATH
            old = history._loads(receipts[path])
            new = history._loads(metadata[path])
            old_hash, new_hash = history.ENDING_METADATA_FINGERPRINTS
            check(old["corpus_contract"]["ending_content_sha256"] == old_hash
                  and new["corpus_contract"]["ending_content_sha256"] == new_hash
                  and old["content_axes"] == new["content_axes"], "only current ending corpus content hash changes")
            # Synthetic raw pairs independently defeat a wrong owner even if
            # their sole changed literal and both outer raw hashes are valid.
            wrong_owner = {"corpus_contract": {"ending_content_sha256": "unchanged"},
                           "content_axes": [{"candidate_scan": {"expected_content_sha256": old_hash}}]}
            wrong_raw = json.dumps(wrong_owner, ensure_ascii=False).encode()
            reject(lambda: history._ending_metadata_semantics(
                wrong_raw, wrong_raw.replace(old_hash.encode(), new_hash.encode()), path),
                   "axis candidate hash is not the ending corpus field")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "outer identity restored; standalone has no success cache")
    return failures, cases


def run_first_win_checks():
    """Bounded474 source/receipt edges; prior full-suite evidence is separate."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER474 first win: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, initial, source = (proof[key] for key in ("first_win_before", "first_win_initial", "first_win_source"))
        check(initial is not None and source is not None, "actual source5 and repair1 are bound")
        if initial is None or source is None:
            return failures, cases
        check(before == proof["ending_metadata"], "immutable473 endpoint precedes first-win source")
        check(len(history.FIRST_WIN_PATHS) == 5 and len(history.FIRST_WIN_TEXT_LEAVES) == 2,
              "exact two results in five locales")
        check(all(before[p] == source[p] for p in before if p not in history.FIRST_WIN_PATHS),
              "source preserves receipts, metadata, runtime and all other product bytes")
        for path in history.FIRST_WIN_PATHS:
            check(history.first_win_product_inverse(before[path], initial[path], path) == before[path],
                  "exact raw/hunk/two-literal inverse " + path)
            for label, raw, owner in (("rollback", before[path], path), ("layout", initial[path] + b"\n", path),
                                      ("path alias", initial[path], "./" + path),
                                      ("type", initial[path].decode(), path)):
                reject(lambda a=before[path], b=raw, p=owner: history.first_win_product_inverse(a, b, p), label)
            raw = initial[path] + b"\n"
            with mock.patch.dict(history.FIRST_WIN_RAW_SHA256,
                                 {path: (history._sha(before[path]), history._sha(raw))}):
                reject(lambda p=path, r=raw: history.first_win_product_inverse(before[p], r, p), "rehashed layout/hunk")
            document = history._Document(initial[path])
            old_rows = {row["id"]: row for row in history._loads(before[path])}
            rows = {row["id"]: i for i, row in enumerate(document.value)}
            quiet = rows["arc_father_quiet_call"]
            check(document.value[quiet] == old_rows["arc_father_quiet_call"], "legacy demo quiet-call row preserved")
            for label, key, value in (
                ("neighbor title", (rows[history.FIRST_WIN_EVENT_IDS[0]], "title"), "unowned"),
                ("demo row", (quiet, "title"), "unowned"),
                ("missing first correction", (rows[history.FIRST_WIN_EVENT_IDS[0]], "choices", 0, "result_text"),
                 old_rows[history.FIRST_WIN_EVENT_IDS[0]]["choices"][0]["result_text"]),
                ("wrong choice", (rows[history.FIRST_WIN_EVENT_IDS[1]], "choices", 1, "result_text"), "unowned"),
            ):
                a, z = document.spans[key]
                mutant = (document.text[:a] + json.dumps(value, ensure_ascii=False) + document.text[z:]).encode()
                pins = {path: (history._sha(before[path]), history._sha(mutant))}
                reject(lambda p=path, r=mutant, q=pins: history._receipt_overlay_inverse(
                    before[p], r, p, history.FIRST_WIN_TEXT_LEAVES, history.FIRST_WIN_PATHS, q, (), 2),
                       "independent rehashed literal boundary " + label)
        path = history.FIRST_WIN_KO_PATH
        check(history.FIRST_WIN_REPAIR_COMMIT is not None
              and history.first_win_product_inverse(initial[path], source[path], path, repair=True) == initial[path],
              "exact repair inverse retains immutable initial source")
        check(all(initial[p] == source[p] for p in initial if p != path),
              "repair preserves four locales, ledger, runtime and all other bytes")
        for label, raw, owner in (("initial rollback", initial[path], path), ("pre474 rollback", before[path], path),
                                  ("layout", source[path] + b"\n", path),
                                  ("wrong path", source[path], history.FIRST_WIN_PATHS[1]),
                                  ("type", source[path].decode(), path)):
            reject(lambda r=raw, p=owner: history.first_win_product_inverse(initial[path], r, p, repair=True),
                   "repair " + label)
        reject(lambda: history.first_win_product_inverse(before[path], source[path], path),
               "repaired current cannot replace initial source pin")
        for label, raw in (
            ("wrong value", source[path].replace(b"15,000", b"15,001")),
            ("one correction", initial[path].replace("1만5천원짜리".encode(), "15,000원짜리".encode(), 1)),
            ("extra amount", source[path].replace(b"15,000", b"15,000 15,000", 1)),
            ("neighbor", source[path] + b"\n"),
        ):
            with mock.patch.dict(history.FIRST_WIN_REPAIR_RAW_SHA256,
                                 {path: (history._sha(initial[path]), history._sha(raw))}):
                reject(lambda r=raw: history.first_win_product_inverse(initial[path], r, path, repair=True),
                       "rehashed repair " + label)
                reject(lambda r=raw: history._first_win_repair_semantics(initial[path], r, path),
                       "independent repair semantics " + label)
        # Even repinning raw bytes cannot move an exact spelling change into an
        # unowned string: the JSON span boundary is independent of price counts.
        document = history._Document(initial[path])
        rows = {row["id"]: i for i, row in enumerate(document.value)}
        edits = []
        for key, value in (
            ((rows[history.FIRST_WIN_EVENT_IDS[0]], "choices", 0, "result_text"),
             document.value[rows[history.FIRST_WIN_EVENT_IDS[0]]]["choices"][0]["result_text"].replace("1만5천원짜리", "표기")),
            ((rows["arc_father_quiet_call"], "title"),
             document.value[rows["arc_father_quiet_call"]]["title"] + " 1만5천원짜리"),
        ):
            a, z = document.spans[key]
            edits.append((a, z, json.dumps(value, ensure_ascii=False)))
        moved = document.text
        for a, z, value in sorted(edits, reverse=True):
            moved = moved[:a] + value + moved[z:]
        moved = moved.encode()
        reject(lambda: history._first_win_repair_semantics(moved,
               moved.replace("1만5천원짜리".encode(), "15,000원짜리".encode()), path),
               "exact spelling counts do not authorize unowned raw")
        check(proof["prose_current"][path] == before[path] != source[path],
              "472 midgame endpoint is immutable despite shared current path")
        reject(lambda: history._first_win_source_comparison(history.ROOT, proof, {path: history._sha(before[path])}),
               "old source cannot claim current474 census")
        reject(lambda: history._first_win_source_comparison(history.ROOT, proof, {path: history._sha(initial[path])}),
               "initial source cannot claim current repaired census")
        reject(lambda: history._prose_source_comparison(history.ROOT, proof,
            {p: history._sha(proof["current"][p]) for p in history.PROSE_KO_PATHS}),
               "474 current bytes cannot skip their inverse into472")
        with mock.patch.object(history, "FIRST_WIN_PRODUCT_PARENT", history.FIRST_WIN_PRODUCT_COMMIT):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "forged direct parent")
        with mock.patch.object(history, "FIRST_WIN_PATHS", history.FIRST_WIN_PATHS[:-1]):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "incomplete path population")
        with mock.patch.object(history, "FIRST_WIN_REPAIR_PARENT", history.FIRST_WIN_PRODUCT_COMMIT):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "forged repair direct parent")
        with mock.patch.object(history, "FIRST_WIN_REPAIR_PATHS", history.FIRST_WIN_PATHS):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "expanded repair path population")
        snapshot = history._snapshot
        def missing(root, revision, paths):
            if revision == history.FIRST_WIN_PRODUCT_COMMIT:
                raise ValueError("missing474 typed source")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "missing typed source object")
            reject(lambda: history._read_proof(history.ROOT), "warm reader/config mutation")
        def missing_repair(root, revision, paths):
            if revision == history.FIRST_WIN_REPAIR_COMMIT:
                raise ValueError("missing474 typed repair")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing_repair):
            reject(lambda: history._first_win_stages(history.ROOT, proof["head"], before), "missing typed repair object")
            reject(lambda: history._read_proof(history.ROOT), "warm repair reader/config mutation")
        check(not history._SEMANTIC_MEMO.get()[1], "failed warm proof clears pure successes")
        physical = history._disk_bytes
        with mock.patch.object(history, "_disk_bytes", lambda p: physical(p) + b"\n" if p == history.ROOT / path else physical(p)):
            reject(lambda: history._read_proof_current(history.ROOT), "actual physical source differs from Git")
            reject(lambda: history._read_proof(history.ROOT), "warm disk reader identity mutation")
        receipts = proof["first_win_receipts"]
        if receipts is None:
            check(history.FIRST_WIN_RECEIPT_COMMIT is None and proof["current"][history.LEDGER_PATH] == source[history.LEDGER_PATH],
                  "source-only stage claims no6 acceptance")
            reject(lambda: history._first_win_receipt_semantics(source, source), "unbound receipt rejection")
        else:
            history._validate_first_win_receipts(source, receipts, history.ROOT)
            check(history._correction_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH],
                  "events", history.FIRST_WIN_TEXT_LEAVES, 264) == source[history.LEDGER_PATH],
                  "raw264 batch prefix and unowned ledger bytes preserved")
            old, new = (history._loads(stage[history.LEDGER_PATH]) for stage in (source, receipts))
            check(sum(len(v) for v in old["accepted"].values()) == sum(len(v) for v in new["accepted"].values()) == 41848,
                  "all41848 existing receipt keys retained")
            for label, mutate in (
                ("old batch", lambda data: data["batches"][0].update(order="forged")),
                ("native approval", lambda data: data["batches"][-1].update(native_review="PASS")),
                ("census", lambda data: next(iter(data["batches"][-1]["official_receipt_headers_by_locale"].values())).update(source_manifest_sha256="0" * 64)),
                ("unowned key", lambda data: data["accepted"]["ja"].pop(next(iter(data["accepted"]["ja"])))),
            ):
                data = copy.deepcopy(new)
                mutate(data)
                raw = (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()
                mutant = {**receipts, history.LEDGER_PATH: raw}
                with mock.patch.dict(history.FIRST_WIN_RECEIPT_RAW_SHA256, {history.LEDGER_PATH:
                    (history._sha(source[history.LEDGER_PATH]), history._sha(raw))}):
                    reject(lambda r=mutant: history._first_win_receipt_semantics(source, r), "rehashed receipt " + label)
            reject(lambda: history._correction_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH] + b"\n",
                   "events", history.FIRST_WIN_TEXT_LEAVES, 264), "ledger layout cannot bypass raw boundary")
            with mock.patch.object(history, "_snapshot", side_effect=ValueError("missing export object")):
                reject(lambda: history._validate_first_win_receipts(source, receipts, history.ROOT), "direct receipt API export loss")
        check(all(proof["current"][p] == before[p] for p in (*history.ENDING_PATHS, *history.ARC_PATHS,
                  *history.RUNTIME_PATHS, history.INVENTORY_PATH, history.RATING_PATH)),
              "protected product and unchanged metadata remain exact473")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "context restored without cross-invocation success cache")
    return failures, cases


def run_night_routine_checks():
    """Only475 source/receipt and the bounded474 comparison adapter."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER475 night routine: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, source = proof["night_before"], proof["night_source"]
        check(source is not None, "actual source5 is bound")
        if source is None:
            return failures, cases
        check(before == proof["first_win_receipts"], "immutable474 receipt endpoint precedes475")
        check(len(history.NIGHT_PATHS) == 5 and len(history.NIGHT_TEXT_LEAVES) == 2,
              "one root, result and bridge summary, five locales")
        check(all(before[p] == source[p] for p in before if p not in history.NIGHT_PATHS),
              "source changes no receipts/metadata/runtime or other product")
        for path in history.NIGHT_PATHS:
            check(history.night_routine_product_inverse(before[path], source[path], path) == before[path],
                  "exact raw/hunk/two-literal inverse " + path)
            for label, raw, owner in (("rollback", before[path], path), ("layout", source[path] + b"\n", path),
                                      ("alias", source[path], "./" + path), ("type", source[path].decode(), path)):
                reject(lambda r=raw, p=owner: history.night_routine_product_inverse(before[path], r, p), label)
            raw = source[path] + b"\n"
            with mock.patch.dict(history.NIGHT_RAW_SHA256, {path: (history._sha(before[path]), history._sha(raw))}):
                reject(lambda: history.night_routine_product_inverse(before[path], raw, path), "rehashed layout/hunk")
            document = history._Document(source[path])
            rows = {row["id"]: i for i, row in enumerate(document.value)}
            old = {row["id"]: row for row in history._loads(before[path])}
            for label, key, value in (
                ("missing bridge", (rows[history.NIGHT_EVENT_ID], "choices", 1, "bridge_summary"),
                 old[history.NIGHT_EVENT_ID]["choices"][1]["bridge_summary"]),
                ("wrong choice", (rows[history.NIGHT_EVENT_ID], "choices", 0, "result_text"), "unowned"),
                ("first-win result", (rows[history.FIRST_WIN_EVENT_IDS[0]], "choices", 0, "result_text"), "unowned"),
                ("legacy demo", (rows["arc_father_quiet_call"], "title"), "unowned"),
            ):
                a, z = document.spans[key]
                mutant = (document.text[:a] + json.dumps(value, ensure_ascii=False) + document.text[z:]).encode()
                pins = {path: (history._sha(before[path]), history._sha(mutant))}
                reject(lambda r=mutant, q=pins: history._receipt_overlay_inverse(before[path], r, path,
                       history.NIGHT_TEXT_LEAVES, history.NIGHT_PATHS, q, (), 2), "independent rehashed " + label)
        locales = ("ko", "en", *history.LOCALES)
        actual = {locale: proof["current"][path] for locale, path in zip(locales, history.NIGHT_PATHS)}
        compared = history.historical_first_win_comparison(actual)
        check(compared == {locale: before[path] for locale, path in zip(locales, history.NIGHT_PATHS)},
              "historical474 adapter returns only exact pre-night bytes")
        compared["ko"] = b"mutated caller map"
        check(proof["night_before"][history.NIGHT_KO_PATH] == before[history.NIGHT_KO_PATH], "comparison map does not alias proof")
        for label, candidate in (
            ("missing locale", {k: v for k, v in actual.items() if k != "ja"}),
            ("extra locale", {**actual, "other": b""}),
            ("old raw", {**actual, "ko": before[history.NIGHT_KO_PATH]}),
            ("neighbor raw", {**actual, "ja": actual["ja"] + b"\n"}),
            ("wrong type", {**actual, "en": actual["en"].decode()}),
        ):
            reject(lambda r=candidate: history.historical_first_win_comparison(r), "comparison " + label)
        path = history.NIGHT_KO_PATH
        reject(lambda: history._night_source_comparison(history.ROOT, proof, {path: history._sha(before[path])}),
               "old census cannot claim current475")
        reject(lambda: history._first_win_source_comparison(history.ROOT, proof, {path: history._sha(source[path])}),
               "current475 cannot skip inverse into474")
        with mock.patch.object(history, "NIGHT_PRODUCT_PARENT", history.NIGHT_PRODUCT_COMMIT):
            reject(lambda: history._night_stages(history.ROOT, proof["head"], before), "forged direct parent")
        with mock.patch.object(history, "NIGHT_PATHS", history.NIGHT_PATHS[:-1]):
            reject(lambda: history._night_stages(history.ROOT, proof["head"], before), "incomplete source paths")
        snapshot = history._snapshot
        def missing(root, revision, paths):
            if revision == history.NIGHT_PRODUCT_COMMIT:
                raise ValueError("missing475 typed source")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing):
            reject(lambda: history._night_stages(history.ROOT, proof["head"], before), "missing typed source")
            reject(lambda: history.historical_first_win_comparison(actual), "warm comparison cannot retain missing proof")
        check(not history._SEMANTIC_MEMO.get()[1], "failed warm proof clears pure successes")
        physical = history._disk_bytes
        with mock.patch.object(history, "_disk_bytes", lambda p: physical(p) + b"\n" if p == history.ROOT / path else physical(p)):
            reject(lambda: history._read_proof_current(history.ROOT), "actual disk differs from Git")
            reject(lambda: history.historical_first_win_comparison(actual), "warm comparison disk reader identity")
        receipts = proof["night_receipts"]
        if receipts is None:
            check(history.NIGHT_RECEIPT_COMMIT is None and proof["current"][history.LEDGER_PATH] == before[history.LEDGER_PATH],
                  "source stage claims no six receipts")
            reject(lambda: history._night_receipt_semantics(source, source), "unbound receipt rejected")
        else:
            history._validate_night_receipts(source, receipts, history.ROOT)
            check(history._correction_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH],
                  "events", history.NIGHT_TEXT_LEAVES, 267) == source[history.LEDGER_PATH], "exact old267 raw prefix")
            old, new = (history._loads(stage[history.LEDGER_PATH]) for stage in (source, receipts))
            check(sum(map(len, old["accepted"].values())) == sum(map(len, new["accepted"].values())) == 41848,
                  "unchanged accepted key population")
            for label, mutate in (
                ("old batch", lambda data: data["batches"][0].update(order="forged")),
                ("native approval", lambda data: data["batches"][-1].update(native_review="PASS")),
                ("census", lambda data: next(iter(data["batches"][-1]["official_receipt_headers_by_locale"].values())).update(source_manifest_sha256="0" * 64)),
                ("unowned key", lambda data: data["accepted"]["ja"].pop(next(iter(data["accepted"]["ja"])))),
            ):
                data = copy.deepcopy(new)
                mutate(data)
                raw = (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()
                with mock.patch.dict(history.NIGHT_RECEIPT_RAW_SHA256, {history.LEDGER_PATH:
                    (history._sha(source[history.LEDGER_PATH]), history._sha(raw))}):
                    reject(lambda r=raw: history._night_receipt_semantics(source, {**receipts, history.LEDGER_PATH: r}),
                           "rehashed receipt " + label)
            reject(lambda: history._correction_ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH] + b"\n",
                   "events", history.NIGHT_TEXT_LEAVES, 267), "ledger layout rejected")
            with mock.patch.object(history, "_snapshot", side_effect=ValueError("missing export")):
                reject(lambda: history._validate_night_receipts(source, receipts, history.ROOT), "direct receipt export loss")
        check(all((history.night_metadata_inverse(before[p], proof["current"][p], p) == before[p]
                   if proof["night_metadata"] is not None and p in history.NIGHT_METADATA_PATHS
                   else proof["current"][p] == before[p])
                  for p in (*history.ENDING_PATHS, *history.ARC_PATHS, *history.RUNTIME_PATHS,
                            history.INVENTORY_PATH, history.RATING_PATH)), "protected product or exact metadata inverse remains474")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "context restored without cross-invocation cache")
    return failures, cases


def run_night_metadata_checks():
    """Only475's two observed content fingerprints and their typed stage."""
    failures, cases = [], 0
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER475 night metadata: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        before, after = proof["night_receipts"], proof["night_metadata"]
        check(before is not None and after is not None and proof["current"] == after, "actual metadata2 current endpoint")
        if before is None or after is None:
            return failures, cases
        check(all(before[p] == after[p] for p in before if p not in history.NIGHT_METADATA_PATHS),
              "all authored source, runtime, targets and receipts preserved")
        for path in history.NIGHT_METADATA_PATHS:
            check(history.night_metadata_inverse(before[path], after[path], path) == before[path], "exact raw/hunk/literal inverse")
            for label, raw, owner in (("rollback", before[path], path), ("layout", after[path] + b"\n", path),
                                      ("alias", after[path], "./" + path), ("type", after[path].decode(), path)):
                reject(lambda r=raw, p=owner: history.night_metadata_inverse(before[path], r, p), label)
            raw = after[path] + b"\n"
            with mock.patch.dict(history.NIGHT_METADATA_RAW_SHA256, {path: (history._sha(before[path]), history._sha(raw))}):
                reject(lambda: history.night_metadata_inverse(before[path], raw, path), "rehashed layout/hunk")
            reject(lambda: history._night_metadata_semantics(before[path], raw, path), "independent raw layout")
            for axis, old, new in history.NIGHT_METADATA_FINGERPRINTS:
                for label, mutant in (("missing one", after[path].replace(new.encode(), old.encode())),
                                      ("wrong value", after[path].replace(new.encode(), b"0" * 64))):
                    reject(lambda r=mutant: history._night_metadata_semantics(before[path], r, path), axis + " " + label)
        path = history.INVENTORY_PATH
        document = history._Document(after[path])
        for axis, _old, _new in history.NIGHT_METADATA_FINGERPRINTS:
            index = next(i for i, row in enumerate(document.value["content_axes"]) if row["id"] == axis)
            for field in ("expected_event_count", "expected_file_count"):
                key = ("content_axes", index, "candidate_scan", field)
                a, z = document.spans[key]
                raw = (document.text[:a] + str(history._leaf(document.value, key) + 1) + document.text[z:]).encode()
                reject(lambda r=raw: history._night_metadata_semantics(before[path], r, path), axis + " " + field)
        # Swap the hash fields in both valid JSONs: whole-text replacement still
        # matches, but the content fingerprints no longer belong to their owner.
        wrong_owner = []
        for raw in (before[path], after[path]):
            doc = history._Document(raw)
            index = next(i for i, row in enumerate(doc.value["content_axes"]) if row["id"] == "sexuality")
            keys = [("content_axes", index, "candidate_scan", field)
                    for field in ("expected_content_sha256", "expected_ids_sha256")]
            spans = [doc.spans[key] for key in keys]
            text = doc.text
            edits = [(a, z, json.dumps(history._leaf(doc.value, keys[1 - i]))) for i, (a, z) in enumerate(spans)]
            for a, z, value in sorted(edits, reverse=True):
                text = text[:a] + value + text[z:]
            wrong_owner.append(text.encode())
        reject(lambda: history._night_metadata_semantics(*wrong_owner, path), "independent candidate owner field")
        for label, raw in (("classification", after[path].replace(b'"id": "sexuality"', b'"id": "unowned"')),
                           ("decision", after[path].replace(b'"decision_boundary":', b'"unowned_decision_boundary":'))):
            check(raw != after[path], "mutant really changes " + label)
            reject(lambda r=raw: history._night_metadata_semantics(before[path], r, path), label)
        path = history.RATING_PATH
        reject(lambda: history._night_metadata_semantics(before[path], after[path].replace(b"124 / 26", b"125 / 26"), path),
               "generated report population")
        with mock.patch.object(history, "NIGHT_METADATA_PARENT", history.NIGHT_METADATA_COMMIT):
            reject(lambda: history._night_metadata_stage(history.ROOT, proof["head"], before), "wrong direct parent")
        with mock.patch.object(history, "NIGHT_METADATA_PATHS", (history.INVENTORY_PATH,)):
            reject(lambda: history._night_metadata_stage(history.ROOT, proof["head"], before), "incomplete paths")
        snapshot = history._snapshot
        def missing(root, revision, paths):
            if revision == history.NIGHT_METADATA_COMMIT:
                raise ValueError("missing475 metadata")
            return snapshot(root, revision, paths)
        with mock.patch.object(history, "_snapshot", missing):
            reject(lambda: history._night_metadata_stage(history.ROOT, proof["head"], before), "missing typed metadata")
            reject(lambda: history._read_proof(history.ROOT), "warm changed reader/object")
        check(not history._SEMANTIC_MEMO.get()[1], "failed warm metadata clears semantic memo")
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "context restored without cross-invocation cache")
    return failures, cases


def run_loss_hold_checks(root=history.ROOT):
    """477 only: actual current admission, exact inverse and closed successors."""
    failures, cases = [], 0
    active, memo = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER477 loss-hold: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof(root) as proof:
        before, source, actual = (proof[k] for k in ("loss_hold_before", "loss_hold_source", "current"))
        check({p for p in before if before[p] != source[p]} == set(history.LOSS_HOLD_PATHS), "exact source5")
        check(before[history.LEDGER_PATH] == source[history.LEDGER_PATH], "source is not acceptance")
        check(proof["night_metadata"] == before, "immutable475 metadata endpoint retained")
        locales = ("ko", "en", *history.LOCALES)
        current = {locale: actual[path] for locale, path in zip(locales, history.LOSS_HOLD_PATHS)}
        expected = {locale: before[path] for locale, path in zip(locales, history.LOSS_HOLD_PATHS)}
        original = dict(current)
        comparison = history.historical_loss_hold_comparison(current, root)
        check(comparison == expected and current == original, "comparison only; actual input untouched")
        comparison["ko"] = b"forged"
        check(history.historical_loss_hold_comparison(current, root) == expected, "no mutable result alias")
        for path in history.LOSS_HOLD_PATHS:
            check(history.loss_hold_product_inverse(before[path], source[path], path) == before[path], "raw/hunk/JSON inverse " + path)
            check(actual[path] == source[path], "receipt and metadata never roll back current prose " + path)
            for label, raw, owner in (("rollback", before[path], path), ("layout", source[path] + b"\n", path),
                                      ("type", source[path].decode(), path), ("alias", source[path], "./" + path)):
                reject(lambda r=raw, p=owner: history.loss_hold_product_inverse(before[path], r, p), label + path)
            raw = source[path] + b"\n"
            with mock.patch.dict(history.LOSS_HOLD_RAW_SHA256, {path: (history._sha(before[path]), history._sha(raw))}):
                reject(lambda: history.loss_hold_product_inverse(before[path], raw, path), "rehashed hunk " + path)
            #Independent semantic guard: repinning cannot extend the owned leaf.
            doc = history._Document(source[path])
            index = next(i for i, row in enumerate(doc.value) if row["id"] == "arc_invest_first_loss")
            key = (index, "choices", 0, "result_text")
            a, z = doc.spans[key]
            mutant = (doc.text[:a] + json.dumps(history._leaf(doc.value, key) + "!", ensure_ascii=False) + doc.text[z:]).encode()
            pins = {path: (history._sha(before[path]), history._sha(mutant))}
            reject(lambda: history._receipt_overlay_inverse(before[path], mutant, path, history.LOSS_HOLD_TEXT_LEAVES,
                   history.LOSS_HOLD_PATHS, pins, (), 1), "independently rehashed neighbor " + path)
        variants = (("old", expected), ("mixed", {**current, "ja": expected["ja"]}),
                    ("missing", {k: v for k, v in current.items() if k != "en"}),
                    ("extra", {**current, "other": b"x"}), ("nonbytes", {**current, "ko": bytearray(current["ko"])}),
                    ("neighbor", {**current, "ko": current["ko"] + b"\n"}))
        for label, rows in variants:
            reject(lambda r=rows: history.historical_loss_hold_comparison(r, root), "public " + label)
        with mock.patch.object(history, "LOSS_HOLD_PRODUCT_PARENT", history.LOSS_HOLD_PRODUCT_COMMIT):
            reject(lambda: history._loss_hold_stages(root, proof["head"], before), "wrong direct parent")
        with mock.patch.object(history, "LOSS_HOLD_PATHS", history.LOSS_HOLD_PATHS[:-1]):
            reject(lambda: history._loss_hold_stages(root, proof["head"], before), "incomplete paths")
        with mock.patch.object(history, "LOSS_HOLD_PRODUCT_COMMIT", None):
            reject(lambda: history._loss_hold_stages(root, proof["head"], before), "unbound source")
        receipt = proof["loss_hold_receipts"]
        if receipt is None:
            check(actual == source and proof["loss_hold_metadata"] is None, "source-only remains unaccepted")
            reject(lambda: history._validate_loss_hold_receipts(source, source, root), "unbound receipt cannot pass")
        else:
            history._validate_loss_hold_receipts(source, receipt, root)
            check(True, "actual official receipt typed export and ancestor")
            check(history._correction_ledger_inverse(source[history.LEDGER_PATH], receipt[history.LEDGER_PATH],
                  "events", history.LOSS_HOLD_TEXT_LEAVES, 270) == source[history.LEDGER_PATH], "270 raw prefix and owned3 inverse")
            reject(lambda: history._validate_loss_hold_receipts(source, source, root), "receipt rollback")
            changed = {**receipt, history.LOSS_HOLD_PATHS[2]: source[history.LOSS_HOLD_PATHS[2]] + b"\n"}
            reject(lambda: history._validate_loss_hold_receipts(source, changed, root), "receipt cannot change target")
            changed = receipt[history.LEDGER_PATH] + b"\n"
            reject(lambda: history._correction_ledger_inverse(source[history.LEDGER_PATH], changed,
                   "events", history.LOSS_HOLD_TEXT_LEAVES, 270), "independent ledger layout")
        metadata = proof["loss_hold_metadata"]
        if metadata is not None:
            check({p for p in receipt if receipt[p] != metadata[p]} == set(history.LOSS_HOLD_METADATA_PATHS), "metadata exact2")
            for path in history.LOSS_HOLD_METADATA_PATHS:
                check(history.loss_hold_metadata_inverse(receipt[path], metadata[path], path) == receipt[path], "fear raw/JSON inverse")
                for label, raw in (("rollback", receipt[path]), ("layout", metadata[path] + b"\n"),
                                   ("wrong value", metadata[path].replace(history.LOSS_HOLD_METADATA_FINGERPRINTS[0][2].encode(), b"0" * 64))):
                    reject(lambda r=raw: history._loss_hold_metadata_semantics(receipt[path], r, path), "fear " + label)
    check(history._ACTIVE.get() is active and history._SEMANTIC_MEMO.get() is memo, "scope identity restored")
    for kind in ("Git", "configuration", "disk"):
        def warm():
            with history.fresh_validation_proof(root):
                if kind == "Git":
                    with mock.patch.object(history, "_git", side_effect=ValueError("missing object")):
                        history.historical_loss_hold_comparison(current, root)
                elif kind == "configuration":
                    with mock.patch.object(history, "LOSS_HOLD_PRODUCT_COMMIT", None):
                        history.historical_loss_hold_comparison(current, root)
                else:
                    read = history._disk_bytes
                    with mock.patch.object(history, "_disk_bytes", side_effect=lambda p: read(p) + b"\n" if p == Path(root) / history.LOSS_HOLD_KO_PATH else read(p)):
                        history.historical_loss_hold_comparison(current, root)
        reject(warm, "warm " + kind)
        check(history._ACTIVE.get() is active and history._SEMANTIC_MEMO.get() is memo, "failed scope restores " + kind)
    return failures, cases


def run_market_cycle_checks(root=history.ROOT, inventory=None):
    """478 changes only this owner's final ledger, never470..477 stages."""
    import market_cycle_label_history as market
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER478 ledger admission: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    active, memo = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()
    with history.fresh_validation_proof(root) as proof, market.fresh_validation_proof(root) as market_proof:
        prior, current = proof["market_before"], proof["current"]
        check(prior == proof["loss_hold_metadata"], "immutable477 metadata endpoint")
        check(proof["market_source"] == prior, "source2 changes no470-owned payload")
        check(current[history.LEDGER_PATH] == market_proof["current"][history.LEDGER_PATH], "actual current ledger")
        check(all(current[p] == prior[p] for p in prior if p != history.LEDGER_PATH), "all prose/runtime/inventory actual and unchanged")
        old = history._loads(prior[history.LEDGER_PATH])
        check(len(old["batches"]) == 273 and sum(map(len, old["accepted"].values())) == 41848, "old273/41848 endpoint remains")
        if market.RECEIPT_COMMIT is None:
            check(proof["market_receipts"] is None and current == prior, "source-only no new receipt")
        else:
            check(current == proof["market_receipts"] and current != prior, "separate actual receipt stage")
            check(market._ledger_inverse(prior[history.LEDGER_PATH], current[history.LEDGER_PATH]) == prior[history.LEDGER_PATH], "exact first1 inverse")
        frozen = copy.deepcopy(market_proof)
        frozen["current"][history.LEDGER_PATH] += b"\n"
        if frozen["receipts"] is not None:
            frozen["receipts"][history.LEDGER_PATH] = frozen["current"][history.LEDGER_PATH]
        else:
            frozen["source"][history.LEDGER_PATH] = frozen["current"][history.LEDGER_PATH]
        @contextlib.contextmanager
        def fake(_root=root):
            yield frozen
        with mock.patch.object(market, "fresh_validation_proof", fake):
            reject(lambda: history._read_proof(root), "forged successor fails actual typed final boundary")
        with mock.patch.object(market, "_snapshot", side_effect=ValueError("missing478 typed object")):
            reject(lambda: history._read_proof(root), "warm missing478 proof")
    check(history._ACTIVE.get() is active and history._SEMANTIC_MEMO.get() is memo, "original scope identity restored")
    return failures, cases


def run_wealth_milestone_checks(root=history.ROOT, inventory=None):
    """Only the new480 boundary; the older test populations remain intact."""
    import wealth_milestone_log_history as wealth
    import contextlib
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER480: " + label)
    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)
    with history.fresh_validation_proof(root) as proof, wealth.fresh_validation_proof(root) as later:
        path = wealth.GAME_STATE_PATH
        old = proof["market_receipts"] if proof["market_receipts"] is not None else proof["market_source"]
        check(proof["wealth_before"] == old, "immutable470/478 endpoint")
        check(proof["wealth_source"][path] == later["source"][path] and proof["current"][path] == later["current"][path], "actual GameState payload")
        check({p for p in old if old[p] != proof["wealth_source"][p]} == {path}, "source changes only owned GS")
        check(history.predecessor_bytes(proof["current"][path], path, root) == proof["before"][path], "public actual to pre470 comparison")
        reject(lambda: history.predecessor_bytes(old[path], path, root), "old GS cannot claim actual")
        check(proof["current"][history.LEDGER_PATH] == later["current"][history.LEDGER_PATH], "actual ledger endpoint")
        for stage in ("after", "receipts", "person_source", "person_receipts", "prose_source", "prose_current",
                      "ending_source", "first_win_source", "night_source", "loss_hold_source", "market_source", "market_receipts"):
            if proof[stage] is not None:
                check(proof[stage][path] == old[path], "old GS endpoint remains " + stage)
        with mock.patch.object(wealth, "_snapshot", side_effect=ValueError("missing480 object")):
            reject(lambda: history.predecessor_bytes(later["current"][path], path, root), "warm missing480 typed evidence")
    return failures, cases


def main():
    if sys.argv[1:] == ["--wealth-milestone-only"]:
        failures, cases = run_wealth_milestone_checks()
        for failure in failures:
            print(failure, file=sys.stderr)
        print(f"ORDER480_FACT_WEALTH_{'FAIL' if failures else 'OK'} cases={cases}")
        return int(bool(failures))
    coffee_only = sys.argv[1:] == ["--coffee-self-test"]
    person_only = sys.argv[1:] == ["--person-self-test"]
    prose_only = sys.argv[1:] == ["--prose-self-test"]
    metadata_only = sys.argv[1:] == ["--prose-metadata-self-test"]
    ending_only = sys.argv[1:] == ["--ending-facts-only"]
    first_win_only = sys.argv[1:] == ["--first-win-only"]
    night_only = sys.argv[1:] == ["--night-routine-only"]
    night_metadata_only = sys.argv[1:] == ["--night-metadata-only"]
    loss_hold_only = sys.argv[1:] == ["--loss-hold-only"]
    market_only = sys.argv[1:] == ["--market-cycle-only"]
    failures, cases = (run_market_cycle_checks() if market_only else run_loss_hold_checks() if loss_hold_only else run_night_metadata_checks() if night_metadata_only else run_night_routine_checks() if night_only else run_first_win_checks() if first_win_only else run_ending_facts_checks() if ending_only else run_prose_metadata_checks() if metadata_only else run_prose_checks() if prose_only else run_person_checks() if person_only else
                       run_coffee_consumer_checks() if coffee_only else run())
    for failure in failures:
        print(failure, file=sys.stderr)
    label = "COFFEE_CONSUMER" if coffee_only else "SOURCE_COMPAT"
    prefix = "ORDER478_MARKET_RECEIPT" if market_only else "ORDER477_LOSS_HOLD" if loss_hold_only else "ORDER475_NIGHT_METADATA" if night_metadata_only else "ORDER475_NIGHT_ROUTINE" if night_only else "ORDER474_FIRST_WIN" if first_win_only else "ORDER473_ENDING_FACTS" if ending_only else "ORDER472_METADATA" if metadata_only else "ORDER472_PROSE" if prose_only else "ORDER471_PERSON" if person_only else "ORDER470_" + label
    print(f"{prefix}_{'FAIL' if failures else 'OK'} cases={cases} source_paths={0 if market_only or night_metadata_only else 5 if loss_hold_only or night_only or first_win_only or ending_only else 0 if metadata_only else 10 if prose_only else 5 if person_only else 9}")
    return int(bool(failures))


def run_whitespace_checks(root=history.ROOT):
    """483 scanner/immutable477 equivalence; no current or warmed Git proof."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER483 whitespace: " + label)

    def original_ws(self, index):
        while index < len(self.text) and self.text[index].isspace():
            index += 1
        return index

    class OriginalDocument(history._Document):
        ws = original_ws

    def outcome(function, text, index):
        document = object.__new__(history._Document)
        document.text = text
        try:
            return "value", function(document, index)
        except Exception as error:
            return "error", (type(error), error.args)

    def same_scan(text, index):
        old, new = outcome(original_ws, text, index), outcome(history._Document.ws, text, index)
        if old[0] != new[0]:
            return False
        if old[0] == "error":
            return old[1] == new[1]
        prior, current = old[1], new[1]
        return (type(prior) is type(current) and (prior is current or prior == current)
                and (prior is index) == (current is index))

    whitespace = tuple(chr(code) for code in range(sys.maxunicode + 1) if chr(code).isspace())
    check(bool(whitespace), "Unicode whitespace population is not empty")
    for character in whitespace:
        text = "한🙂" + character * 3 + "x"
        check(all(same_scan(text, index) for index in range(len(text) + 1)),
              "all indices around Unicode whitespace U+%04X" % ord(character))
    for text in ("", "x", "\u200b", "\ufeff", "\u200b \ufeff", "한🙂 \t끝", "".join(whitespace)):
        check(all(same_scan(text, index) for index in range(len(text) + 1)),
              "valid-index nonspace/boundary " + repr(text))

    class Index(int):
        pass

    class Text(str):
        pass

    class IndexedText(str):
        def __getitem__(self, index):
            raise RuntimeError("original subclass indexing")

    indices = (False, True, Index(0), Index(1000), -1, -2, -3, -4, 4, 10 ** 100,
               -0.5, 0.0, 1.0, 4.5, float("nan"), float("inf"), None, "0", object())
    for index in indices:
        check(all(same_scan(text, index) for text in ("", "x  ", "  x", " \t ")),
              "fallback value/type/identity/exception " + repr(index))
    for text in (Text("  x"), IndexedText("  x"), b"  x", [" ", "x"], (), None, 5):
        check(all(same_scan(text, index) for index in (False, 0, 1, -1, 1000)),
              "non-builtin text fallback " + repr(text))
    for text, index in (("x" * 1000, int("999")), (" " * 1000, int("1000")),
                        ("x" * 1000 + " ", int("999")), ("x" * 999 + " ", int("999"))):
        check(same_scan(text, index), "large exact-int return identity " + repr(index))

    class ForeignReceiver:
        def __init__(self, values):
            self.values, self.reads = values, 0

        @property
        def text(self):
            value = self.values[min(self.reads, len(self.values) - 1)]
            self.reads += 1
            if isinstance(value, Exception):
                raise value
            return value

    class SubclassReceiver(history._Document):
        __init__ = ForeignReceiver.__init__
        text = ForeignReceiver.text

    def receiver_outcome(function, cls, values, index):
        receiver = cls(values)
        try:
            value = function(receiver, index)
            result = ("value", type(value), value, value is index)
        except Exception as error:
            result = ("error", type(error), error.args)
        return result, receiver.reads

    receiver_cases = (((" x",), 0), ((" x", "x ", "x"), 0),
                      (("x", ValueError("second getter")), 0),
                      ((RuntimeError("first getter"),), 0),
                      (("x", RuntimeError("unexpected extra getter")), 1000),
                      (("x", RuntimeError("unexpected extra getter")), True),
                      (("x",), Index(0)), (("x",), 0.0), (("x",), -2))
    for cls in (ForeignReceiver, SubclassReceiver):
        for ordinal, (values, index) in enumerate(receiver_cases):
            check(receiver_outcome(original_ws, cls, values, index)
                  == receiver_outcome(history._Document.ws, cls, values, index),
                  "foreign/subclass getter value/type/identity/reads/exception " + cls.__name__ + str(ordinal))

    def document_state(document):
        #470 deliberately accepts JSONDecoder's nonfinite constants; do not
        #copy the newer market helper's stricter parse_constant contract here.
        return (json.dumps(document.value, ensure_ascii=False, allow_nan=True),
                type(document.value), document.text, document.spans)

    value = {"한🙂": [None, True, False, -12.5, {"escaped": 'quote" slash\\ newline\n'}],
             "empty": {}, "list": [], "nested": {"x": [1, "끝"]}}
    valid = (b"{}", b"[]", b"null", b"17", '"한🙂"'.encode(),
             json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode(),
             (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode(),
             (json.dumps(value, ensure_ascii=True, indent=2).replace("\n", "\r\n") + "\r\n").encode(),
             b' \t\r\n{"spaced" : [ 1 , { "x" : "y" } ] } \r\n',
             b'NaN', b'Infinity', b'-Infinity', b'{"x":[NaN,Infinity,-Infinity]}')
    for index, raw in enumerate(valid):
        old, new = OriginalDocument(raw), history._Document(raw)
        check(document_state(old) == document_state(new), "Document exact value/text/spans " + str(index))
        check(all(new.text[a:z] == old.text[a:z] for a, z in new.spans.values())
              and new.text.encode() == raw, "character spans preserve raw UTF-8 " + str(index))
    invalid = (b'{"x":1,"x":2}', b'{"x":{"a":1,"a":2}}', b'{} trailing', b'{}{}',
               b'{"x":1,}', b'[1,]', b'{"x" 1}', b'"unterminated', b'\xff')
    invalid += tuple((character + '{}').encode() for character in whitespace if character not in " \t\r\n")
    invalid += tuple(('{"x":' + character + '1}').encode() for character in ("\u00a0", "\u2003", "\u200b", "\ufeff"))
    for index, raw in enumerate(invalid):
        errors = []
        for cls in (OriginalDocument, history._Document):
            try:
                cls(raw)
            except Exception as error:
                errors.append((type(error), error.args))
        check(len(errors) == 2 and errors[0] == errors[1], "original JSON rejection unchanged " + str(index))

    #Read only the six immutable historical inputs. This is not a current
    #census, accepted-current receipt check, or a warmed admission scope.
    receipt_parent = "fb9952cd1c5fbd8d128d487d20902ca10429a42d"
    receipt_revision = "fb766fd7fc17a574bc00ffcbcd278fb03b797cee"
    check((history.LOSS_HOLD_RECEIPT_PARENT, history.LOSS_HOLD_RECEIPT_COMMIT)
          == (receipt_parent, receipt_revision), "declared historical tuple remains exact")
    paths = (*history.LOSS_HOLD_PATHS, history.LEDGER_PATH)
    before, _ = history._snapshot(root, receipt_parent, paths)
    after, headers = history._snapshot(root, receipt_revision, paths)
    check([row[7:].decode() for row in headers if row.startswith(b"parent ")]
          == [history.LOSS_HOLD_RECEIPT_PARENT], "actual historical receipt direct parent")
    check(all(before[path] == after[path] for path in history.LOSS_HOLD_PATHS),
          "historical receipt changes no source5 bytes")
    prior, current = before[history.LEDGER_PATH], after[history.LEDGER_PATH]
    check((history._sha(prior), history._sha(current))
          == history.LOSS_HOLD_RECEIPT_RAW_SHA256[history.LEDGER_PATH], "historical pinned ledger pair")
    for label, raw in (("before", prior), ("after", current)):
        check(document_state(OriginalDocument(raw)) == document_state(history._Document(raw)),
              "historical ledger exact value/text/spans " + label)
    inverse_args = (prior, current, "events", history.LOSS_HOLD_TEXT_LEAVES, 270)
    with mock.patch.object(history._Document, "ws", original_ws):
        old_inverse = history._correction_ledger_inverse(*inverse_args)
        old_revisions = history._loss_hold_receipt_semantics(before, after)
    check(old_inverse is prior and history._correction_ledger_inverse(*inverse_args) is prior,
          "270 raw prefix inverse returns the original bytes object")
    new_revisions = history._loss_hold_receipt_semantics(before, after)
    check(type(old_revisions) is type(new_revisions) is tuple
          and old_revisions == new_revisions == (history.LOSS_HOLD_RECEIPT_PARENT,),
          "historical receipt headers and export revision unchanged")

    def receipt_error(raw):
        try:
            history._loss_hold_receipt_semantics(before, {**after, history.LEDGER_PATH: raw})
        except Exception as error:
            return type(error), error.args
        return None

    document = history._Document(current)
    owned = {"events:" + eid + ":/" + "/".join(map(str, keys)) for eid, keys in history.LOSS_HOLD_TEXT_LEAVES}
    unowned = next(key for key in document.value["accepted"]["ja"] if key not in owned)
    changed = copy.deepcopy(document.value)
    changed["accepted"]["ja"][unowned]["target_sha256"] = "0" * 64
    replacements = []
    for key, replacement in ((("accepted", "ja", unowned, "target_sha256"), "0" * 64),
                             (("accepted_sha256",), history._digest(changed["accepted"]))):
        a, z = document.spans[key]
        replacements.append((a, z, json.dumps(replacement)))
    text = document.text
    for a, z, replacement in sorted(replacements, reverse=True):
        text = text[:a] + replacement + text[z:]
    mutants = (("layout", current + b"\n"),
               ("neighbor", current.replace(b'"native_review": "OPEN"', b'"native_review": "PASS"', 1)),
               ("unowned accepted leaf and rehashed accepted digest", text.encode()))
    for label, raw in mutants:
        check(raw != current, "receipt mutant changes bytes " + label)
        with mock.patch.dict(history.LOSS_HOLD_RECEIPT_RAW_SHA256,
                             {history.LEDGER_PATH: (history._sha(prior), history._sha(raw))}):
            with mock.patch.object(history._Document, "ws", original_ws):
                old_error = receipt_error(raw)
            new_error = receipt_error(raw)
        check(old_error is not None and old_error == new_error and old_error[0] is ValueError,
              "independently rehashed mutation has original rejection " + label)

    #Exercise only the binding rejection before _read_proof_current/Git. A
    #synthetic memo here is not evidence of an actual warmed live proof.
    active_before, memo_before = history._ACTIVE.get(), history._SEMANTIC_MEMO.get()
    real_disk = history._disk_bytes
    module = Path(history.__file__).resolve()
    for kind in ("ws", "module"):
        armed = [False]
        def read(path):
            raw = real_disk(path)
            return raw + b"\n" if armed[0] and Path(path).resolve() == module else raw
        with contextlib.ExitStack() as stack:
            git = stack.enter_context(mock.patch.object(history, "_git", side_effect=AssertionError("unexpected live proof")))
            stack.enter_context(mock.patch.object(history, "_disk_bytes", read))
            binding = history._semantic_binding(root)
            memo = (binding, {("prepared-only", (b"input",)): b"cached"})
            token = history._SEMANTIC_MEMO.set(memo)
            patch = (mock.patch.object(history._Document, "ws", original_ws)
                     if kind == "ws" else contextlib.nullcontext())
            try:
                armed[0] = kind == "module"
                with patch:
                    check(history._semantic_binding(root) != binding, "binding observes " + kind)
                    try:
                        history._read_proof(root)
                    except ValueError as error:
                        check(error.args == ("ORDER-470: semantic scope root/config/module identity changed",),
                              "exact early rejection " + kind)
                    else:
                        check(False, "early rejection " + kind)
                check(not memo[1] and git.call_count == 0, "failure clears memo before any Git " + kind)
            finally:
                history._SEMANTIC_MEMO.reset(token)
            check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
                  "prepared binding case restores original scope identities " + kind)
    reads, captured = [0], []
    def changed_entry(path):
        raw = real_disk(path)
        if Path(path).resolve() == module:
            reads[0] += 1
            if reads[0] == 2:
                memo = history._SEMANTIC_MEMO.get()
                captured.append(memo)
                memo[1][("prepared-entry-only", (b"input",))] = b"cached"
                return raw + b"\n"
        return raw
    active_token = history._ACTIVE.set(None)
    memo_token = history._SEMANTIC_MEMO.set(None)
    try:
        with contextlib.ExitStack() as stack:
            git = stack.enter_context(mock.patch.object(history, "_git", side_effect=AssertionError("unexpected live proof")))
            stack.enter_context(mock.patch.object(history, "_disk_bytes", changed_entry))
            try:
                with history.fresh_validation_proof(root):
                    check(False, "changed entry must not yield a proof")
            except ValueError as error:
                check(error.args == ("ORDER-470: semantic scope root/config/module identity changed",),
                      "fresh context rejects before live entry")
            else:
                check(False, "changed entry must raise")
            check(len(captured) == 1 and not captured[0][1] and git.call_count == 0,
                  "pre-admission failure clears memo without Git")
            check(history._ACTIVE.get() is None and history._SEMANTIC_MEMO.get() is None,
                  "real context finally resets failed pre-admission scope")
    finally:
        history._SEMANTIC_MEMO.reset(memo_token)
        history._ACTIVE.reset(active_token)
    check(history._ACTIVE.get() is active_before and history._SEMANTIC_MEMO.get() is memo_before,
          "pre-admission unit restores caller scope identities")
    return failures, cases


def whitespace_main():
    failures, cases = run_whitespace_checks()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"ORDER483_WHITESPACE_{'FAIL' if failures else 'OK'} cases={cases}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(whitespace_main() if sys.argv[1:] == ["--whitespace-only"] else main())
