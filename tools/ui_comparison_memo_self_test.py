#!/usr/bin/env python3
"""Bounded invocation-local inverse reuse checks, not historical acceptance.

Slot tests and public-history orchestration use explicitly synthetic doubles.
Three immutable Git blob pairs separately exercise the real pure inverses.
Actual current Git/source admission and timings belong to the fresh CLI A/B.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import sys
import traceback
from unittest import mock

sys.dont_write_bytecode = True
import ui_translation_append as append

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = "4938b3322e22a04249ed0e4b3c4e77939e8c0903"
BASE_SHA = "2731c630a25af19474a45b8ab7d86250ec27759be91bde3ff897bb7a933a940c"
OLD_TEST_SHA = "f4d54b0ec63efaa17487af6ae1b3be0dd602646aee4c4ba66fa6f4b5aac68cc2"
OLD_LOOP = (
    b"    def comparison(snapshot):\n"
    b"        for function, before, after in reversed(corrections):\n"
    b"            snapshot = function(snapshot, before, after)\n"
    b"        return snapshot\n"
)
NEW_LINK = b"    comparison = _comparison_memo(paths, corrections)\n"


def uncached_factory(paths, corrections):
    """Exactly the previous loop; used only as this test's comparison oracle."""
    def comparison(snapshot):
        for function, before, after in reversed(corrections):
            snapshot = function(snapshot, before, after)
        return snapshot
    return comparison


def synthetic_history(factory, fault=None):
    """Execute the actual current history body with numeric-byte test doubles.

    Six states: baseline -> append -> correction -> fee -> legacy -> append.
    No synthetic Git/proof result is evidence about the real repository.
    """
    paths = append.CURRENT_PATHS
    baseline, first, head = "b" * 40, "a" * 40, "f" * 40
    commits = [first, append.CORRECTION_AFTER_COMMIT, append.FEE_AFTER_COMMIT,
               append.LEGACY_GIFT_AFTER_COMMIT, head]
    lineage = list(reversed(commits)) + [baseline]
    states = {baseline: {p: b"10" for p in paths}}
    changed_paths = [paths, append.PATHS, append.PATHS,
                     (append.LEGACY_GIFT_PATH, append.LEDGER_PATH), paths]
    parents = dict(zip(commits, [baseline, *commits[:-1]]))
    for commit, changed in zip(commits, changed_paths):
        previous = states[parents[commit]]
        states[commit] = {p: str(int(value) + int(p in changed)).encode()
                          for p, value in previous.items()}
    revision, manifest = "c" * 40, "d" * 64
    trace, inverse_trace = [], []
    head_reads = 0
    source_reads = 0

    def snapshot(where, commit, selected=append.PATHS):
        trace.append(("snapshot", commit, tuple(selected)))
        result = {p: states[commit][p] for p in selected}
        if fault == "raw" and commit == head:
            result[paths[0]] += b" "
        return result

    def git(where, *args, **kwargs):
        nonlocal head_reads
        trace.append(("git", args, kwargs.get("input")))
        if fault == "git":
            raise OSError("synthetic Git unavailable")
        if args == ("rev-parse", "--verify", "HEAD^{commit}"):
            head_reads += 1
            value = "e" * 40 if fault == "head" and head_reads == 2 else head
            return (value + "\n").encode()
        if args == ("rev-list", "--first-parent", head):
            return ("\n".join(lineage) + "\n").encode()
        if args[:1] == ("log",):
            return ("\n".join(commits) + "\n").encode()
        if args[:2] == ("merge-base", "--is-ancestor"):
            return b""
        raise AssertionError("unmodelled synthetic Git call: " + repr(args))

    def objects(where, requests):
        trace.append(("objects", tuple(requests)))
        if fault == "objects":
            raise ValueError("synthetic immutable object failure")
        return [("tree " + "0" * 40 + "\nparent " + parents[commit] +
                 "\n\nsynthetic commit\n").encode() for commit, _, _ in requests]

    def change(delta=0, correction=False, first_receipts=0):
        return {"ui_by_locale": {"ja": delta, "zh-CN": 0, "zh-TW": 0},
                "receipts": delta, "batches": delta, "source_manifests": {revision: manifest},
                "corrections": 2 if correction else 0,
                "correction_batches": int(correction), "first_receipts": first_receipts}

    def proof(commit, selected, extra=0):
        def run(where, inventory):
            trace.append(("proof", commit))
            if fault == "proof" and commit == append.FEE_AFTER_COMMIT:
                raise ValueError("synthetic correction proof failure")
            return ({p: states[parents[commit]][p] for p in selected},
                    {p: states[commit][p] for p in selected}, change(correction=True, first_receipts=extra))
        return run

    def inverse(label, selected):
        def run(value, before, after):
            inverse_trace.append((label, tuple((p, value[p]) for p in paths)))
            return {p: str(int(raw) - int(p in selected)).encode() for p, raw in value.items()}
        return run

    def validate(before, after, inventory):
        trace.append(("validate_append", tuple(before.items()), tuple(after.items())))
        old, new = set(map(int, before.values())), set(map(int, after.values()))
        append.require(len(old) == len(new) == 1, "synthetic inverse did not restore equal components")
        delta = next(iter(new)) - next(iter(old))
        append.require(delta in (1, 2), "synthetic append delta")
        return change(delta)

    def source_matches(where, inventory, expected):
        nonlocal source_reads
        source_reads += 1
        trace.append(("source_matches", expected))
        return expected == manifest and not (fault == "source" and source_reads == len(commits))

    def source_manifest(where, source):
        trace.append(("source_manifest", source))
        return "0" * 64 if fault == "manifest" else manifest

    class SplitDouble:
        def __init__(self, where, inventory):
            trace.append(("split_init",))

        def step(self, commit, before, after):
            trace.append(("split_step", commit, tuple(before.items()), tuple(after.items())))
            return None

        def finish(self):
            trace.append(("split_finish",))
            if fault == "split":
                raise ValueError("synthetic unresolved split")

    def factory_spy(selected, corrections):
        trace.append(("factory", tuple(selected)))
        return factory(selected, corrections)

    patches = {
        "_comparison_memo": factory_spy, "_git": git, "_objects": objects, "_snapshot": snapshot,
        "_SplitReceiptHistory": SplitDouble, "validate_append": validate,
        "_source_manifest_matches": source_matches, "_source_manifest": source_manifest,
        "_correction_proof": proof(commits[1], append.PATHS),
        "_fee_correction_proof": proof(commits[2], append.PATHS),
        "_legacy_ja_gift_proof": proof(commits[3], paths, 2),
        "_correction_comparison": inverse("correction", append.PATHS),
        "_fee_comparison": inverse("fee", append.PATHS),
        "_legacy_ja_gift_comparison": inverse("legacy", changed_paths[3]),
    }
    with mock.patch.multiple(append, **patches):
        try:
            result = append.validate_history(ROOT, baseline, states[baseline], states[head], {})
            outcome = ("return", result)
        except (ValueError, OSError) as error:
            outcome = ("error", type(error).__name__, str(error))
    return outcome, trace, inverse_trace


