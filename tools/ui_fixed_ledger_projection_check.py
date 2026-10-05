#!/usr/bin/env python3
"""Bounded ORDER-454 equivalence; no collector or historical admission replay.

Two immutable Git blob pairs are pure inverse samples, not fresh admission.
Small malformed fixtures and the reused history doubles are synthetic evidence.
The separate normal365 invocation owns actual current repository admission.
"""
from __future__ import annotations

import ast
import copy
import hashlib
import json
from pathlib import Path
import sys
import traceback
from unittest import mock

sys.dont_write_bytecode = True
import ui_translation_append as append
from ui_comparison_memo_self_test import synthetic_history, uncached_factory

ROOT = Path(__file__).resolve().parents[1]
REFERENCE_COMMIT = "d6d7fc54f03382539e893d4ece33c0d4e47951ed"
REFERENCE_SHA = "6fd26f3d5e85570098602675dba25e8ab53d55efd7a947cdca1277bfc3ef5e2e"
NAMES = ("_correction_comparison", "_fee_comparison")
KINDS = ("correction", "fee")
DOCUMENT = append._Document
CONTEXT = append._ACTIVE_FIXED_LEDGER_PROJECTION
ERRORS = (ValueError, TypeError, KeyError, IndexError)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def raw(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode()


def configuration(kind):
    prefix = "CORRECTION" if kind == "correction" else "FEE"
    return (getattr(append, prefix + "_KEY"), getattr(append, prefix + "_TEXTS"),
            148 if kind == "correction" else 151)


def fixture(kind, metadata_change=False):
    """Minimal parser/comparison shape, deliberately not official receipts."""
    key, texts, index = configuration(kind)
    identifier = append.receipt_id(key)
    before = {p: raw({"prefix": "unchanged", key: texts[locale][0], "suffix": 1})
              for locale, p in zip(append.LOCALES, append.UI_PATHS)}
    accepted = {locale: {identifier: {"source_sha256": "a" * 64,
                                    "target_sha256": "b" * 64}}
                for locale in append.LOCALES}
    accepted["ja"] = {"protected": {"target_sha256": "c" * 64}}
    ledger = {"accepted": accepted, "accepted_sha256": append.exchange.digest(accepted),
              "batches": [{"slot": i, "label": "fixed"} for i in range(index)]}
    before[append.LEDGER_PATH] = raw(ledger)
    after = {p: raw({"prefix": "unchanged", key: texts[locale][1], "suffix": 1})
             for locale, p in zip(append.LOCALES, append.UI_PATHS)}
    ledger = copy.deepcopy(ledger)
    for locale in append.LOCALES:
        ledger["accepted"][locale][identifier]["target_sha256"] = "d" * 64
        if metadata_change:
            ledger["accepted"][locale][identifier]["source_sha256"] = "e" * 64
    ledger["accepted_sha256"] = append.exchange.digest(ledger["accepted"])
    ledger["batches"].append({"slot": index, "label": "correction"})
    after[append.LEDGER_PATH] = raw(ledger)
    return before, after


def suffix_append(snapshot):
    """Synthetic prefix append with changed dynamic spans and accepted checksum."""
    result = dict(snapshot)
    for path in append.UI_PATHS:
        value = json.loads(result[path])
        value["later synthetic key"] = "preserved later text"
        result[path] = raw(value)
    value = json.loads(result[append.LEDGER_PATH])
    for locale in append.LOCALES:
        value["accepted"][locale]["synthetic later receipt"] = {"target_sha256": "f" * 64}
    value["batches"].append({"slot": "later", "label": "append"})
    value["accepted_sha256"] = append.exchange.digest(value["accepted"])
    result[append.LEDGER_PATH] = raw(value)
    return result


def edit_ledger(snapshot, change, checksum=True):
    value = json.loads(snapshot[append.LEDGER_PATH])
    change(value)
    if checksum:
        value["accepted_sha256"] = append.exchange.digest(value["accepted"])
    return {**snapshot, append.LEDGER_PATH: raw(value)}


def token_edit(snapshot, path, field, replacement):
    doc = DOCUMENT(snapshot[path])
    start, end = doc.spans[field]
    return {**snapshot, path: (doc.text[:start] + replacement(doc.text[start:end]) + doc.text[end:]).encode()}


def outcome(function, snapshot, before, after):
    try:
        return "return", function(snapshot, before, after)
    except ERRORS as error:
        return "error", type(error).__name__, str(error)


def reference_functions():
    original = append._git(ROOT, "show", REFERENCE_COMMIT + ":tools/ui_translation_append.py")
    assert sha(original) == REFERENCE_SHA, "sealed453 append source mismatch"
    tree = ast.parse(original.decode())
    nodes = [node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in NAMES]
    assert [node.name for node in nodes] == list(NAMES)
    # Execute only these two sealed function definitions, never old module/main.
    env = dict(append.__dict__)
    exec(compile(ast.Module(body=nodes, type_ignores=[]), "<sealed453-comparisons>", "exec"), env)
    return {kind: env[name] for kind, name in zip(KINDS, NAMES)}


def check_all():
    cases, failures = 0, []

    def check(ok, label):
        nonlocal cases
        cases += 1
        print("UI_FIXED_LEDGER_PROJECTION_CASE " + ("PASS " if ok else "FAIL ") + label)
        if not ok:
            failures.append(label)

    def reject(call, label):
        try:
            call()
        except ERRORS:
            check(True, label)
        else:
            check(False, label)

    protected = ("tools/ui_translation_append.py", "tools/ui_fixed_ledger_projection_check.py",
                 "tools/ui_comparison_memo_self_test.py", "tools/ui_receipt_cost_profile.py",
                 "tools/ui_receipt_cost_profile_check.py", "tools/order350_source_compat.py",
                 "tools/order351_source_compat.py", "tools/audit_scope.json", *append.CURRENT_PATHS)
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    references = reference_functions()
    functions = {kind: getattr(append, name) for kind, name in zip(KINDS, NAMES)}
    check(CONTEXT.get() is None, "no projection context at entry")

    for kind in KINDS:
        function, reference = functions[kind], references[kind]
        before, after = fixture(kind)
        originals = (dict(before), dict(after))
        key, _, index = configuration(kind)
        identifier = append.receipt_id(key)
        bound = append._bind_fixed_ledger_comparison(function, before, after)
        for mode, sample in (("exact", after), ("later", suffix_append(after))):
            for count in (3, 4):
                snapshot = dict(sample)
                if count == 4:
                    snapshot[append.CURRENT_UI_PATHS[0]] = b'{"protected JA": "unchanged"}\n'
                expected = reference(snapshot, before, after)
                check(function(snapshot, before, after) == bound(snapshot, before, after) == expected,
                      f"synthetic {kind} {mode} {count}-path byte equivalence")
                if mode == "exact":
                    check(all(expected[p] == before[p] for p in before), f"synthetic {kind} exact inverse {count}")
                if count == 4:
                    check(expected[append.CURRENT_UI_PATHS[0]] == snapshot[append.CURRENT_UI_PATHS[0]],
                          f"synthetic {kind} protected JA retained {mode}")

        # Isolated faults: no claim about diagnostic precedence for compound faults.
        escaped = lambda token: token[:1] + "\\u%04x" % ord(token[1]) + token[2:]
        receipt_field = ("accepted", append.LOCALES[0], identifier, "target_sha256")
        mutants = {
            "UI rollback": {**after, append.UI_PATHS[0]: before[append.UI_PATHS[0]]},
            "UI same-value escape": token_edit(after, append.UI_PATHS[0], (key,), escaped),
            "receipt same-value escape": token_edit(after, append.LEDGER_PATH, receipt_field, escaped),
            "checksum": edit_ledger(after, lambda v: v.__setitem__("accepted_sha256", "0" * 64), False),
            "receipt absent": edit_ledger(after, lambda v: v["accepted"][append.LOCALES[0]].pop(identifier)),
            "receipt source": edit_ledger(after, lambda v: v["accepted"][append.LOCALES[0]][identifier].__setitem__("source_sha256", "0" * 64)),
            "receipt order": edit_ledger(after, lambda v: v["accepted"][append.LOCALES[0]].__setitem__(identifier, dict(reversed(list(v["accepted"][append.LOCALES[0]][identifier].items()))))),
            "batch absent": edit_ledger(after, lambda v: v["batches"].pop()),
            "batch value": edit_ledger(after, lambda v: v["batches"][index].__setitem__("label", "changed")),
            "batch key order": edit_ledger(after, lambda v: v["batches"].__setitem__(index, dict(reversed(list(v["batches"][index].items()))))),
            "path absent": {p: v for p, v in after.items() if p != append.UI_PATHS[0]},
            "duplicate JSON key": {**after, append.UI_PATHS[0]: b'{"duplicate":1,"duplicate":2}'},
            "nonfinite JSON": {**after, append.UI_PATHS[0]: b'{"invalid":NaN}'},
            "trailing JSON": {**after, append.LEDGER_PATH: after[append.LEDGER_PATH] + b'{}'},
        }
        doc = DOCUMENT(after[append.LEDGER_PATH])
        at = doc.spans[("batches", index - 1)][1]
        mutants["batch delimiter whitespace"] = {**after, append.LEDGER_PATH: (doc.text[:at] + " " + doc.text[at:]).encode()}
        for label, changed in mutants.items():
            expected = outcome(reference, changed, before, after)
            check(expected[0] == "error" and outcome(function, changed, before, after) == expected
                  and outcome(bound, changed, before, after) == expected, f"synthetic {kind} isolated reject {label}")
            check(bound(after, before, after) == before and CONTEXT.get() is None,
                  f"synthetic {kind} recovery after {label}")
        output = bound(after, before, after)
        output[append.LEDGER_PATH] = b"poison returned dict"
        check(bound(after, before, after) == before and (before, after) == originals,
              f"synthetic {kind} input/return independence")

        # An unrelated accepted row is outside this pure inverse's ownership.
        # A stale whole checksum rejects; recomputed checksum preserves the row.
        # This is NOT permission for such a change in repository admission.
        for recompute in (False, True):
            changed = edit_ledger(after, lambda v: v["accepted"]["ja"]["protected"].__setitem__(
                "target_sha256", "9" * 64), checksum=recompute)
            expected = outcome(reference, changed, before, after)
            cold_boundary = append._bind_fixed_ledger_comparison(function, before, after)
            check(expected[0] == ("return" if recompute else "error")
                  and outcome(function, changed, before, after) == expected
                  and outcome(cold_boundary, changed, before, after) == expected
                  and outcome(bound, changed, before, after) == expected,
                  f"synthetic {kind} non-owned accepted row {'rechecksummed preservation' if recompute else 'stale checksum rejection'} cold/warm")
            if recompute:
                check(json.loads(expected[1][append.LEDGER_PATH])["accepted"]["ja"]["protected"]["target_sha256"] == "9" * 64,
                      f"synthetic {kind} unrelated accepted value retained, not admission")

        # This deliberately non-official pair exposes the two checksum algorithms.
        a, b = fixture(kind, metadata_change=True)
        result = append._bind_fixed_ledger_comparison(function, a, b)(b, a, b)
        expected = reference(b, a, b)
        value = json.loads(result[append.LEDGER_PATH])
        checksum_value = copy.deepcopy(value["accepted"])
        if kind == "fee":
            for locale in append.LOCALES:
                checksum_value[locale][identifier] = json.loads(a[append.LEDGER_PATH])["accepted"][locale][identifier]
        check(result == expected and value["accepted_sha256"] == append.exchange.digest(checksum_value),
              f"synthetic {kind} target-only versus whole-receipt checksum semantics")

        projects = []
        actual_project = append._project_fixed_ledger
        def project(*args):
            projects.append(args[:2])
            return actual_project(*args)
        bad = mutants["checksum"]
        with mock.patch.object(append, "_project_fixed_ledger", project):
            cold = append._bind_fixed_ledger_comparison(function, before, after)
            for _ in range(2):
                reject(lambda: cold(bad, before, after), f"synthetic {kind} cold failure unpublished")
            check(len(projects) == 2 and CONTEXT.get() is None, f"synthetic {kind} failure rebuilds projection")
            check(cold(after, before, after) == cold(after, before, after) == before and len(projects) == 3,
                  f"synthetic {kind} success publishes projection only")
            fresh = append._bind_fixed_ledger_comparison(function, before, after)
            check(fresh(after, before, after) == before and len(projects) == 4,
                  f"synthetic {kind} new binding has no inherited projection")
        retained = dict(zip(cold.__code__.co_freevars, (cell.cell_contents for cell in cold.__closure__)))
        check(isinstance(retained.get("saved"), append._FixedLedgerProjection)
              and all(callable(value) or isinstance(value, (str, bytes, tuple, type(None)))
                      for value in retained.values()), f"{kind} actual bound closure retains no mutable mapping/Document")

        fixed = actual_project(kind, append.LEDGER_PATH, before[append.LEDGER_PATH], after[append.LEDGER_PATH])
        def immutable(value):
            return isinstance(value, (str, bytes, int, type(None))) or (isinstance(value, tuple) and all(immutable(x) for x in value))
        check(immutable(fixed) and not any(hasattr(fixed, attr) for attr in ("value", "text", "spans", "keys")),
              f"{kind} retained projection is tuples/scalars only, no parsed Document graph")
        check(immutable(retained["saved"]), f"{kind} actual saved closure projection recursively immutable")
        try:
            fixed.kind = "poison"
        except AttributeError:
            check(True, f"{kind} projection immutable")
        else:
            check(False, f"{kind} projection immutable")
        reject(lambda: actual_project("other", append.LEDGER_PATH, before[append.LEDGER_PATH], after[append.LEDGER_PATH]), f"{kind} invalid projection kind")
        reject(lambda: actual_project(kind, "other.json", before[append.LEDGER_PATH], after[append.LEDGER_PATH]), f"{kind} invalid projection path")
        for side in (0, 1):
            pair = [dict(before), dict(after)]
            pair[side][append.LEDGER_PATH] += b" "
            reject(lambda: bound(after, *pair), f"{kind} bound side{side} same-value raw drift")
        reject(lambda: bound(after, after, before), f"{kind} swapped fixed raw rejected")
        reject(lambda: bound(after, {**before, "extra": b"{}"}, after), f"{kind} bound path set rejects extra")
        for changed in (fixed._replace(kind="fee" if kind == "correction" else "correction"),
                        fixed._replace(path="other"), fixed._replace(before_raw=fixed.before_raw + b" "),
                        fixed._replace(after_raw=fixed.after_raw + b" ")):
            token = CONTEXT.set(changed)
            try:
                reject(lambda: function(after, before, after), f"{kind} direct context identity mismatch")
            finally:
                CONTEXT.reset(token)

    # Nested real comparisons and exceptional cleanup, not fake return-cache calls.
    pairs = {kind: fixture(kind) for kind in KINDS}
    nested = {kind: append._bind_fixed_ledger_comparison(functions[kind], *pairs[kind]) for kind in KINDS}
    entered, restored = [], []
    sentinel = RuntimeError("synthetic nested interruption")
    for fail in (False, True):
        fired = [False]
        def document(value):
            outer = CONTEXT.get()
            if outer is not None and outer.kind == "correction" and not fired[0]:
                fired[0] = True
                a, b = pairs["fee"]
                entered.append(nested["fee"](b, a, b) == a)
                restored.append(CONTEXT.get() is outer)
                if fail:
                    raise sentinel
            return DOCUMENT(value)
        a, b = pairs["correction"]
        with mock.patch.object(append, "_Document", document):
            try:
                result = nested["correction"](b, a, b)
            except RuntimeError as error:
                check(fail and error is sentinel, "nested same exception identity")
            else:
                check(not fail and result == a, "nested result equivalence")
        check(fired[0] and CONTEXT.get() is None, "nested finally restores outer/default contexts")
    check(all(entered) and all(restored) and len(entered) == 2, "nested projection scopes restore correctly")
    fake = lambda value, before, after: value
    check(append._bind_fixed_ledger_comparison(fake, {}, {}) is fake, "unrelated/fake inverse identity preserved")

    # Actual pinned blobs: one bounded objects read, no full history/proof/collector.
    requests, locations = [], []
    for kind, prefix in (("correction", "CORRECTION"), ("fee", "FEE")):
        commits = (getattr(append, prefix + "_BEFORE_COMMIT"), getattr(append, prefix + "_AFTER_COMMIT"))
        blobs, hashes = getattr(append, prefix + "_BLOBS"), getattr(append, prefix + "_HASHES")
        for side, commit in enumerate(commits):
            for path in append.PATHS:
                requests.append((commit + ":" + path, blobs[path][side], "blob"))
                locations.append((kind, side, path, hashes[path][side]))
    snapshots = {(kind, side): {} for kind in KINDS for side in (0, 1)}
    blobs = append._objects(ROOT, requests)
    check(len(blobs) == len(requests) == 12, "actual two immutable three-path pairs, twelve blob requests")
    for value, (kind, side, path, expected) in zip(blobs, locations):
        check(sha(value) == expected, f"actual immutable blob SHA {kind}/{side}/{path}")
        snapshots[kind, side][path] = value
    for kind in KINDS:
        a, b = snapshots[kind, 0], snapshots[kind, 1]
        reference, function = references[kind], functions[kind]
        check(reference(b, a, b) == a, f"actual sealed453 exact inverse {kind}")
        stages, rows = ["direct"], []
        def count_document(value):
            rows.append((stages[-1], "ledger" if value in (a[append.LEDGER_PATH], b[append.LEDGER_PATH]) else "ui"))
            return DOCUMENT(value)
        project_function = append._project_fixed_ledger
        def project(*args):
            stages.append("fixed preparation")
            try:
                return project_function(*args)
            finally:
                stages.pop()
        with mock.patch.object(append, "_Document", count_document), mock.patch.object(append, "_project_fixed_ledger", project):
            check(function(b, a, b) == a, f"actual direct old API equivalent {kind}")
            bound = append._bind_fixed_ledger_comparison(function, a, b)
            stages[0] = "cold"
            check(bound(b, a, b) == a, f"actual bound cold equivalent {kind}")
            stages[0] = "warm"
            check(bound(dict(b), a, b) == a, f"actual bound warm equivalent {kind}")
            check(bound(dict(b), a, b) == a, f"actual bound second warm equivalent {kind}")
        expected_counts = {("direct", "ledger"): 2, ("direct", "ui"): 4,
                           ("fixed preparation", "ledger"): 2, ("cold", "ledger"): 1,
                           ("cold", "ui"): 4, ("warm", "ledger"): 2, ("warm", "ui"): 8}
        check({row: rows.count(row) for row in set(rows)} == expected_counts,
              f"actual {kind} direct ledger2; cold fixed2+dynamic1; two warm dynamic2; UI12 unchanged")
        print(f"UI_FIXED_LEDGER_PROJECTION_PARSES kind={kind} direct_control_total=6 bound_calls=3 bound_ledger=5 bound_ui=12 bound_total=17 direct_ledger_per_call=2 derived_uncached_ledger_three_calls=6 exact_after_extra_dynamic_per_call=1")

    # Reuse only the two old pure helpers. Their obsolete whole-file seal is NOT run.
    old = synthetic_history(uncached_factory)
    new = synthetic_history(append._comparison_memo)
    check(old[:2] == new[:2] and new[0][0] == "return", "synthetic history complete outcome/external trace equivalence")
    check(len(old[2]) == 9 and len(new[2]) == 6, "synthetic inverse epoch/memo calls remain9to6")
    for label, count in (("split_step", 5), ("split_finish", 1), ("source_matches", 5), ("source_manifest", 1), ("proof", 3)):
        check(sum(row[0] == label for row in new[1]) == count, "synthetic fresh trace " + label)
    for fault in ("git", "objects", "raw", "proof", "source", "manifest", "split", "head"):
        a, b = synthetic_history(uncached_factory, fault), synthetic_history(append._comparison_memo, fault)
        check(a[:2] == b[:2] and b[0][0] == "error", "synthetic fresh rejection trace " + fault)
        check(synthetic_history(append._comparison_memo) == new, "synthetic fresh recovery " + fault)
    check(CONTEXT.get() is None, "no transient projection leaked at exit")
    check(all(sha((ROOT / p).read_bytes()) == expected for p, expected in unchanged.items()), "source/parser/oldtests/UI/ledger inputs unchanged")
    print("UI_FIXED_LEDGER_PROJECTION_SCOPE sealed_reference_functions=2 immutable_blob_pairs=2 synthetic_history_only=true actual_admission_runs=0 historical_cases=0")
    return failures, cases


def main():
    try:
        failures, cases = check_all()
    except Exception:
        traceback.print_exc(file=sys.stdout)
        print("UI_FIXED_LEDGER_PROJECTION_FAIL unexpected_error historical_cases=0")
        return 1
    for failure in failures:
        print("UI_FIXED_LEDGER_PROJECTION_ERROR " + failure)
    print(f"UI_FIXED_LEDGER_PROJECTION_{'FAIL' if failures else 'OK'} cases={cases} historical_cases=0")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
