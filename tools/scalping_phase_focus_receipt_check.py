#!/usr/bin/env python3
"""Bounded Scalp bridge checks: one real Git transition, explicit synthetic faults.

Does not replay old focused suites, generate receipts, run Godot, or write files.
Synthetic Main variants exercise the new seam, not historical quality claims.
"""
from __future__ import annotations

import copy
import hashlib
import sys
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
PATH = bridge.SCALPING_PHASE_PATH
CASES: list[str] = []


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def rejects(name, operation, message):
    try:
        operation()
    except ValueError as error:
        if message not in str(error):
            raise AssertionError(f"{name}: unexpected rejection {error}") from error
    else:
        raise AssertionError(name + ": unexpectedly admitted")
    CASES.append(name)


def inventory(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def main():
    commits = (bridge.SCALPING_PHASE_BEFORE_COMMIT, bridge.SCALPING_PHASE_AFTER_COMMIT)
    requests = [(commit, commit, "commit") for commit in commits]
    requests += [(tree, tree, "tree") for tree in bridge.SCALPING_PHASE_TREES]
    requests += [(commit + ":" + PATH, blob, "blob")
                 for commit, blob in zip(commits, bridge.SCALPING_PHASE_BLOBS)]
    values = bridge._objects(ROOT, requests)
    before, after = values[4:]
    check("real fixed Git blob SHA", tuple(hashlib.sha256(v).hexdigest() for v in (before, after)) == bridge.SCALPING_PHASE_HASHES)
    check("real current bytes", (ROOT / PATH).read_bytes() == after)
    check("real six-object/direct-parent/path/HEAD admission", bridge.scalping_phase_predecessor(ROOT, after) == before)
    check("pure exact inverse", bridge._scalping_phase_inverse(after) == before)
    rejects("mutable raw", lambda: bridge._scalping_phase_inverse(bytearray(after)), "immutable raw")
    rejects("old raw not successor", lambda: bridge.scalping_phase_predecessor(ROOT, before), "current runtime differs")
    rejects("extra edit outside inverse", lambda: bridge._scalping_phase_inverse(after + b"\n"), "outside exact")
    rejects("extra edit admission", lambda: bridge.scalping_phase_predecessor(ROOT, after + b"\n"), "current runtime differs")
    for index, (_, new) in enumerate(bridge.SCALPING_PHASE_REPLACEMENTS):
        chunk = new.encode()
        rejects(f"missing inverse chunk {index}", lambda c=chunk: bridge._scalping_phase_inverse(after.replace(c, b"", 1)), "not exact1")
        rejects(f"duplicate inverse chunk {index}", lambda c=chunk: bridge._scalping_phase_inverse(after + c), "not exact1")

    # Feed genuine object contents through the seam; each fault below is synthetic.
    def git_stub(root, *args):
        if args[0] == "diff":
            return b"M\0" + PATH.encode() + b"\0"
        if args[0] == "merge-base":
            return b""
        if args == ("rev-parse", "HEAD:" + PATH):
            return bridge.SCALPING_PHASE_BLOBS[1].encode() + b"\n"
        raise AssertionError("unexpected Git request: " + repr(args))

    with patch.object(bridge, "_git", side_effect=git_stub):
        for index in (0, 1):
            broken = list(values)
            broken[index] = broken[index].replace(bridge.SCALPING_PHASE_TREES[index].encode(), b"0" * 40, 1)
            with patch.object(bridge, "_objects", return_value=broken):
                rejects(f"synthetic commit tree {index}", lambda: bridge.scalping_phase_predecessor(ROOT, after), "tree mismatch")
        broken = list(values)
        broken[1] = broken[1].replace(b"parent " + commits[0].encode(), b"parent " + b"0" * 40, 1)
        with patch.object(bridge, "_objects", return_value=broken):
            rejects("synthetic direct parent", lambda: bridge.scalping_phase_predecessor(ROOT, after), "direct parent mismatch")
        for index in (4, 5):
            broken = list(values)
            broken[index] += b"\n"
            with patch.object(bridge, "_objects", return_value=broken):
                rejects(f"synthetic Git blob {index}", lambda: bridge.scalping_phase_predecessor(ROOT, after), "Git blobs/current raw mismatch")

    for command, output, message in (
        ("diff", b"M\0scenes/MainGame.gd\0", "exactly one modified file"),
        ("diff", b"M\0" + PATH.encode() + b"\0M\0extra\0", "exactly one modified file"),
        ("rev-parse", b"0" * 40, "actual Git candidate"),
        ("merge-base", None, "synthetic ancestry failure"),
    ):
        def fault_git(root, *args, target=command, result=output):
            if args[0] == target:
                if result is None:
                    raise ValueError("synthetic ancestry failure")
                return result
            return git_stub(root, *args)
        with patch.object(bridge, "_objects", return_value=values), patch.object(bridge, "_git", side_effect=fault_git):
            rejects("synthetic Git " + message + " " + repr(output), lambda: bridge.scalping_phase_predecessor(ROOT, after), message)

    actual = inventory({PATH: bridge.SCALPING_PHASE_HASHES[1], "scenes/MainGame.gd": "main-0", "other.gd": "fixed"})
    old = inventory({**actual["source_hashes"], PATH: bridge.SCALPING_PHASE_HASHES[0]})
    old_manifests = [bridge.exchange.digest({**old["source_hashes"], "scenes/MainGame.gd": f"main-{i}"}) for i in range(13)]
    phantom_manifests = [bridge.exchange.digest({**actual["source_hashes"], "scenes/MainGame.gd": f"main-{i}"}) for i in range(1, 13)]
    real_read = Path.read_bytes

    def read_stub(path):
        return after if path == ROOT / PATH else real_read(path)

    def predecessor_stub(root, raw):
        if root != ROOT or raw != after:
            raise AssertionError("incorrect predecessor seam input")
        return before

    def old_matcher(root, data, expected):
        if "source_hashes" not in data:
            return expected == "isolated-legacy-fixture"
        hashes = data["source_hashes"]
        return expected in {bridge.exchange.digest({**hashes, "scenes/MainGame.gd": f"main-{i}"}) for i in range(13)}

    with patch.object(Path, "read_bytes", read_stub), patch.object(bridge, "scalping_phase_predecessor", side_effect=predecessor_stub) as fresh, patch.object(bridge, "_SCALPING_PHASE_OLD_MANIFEST_MATCHES", side_effect=old_matcher):
        for index, digest in enumerate(old_manifests):
            check(f"synthetic old-Scalp manifest {index}", bridge._source_manifest_matches(ROOT, actual, digest))
        check("synthetic actual successor manifest", bridge._source_manifest_matches(ROOT, actual, actual["source_manifest_sha256"]))
        for index, digest in enumerate(phantom_manifests):
            check(f"reject synthetic phantom new-Scalp old-Main {index}", not bridge._source_manifest_matches(ROOT, actual, digest))
        check("fresh proof on every manifest admission", fresh.call_count == 26)
        changed = inventory({**actual["source_hashes"], "other.gd": "changed"})
        check("other source edit cannot use old manifest", not bridge._source_manifest_matches(ROOT, changed, old_manifests[0]))
        bad = {**actual, "source_manifest_sha256": "bad"}
        rejects("invalid current manifest checksum", lambda: bridge._source_manifest_matches(ROOT, bad, old_manifests[0]), "census/raw mismatch")
        rejects("old census pretending to be current", lambda: bridge._source_manifest_matches(ROOT, old, old_manifests[0]), "census/raw mismatch")
        check("legacy isolated fixture delegation", bridge._source_manifest_matches(ROOT, {}, "isolated-legacy-fixture"))

    head = "f" * 40
    result = {**actual, "evidence": {"head": head}, "kept": "actual current result"}

    def admission(value=None, reads=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=reads or [after, after]), patch.object(bridge, "_git", side_effect=heads or [head.encode(), head.encode()]), patch.object(bridge, "scalping_phase_predecessor", side_effect=predecessor_stub), patch.object(bridge, "_SCALPING_PHASE_OLD_CURRENT_PROOF", return_value=result if value is None else value):
            return bridge.current_proof(ROOT, "synthetic-baseline", {})

    check("current seam returns actual census unchanged", admission() is result)
    bad = copy.deepcopy(result)
    bad["source_hashes"][PATH] = bridge.SCALPING_PHASE_HASHES[0]
    bad["source_manifest_sha256"] = bridge.exchange.digest(bad["source_hashes"])
    rejects("returned predecessor census", lambda: admission(bad), "source changed during")
    rejects("returned invalid digest", lambda: admission({**result, "source_manifest_sha256": "bad"}), "source changed during")
    rejects("source changes during admission", lambda: admission(reads=[after, after + b"\n"]), "source changed during")
    rejects("outer HEAD changes", lambda: admission(heads=[head.encode(), b"0" * 40]), "Git candidate changed")
    rejects("inner HEAD differs", lambda: admission({**result, "evidence": {"head": "0" * 40}}), "Git candidate changed")
    with patch.object(Path, "read_bytes", read_stub), patch.object(bridge, "_git", return_value=head.encode()), patch.object(bridge, "scalping_phase_predecessor", side_effect=[before, ValueError("synthetic next-call proof failure")]) as fresh, patch.object(bridge, "_SCALPING_PHASE_OLD_CURRENT_PROOF", return_value=result):
        check("successful call before next fault", bridge.current_proof(ROOT, "synthetic-baseline", {}) is result)
        rejects("next call cannot reuse success", lambda: bridge.current_proof(ROOT, "synthetic-baseline", {}), "next-call proof failure")
        check("next call performed fresh proof", fresh.call_count == 2)
    check("no duplicate case names", len(CASES) == len(set(CASES)))
    print(f"SCALPING_PHASE_FOCUS_RECEIPT_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