def comparison_memo_self_test():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        print("UI_COMPARISON_MEMO_CASE " + ("PASS " if ok else "FAIL ") + label)
        if not ok:
            failures.append(label)

    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, TypeError, KeyError) as error:
            check(message is None or message in str(error), label)
        else:
            check(False, label)

    sha = lambda raw: hashlib.sha256(raw).hexdigest()
    protected = ("tools/ui_translation_append.py", "tools/ui_translation_append_self_test.py",
                 "tools/ui_comparison_memo_self_test.py", "tools/main_game_locale_history.py",
                 "tools/ja_translation_pipeline.py", "tools/audit_scope.json", *append.CURRENT_PATHS)
    observed = {path: sha((ROOT / path).read_bytes()) for path in protected}
    original = append._git(ROOT, "show", DECLARATION + ":tools/ui_translation_append.py")
    check(sha(original) == BASE_SHA and original.count(OLD_LOOP) == 1, "independent declared original module")
    old_description = b"No private receipts, mutable success cache, or historical consumer are used."
    new_description = b"No private receipts, cached validation verdicts, or historical consumer are used."
    expected = original.replace(OLD_LOOP, NEW_LINK, 1).replace(old_description, new_description, 1)
    current = (ROOT / "tools/ui_translation_append.py").read_bytes()
    begin, end = b"# BEGIN_LOCAL_COMPARISON_MEMO", b"# END_LOCAL_COMPARISON_MEMO"
    check(original.count(old_description) == 1 and current.splitlines().count(begin) ==
          current.splitlines().count(end) == 1, "one exact helper and description boundary")
    prefix, helper = current.split(begin + b"\n", 1)
    check(prefix == expected + b"\n" and helper.endswith(end + b"\n"),
          "all original bytes preserved outside the two declared replacements and EOF helper")
    check(sha((ROOT / "tools/ui_translation_append_self_test.py").read_bytes()) == OLD_TEST_SHA,
          "entire original self-test unchanged; no historical suite executed")

    factory = append._comparison_memo
    for paths in (append.PATHS, append.CURRENT_PATHS):
        source = {path: b"0" for path in paths}
        corrections, calls = [], []

        def tagged(label):
            def inverse(value, before, after):
                calls.append(label)
                return {path: raw + label.encode() for path, raw in value.items()}
            return inverse

        memo = factory(paths, corrections)
        output = memo(source)
        check(output == source and output is not source, "zero-epoch input copy " + str(len(paths)))
        output[paths[0]] = b"poison"
        source[paths[0]] = b"mutated caller"
        plain = {path: b"0" for path in paths}
        check(memo(plain) == plain, "zero-epoch stored and returned copies " + str(len(paths)))
        for epoch, label in enumerate(("A", "B", "C"), 1):
            corrections.append((tagged(label), {}, {}))
            prior_calls = len(calls)
            expected_view = {path: b"0" + b"CBA"[3 - epoch:] for path in paths}
            check(memo(plain) == expected_view and len(calls) == prior_calls + epoch,
                  "epoch miss and reverse order " + str(len(paths)) + ":" + str(epoch))
            result = memo(dict(reversed(list(plain.items()))))
            check(result == expected_view and len(calls) == prior_calls + epoch,
                  "same bytes distinct/reordered dict hit " + str(len(paths)) + ":" + str(epoch))
            result[paths[0]] = b"poison"
            check(memo(plain) == expected_view, "nonzero-epoch return isolation " + str(epoch))
        for path in paths:
            old_calls = len(calls)
            changed = {**plain, path: plain[path] + b" "}
            check(memo(changed)[path] == b"0 CBA" and len(calls) == old_calls + 3,
                  "raw one-byte miss " + path + ":" + str(len(paths)))
            check(memo(plain) == expected_view and len(calls) == old_calls + 6,
                  "one-slot eviction " + path + ":" + str(len(paths)))
            reject(lambda p=path: memo({k: v for k, v in plain.items() if k != p}),
                   "missing path rejects after warm " + path)
        reject(lambda: memo({**plain, "unexpected.json": b"0"}), "extra path rejects after warm")
        for invalid in (bytearray(b"0"), memoryview(b"0"), "0", None):
            reject(lambda value=invalid: memo({**plain, paths[0]: value}), "non-bytes rejected " + type(invalid).__name__)
        reject(lambda: factory((*paths, paths[0]), []), "duplicate configured path rejected")
        before_calls = len(calls)
        check(factory(paths, corrections)(plain) == expected_view and len(calls) == before_calls + 3,
              "fresh factory cannot borrow another invocation slot " + str(len(paths)))

    # Even a deliberately mutating synthetic inverse cannot alias the caller or cache.
    path = append.PATHS[0]
    source = {p: b"0" for p in append.PATHS}
    retained = []
    def mutating(value, before, after):
        value[path] = b"1"
        retained.append(value)
        return value
    memo = factory(append.PATHS, [(mutating, {}, {})])
    output = memo(source)
    retained[0][path] = b"retained inverse alias"
    output[path] = b"returned alias"
    check(source[path] == b"0" and memo(source)[path] == b"1", "input/store/return isolate an inverse-owned dict")

    attempt, failing = [], [True]
    sentinel = ValueError("synthetic inverse failure")
    def fail_once(value, before, after):
        attempt.append(tuple(value.items()))
        if value[path] == b"bad" and failing[0]:
            raise sentinel
        return dict(value)
    memo = factory(append.PATHS, [(fail_once, {}, {})])
    memo(source)
    bad = {**source, path: b"bad"}
    for number in (1, 2):
        try:
            memo(bad)
        except ValueError as error:
            check(error is sentinel and len(attempt) == number + 1, "same exception; failed result not cached " + str(number))
        else:
            check(False, "failed inverse must propagate " + str(number))
    check(memo(source) == source and len(attempt) == 3, "failure cannot replace last successful slot")
    failing[0] = False
    check(memo(bad) == bad and len(attempt) == 4 and memo(bad) == bad and len(attempt) == 4,
          "failed input freshly recovers then becomes reusable")

    # Exercise the real current history loop; every surrounding dependency below
    # is synthetic, including the numeric bytes, Git objects and source proofs.
    old = synthetic_history(uncached_factory)
    new = synthetic_history(factory)
    check(old[:2] == new[:2] and old[0][0] == "return", "synthetic public complete result and external trace equivalence")
    result = new[0][1]
    check({key: result[key] for key in ("receipts", "batches", "append_receipts", "append_batches", "corrections",
                                      "correction_batches", "first_receipts")} ==
          {"receipts": 4, "batches": 5, "append_receipts": 2, "append_batches": 2,
           "corrections": 6, "correction_batches": 3, "first_receipts": 2}, "synthetic correction/append census preserved")
    check(len(old[2]) == 9 and len(new[2]) == 6, "synthetic final candidate hit reduces only pure inverse calls 9 to 6")
    check(sum(row[0] == "split_step" for row in new[1]) == 5 and
          sum(row[0] == "split_finish" for row in new[1]) == 1 and
          sum(row[0] == "source_matches" for row in new[1]) == 5 and
          sum(row[0] == "source_manifest" for row in new[1]) == 1 and
          sum(row[0] == "proof" for row in new[1]) == 3,
          "synthetic split/current-source/immutable-proof calls are not skipped")
    for fault in ("git", "objects", "raw", "proof", "source", "manifest", "split", "head"):
        a, b = synthetic_history(uncached_factory, fault), synthetic_history(factory, fault)
        check(a[:2] == b[:2] and b[0][0] == "error", "warm then fresh public failure and trace " + fault)
        check(synthetic_history(factory) == new, "fresh public recovery with no inherited slot " + fault)

    # One bounded batch of immutable historical blobs, NOT historical consumers,
    # correction admission, source collection or the current full Git history.
    fixtures = (
        ("correction", append._correction_comparison, append.CORRECTION_BEFORE_COMMIT,
         append.CORRECTION_AFTER_COMMIT, append.CORRECTION_BLOBS, append.CORRECTION_HASHES, append.CORRECTION_KEY),
        ("fee", append._fee_comparison, append.FEE_BEFORE_COMMIT, append.FEE_AFTER_COMMIT,
         append.FEE_BLOBS, append.FEE_HASHES, append.FEE_KEY),
        ("legacy", append._legacy_ja_gift_comparison, append.LEGACY_GIFT_BEFORE_COMMIT,
         append.LEGACY_GIFT_AFTER_COMMIT, append.LEGACY_GIFT_BLOBS, append.LEGACY_GIFT_HASHES, append.LEGACY_GIFT_KEYS[0]),
    )
    requests, locations = [], []
    for label, inverse, before, after, blobs, hashes, key in fixtures:
        for side, commit in enumerate((before, after)):
            for p in blobs:
                requests.append((commit + ":" + p, blobs[p][side], "blob"))
                locations.append((label, side, p, hashes[p][side]))
    raw_blobs = append._objects(ROOT, requests)
    snapshots = {(label, side): {} for label, *_ in fixtures for side in (0, 1)}
    check(len(raw_blobs) == len(requests) == 20, "three immutable before/after samples; exact twenty blobs")
    for raw, (label, side, p, expected_hash) in zip(raw_blobs, locations):
        check(sha(raw) == expected_hash, "actual immutable blob hash " + label + ":" + str(side) + ":" + p)
        snapshots[label, side][p] = raw
    for label, inverse, *_rest, key in fixtures:
        before, after = snapshots[label, 0], snapshots[label, 1]
        originals = (dict(before), dict(after))
        corrections = [(inverse, before, after)]
        reference = uncached_factory(tuple(after), corrections)(after)
        with mock.patch.object(append, "_Document", wraps=append._Document) as document:
            memo = factory(tuple(after), corrections)
            check(memo(after) == reference == before, "real pure inverse byte equivalence " + label)
            parses = document.call_count
            check(parses > 0 and memo(dict(after)) == before and document.call_count == parses,
                  "real repeated sample avoids parsing only " + label)
        target = append.LEGACY_GIFT_PATH if label == "legacy" else append.UI_PATHS[0]
        doc = append._Document(after[target])
        start, end = doc.spans[(key,)]
        token = doc.text[start:end]
        escaped = token[:1] + "\\u%04x" % ord(token[1]) + token[2:]
        changed = {**after, target: (doc.text[:start] + escaped + doc.text[end:]).encode()}
        reject(lambda: memo(changed), "warm real inverse rejects same-value raw escape " + label)
        check(memo(after) == before and (before, after) == originals, "real inverse inputs and success survive failure " + label)

    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()),
          "all observed source, tools, dictionaries and receipt bytes unchanged")
    print("UI_COMPARISON_MEMO_SCOPE synthetic_public_history=true immutable_inverse_samples=3 current_history_runs=0")
    return failures, cases


def main():
    try:
        failures, cases = comparison_memo_self_test()
    except Exception:
        traceback.print_exc()
        print("UI_COMPARISON_MEMO_FAIL unexpected_error historical_cases=0")
        return 1
    for failure in failures:
        print("UI_COMPARISON_MEMO_ERROR " + failure)
    print(f"UI_COMPARISON_MEMO_{'FAIL' if failures else 'OK'} cases={cases} historical_cases=0")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
