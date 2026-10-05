#!/usr/bin/env python3
"""Bounded single-matcher proof reuse; no collector or historical suite.

One real thirteen-stage proof supplies the immutable Git before-blob witness.
All remaining freshness/fault cases use explicit synthetic seams, not repeated
repository admission. The separate full-body command owns current50 admission.
"""
from __future__ import annotations

import ast
from contextlib import contextmanager, ExitStack
from copy import deepcopy
import hashlib
from operator import setitem
from pathlib import Path
import sys
import traceback
from unittest.mock import patch

sys.dont_write_bytecode = True
import holdem_money_history as history
import ui_translation_append as append

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = "840b9f0f83492df2d5c9d211deec26060ccb8fa5"
REFERENCE_HASHES = {
    "tools/holdem_money_history.py": "3a5d6a2f7457cf7b56271a3e33890da2b361f7cf2f6d7470e0f07e3705090ab1",
    "tools/ui_translation_append.py": "a64997852f3b93b7cde3067870e30755ca251afb93d73f034ed96c7528cddb3d",
}
STAGES = (
    ("", "holdem_money_predecessor"),
    ("CANVAS_", "holdem_canvas_predecessor"),
    ("BETTING_", "holdem_betting_predecessor"),
    ("ASYNC_", "holdem_async_predecessor"),
    ("CARD_COLOR_", "holdem_card_color_predecessor"),
    ("MESSAGE_PULSE_", "holdem_message_pulse_predecessor"),
    ("BANNER_", "holdem_banner_predecessor"),
    ("BANNER_LOCALE_", "holdem_banner_locale_predecessor"),
    ("TABLE_LABELS_", "holdem_table_labels_predecessor"),
    ("SEAT_HEIGHT_", "holdem_seat_height_predecessor"),
    ("FOLDED_LOCALE_", "holdem_folded_locale_predecessor"),
    ("HAND_NET_", "holdem_hand_net_predecessor"),
    ("VICTORY_PARTICLE_", "holdem_victory_particle_predecessor"),
)
CASES = []


def check(label, condition):
    if not condition:
        raise AssertionError(label)
    CASES.append(label)


def rejects(label, operation):
    try:
        operation()
    except (ValueError, OSError, TypeError, RuntimeError):
        CASES.append(label)
        return
    raise AssertionError(label + ": unexpectedly admitted")


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def nodes(raw, name):
    return [ast.dump(node, include_attributes=False)
            for node in ast.parse(raw).body
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name == name]


def source_preservation():
    for path, expected in REFERENCE_HASHES.items():
        old = history._git(ROOT, "show", REFERENCE + ":" + path)
        current = (ROOT / path).read_bytes()
        current_nodes = [ast.dump(n, include_attributes=False) for n in ast.parse(current).body]
        check("sealed pre461 source " + path, sha(old) == expected)
        if path.endswith("holdem_money_history.py"):
            names = {node.name for node in ast.parse(old).body
                     if isinstance(node, ast.FunctionDef)
                     and (node.name.endswith("_inverse") or node.name == "_holdem_exact_stage_chain")}
            for name in sorted(names):
                check("unchanged exact inverse/proof body " + name, nodes(old, name) == nodes(current, name))
            for node in ast.parse(old).body:
                if not isinstance(node, ast.Assign) or not any(
                    isinstance(target, ast.Name) and
                    (target.id == "HOLDEM_PATH" or target.id.endswith(("_COMMIT", "_TREES", "_BLOBS", "_HASHES", "_REPLACEMENT", "_REPLACEMENTS", "_APPENDIX"))
                     or target.id in {"TREES", "BLOBS", "HASHES", "FMT_REPLACEMENT"})
                    for target in node.targets):
                    continue
                serialized = ast.dump(node, include_attributes=False)
                check("unchanged pinned assignment " + ast.unparse(node.targets[0]),
                      serialized in current_nodes)
        else:
            for name in ("current_proof", "validate_history", "_comparison_memo"):
                check("unchanged append producer " + name, nodes(old, name) == nodes(current, name))
            original = nodes(old, "_source_manifest_matches")
            check("all previous matcher bodies retained",
                  nodes(current, "_source_manifest_matches")[:len(original)] == original)


def decode_packet(raw):
    """Independent framing/type/content-address check of the one actual packet."""
    cursor, values = 0, []
    while cursor < len(raw):
        end = raw.find(b"\n", cursor)
        if end < cursor:
            raise AssertionError("actual Git packet missing header")
        oid, kind, size_text = raw[cursor:end].split()
        size = int(size_text)
        value = raw[end + 1:end + 1 + size]
        if size < 0 or len(value) != size or raw[end + 1 + size:end + 2 + size] != b"\n":
            raise AssertionError("actual Git packet truncated")
        if hashlib.sha1(kind + b" " + str(size).encode() + b"\0" + value).hexdigest().encode() != oid:
            raise AssertionError("actual Git packet content address differs")
        values.append((oid.decode(), kind.decode(), value))
        cursor = end + 2 + size
    if cursor != len(raw):
        raise AssertionError("actual Git packet trailing bytes")
    return values


def actual_proof(scope, context):
    raw = (ROOT / history.HOLDEM_PATH).read_bytes()
    original_git, original_chain = history._git, history._holdem_exact_stage_chain
    records, chain_calls = [], []

    def git(root, *args, input=None):
        output = original_git(root, *args, input=input)
        records.append((args, input, output))
        return output

    def chain(*args, **kwargs):
        chain_calls.append((args[0], args[1]))
        return original_chain(*args, **kwargs)

    with patch.object(history, "_git", git), patch.object(history, "_holdem_exact_stage_chain", chain):
        with scope():
            observed = tuple(getattr(history, name)(raw, ROOT) for _prefix, name in STAGES)
        check("actual scope cleanup", context.get() is None)
    packets = [row for row in records if row[0] == ("cat-file", "--batch")]
    check("actual thirteen getters perform one whole chain", len(chain_calls) == 1 and len(packets) == 1)
    requests = packets[0][1].decode().splitlines()
    values = decode_packet(packets[0][2])
    check("actual packet contains all78 stage requests", len(requests) == len(values) == 78)
    before_values = []
    for index, (prefix, name) in enumerate(STAGES):
        offset = index * 6 + 4
        before = getattr(history, prefix + "BEFORE_COMMIT")
        blob = getattr(history, prefix + "BLOBS")[0]
        expected_sha = getattr(history, prefix + "HASHES")[0]
        oid, kind, witness = values[offset]
        check("actual immutable before blob " + name,
              requests[offset] == before + ":" + history.HOLDEM_PATH
              and oid == blob and kind == "blob" and sha(witness) == expected_sha
              and observed[index] == witness)
        before_values.append(witness)
    check("actual output consists only of immutable bytes", all(type(v) is bytes for v in observed))
    check("actual current source unchanged", (ROOT / history.HOLDEM_PATH).read_bytes() == raw)
    return raw, tuple(reversed(before_values))


@contextmanager
def synthetic_chain(raw, predecessors):
    """No Git, collector, disk writes or repeated immutable proof in this seam."""
    state = {"head": b"1" * 40 + b"\n", "blob": history.VICTORY_PARTICLE_BLOBS[1],
             "disk": raw, "calls": [], "git": [], "reads": 0,
             "error": None, "result": predecessors, "during": None}
    read_bytes = Path.read_bytes

    def git(root, *args, input=None):
        state["git"].append((Path(root), args, input))
        if state.get("git_error") is not None:
            raise state["git_error"]
        if args == ("rev-parse", "HEAD"):
            return state["head"]
        if args == ("rev-parse", "HEAD:" + history.HOLDEM_PATH):
            return (state["blob"] + "\n").encode()
        raise AssertionError("unexpected synthetic Git operation: " + repr(args))

    def read(path):
        if path == ROOT / history.HOLDEM_PATH:
            state["reads"] += 1
            return state["disk"]
        return read_bytes(path)

    def chain(current, root, stages):
        state["calls"].append((current, Path(root), stages))
        if state["during"] is not None:
            state["during"]()
        if state["error"] is not None:
            raise state["error"]
        return state["result"]

    with ExitStack() as stack:
        stack.enter_context(patch.object(history, "_git", git))
        stack.enter_context(patch.object(history, "_holdem_exact_stage_chain", chain))
        stack.enter_context(patch.object(Path, "read_bytes", read))
        yield state


def scope_boundaries(raw, predecessors):
    scope, context = history._holdem_manifest_proof_scope, history._HOLDEM_MANIFEST_PROOF_SCOPE
    proof = history._holdem_victory_particle_proof
    with synthetic_chain(raw, predecessors) as state:
        with scope():
            first = proof(raw, ROOT)
            check("synthetic cold result identity", first is predecessors)
            for index, (_prefix, name) in enumerate(STAGES):
                check("synthetic shared getter " + name,
                      getattr(history, name)(raw, ROOT) == predecessors[12 - index])
            check("synthetic thirteen getters share one proof", len(state["calls"]) == 1)
            check("synthetic warm uses fresh HEAD/blob/disk guards",
                  len(state["git"]) == 6 + 13 * 3 and state["reads"] == 4 + 13 * 2)
            rejects("immutable tuple element", lambda: setitem(first, 0, b"changed"))
            check("immutable thirteen exact bytes", type(first) is tuple and len(first) == 13
                  and all(type(part) is bytes for part in first))
        check("normal scope reset", context.get() is None)
        with scope():
            check("next scope fresh result", proof(raw, ROOT) is predecessors)
        proof(raw, ROOT)
        proof(raw, ROOT)
        check("next scope and two outside calls are fresh", len(state["calls"]) == 4)
        with scope():
            proof(raw, ROOT)
            outer = context.get()
            with scope():
                check("nested scope starts empty", context.get() == ())
                proof(raw, ROOT)
                check("nested successful slot distinct", context.get() is not outer)
            check("nested normal reset restores outer identity", context.get() is outer)
            sentinel = RuntimeError("nested sentinel")
            try:
                with scope():
                    proof(raw, ROOT)
                    raise sentinel
            except RuntimeError as error:
                check("nested exception identity", error is sentinel)
            check("nested exception reset restores outer identity", context.get() is outer)
            before = len(state["calls"])
            check("outer result still reusable", proof(raw, ROOT) is predecessors
                  and len(state["calls"]) == before)
        check("nested scopes leave no global slot", context.get() is None)
    with synthetic_chain(raw, predecessors) as state, scope():
        sentinel = object()
        old_raw = b"synthetic earlier Holdem source"
        with patch.object(history, "_VICTORY_PARTICLE_OLD_HAND_NET_PROOF", return_value=sentinel) as old:
            check("non455 raw delegates original earlier proof",
                  history._holdem_hand_net_proof(old_raw, ROOT) is sentinel
                  and old.call_args.args == (old_raw, ROOT))
        check("earlier raw does not initialize scope", context.get() == ()
              and not state["calls"] and not state["git"] and state["reads"] == 0)


def warm_faults(raw, predecessors):
    scope, context = history._holdem_manifest_proof_scope, history._HOLDEM_MANIFEST_PROOF_SCOPE
    proof = history._holdem_victory_particle_proof
    with synthetic_chain(raw, predecessors) as state, scope():
        proof(raw, ROOT)
        saved = context.get()

        def fault(label, operation):
            before = len(state["calls"])
            rejects(label, operation)
            check(label + " leaves saved success unchanged",
                  context.get() is saved and len(state["calls"]) == before)

        fault("warm different raw", lambda: proof(raw + b"\n", ROOT))
        fault("warm mutable same-value raw", lambda: proof(bytearray(raw), ROOT))
        fault("warm different root", lambda: proof(raw, ROOT / "synthetic-other-root"))
        for key, changed in (("head", b"2" * 40 + b"\n"), ("disk", raw + b"\n"), ("blob", "0" * 40)):
            original = state[key]
            state[key] = changed
            fault("warm " + key + " drift", lambda: proof(raw, ROOT))
            state[key] = original
            check("warm " + key + " recovery revalidates saved tuple", proof(raw, ROOT) is predecessors)
        for name, changed in (
            ("VICTORY_PARTICLE_BEFORE_COMMIT", "0" * 40),
            ("CANVAS_TREES", ("0" * 40, history.CANVAS_TREES[1])),
            ("VICTORY_PARTICLE_APPENDIX", history.VICTORY_PARTICLE_APPENDIX + "# drift\n"),
            ("VICTORY_PARTICLE_REPLACEMENT", ("wrong", "replacement")),
            ("holdem_victory_particle_inverse", lambda current, before: before),
            ("_holdem_exact_stage_chain", lambda current, root, stages: predecessors),
        ):
            with patch.object(history, name, changed):
                fault("warm binding drift " + name, lambda: proof(raw, ROOT))
            check("warm binding restored " + name, proof(raw, ROOT) is predecessors)
        inverse = history.holdem_victory_particle_inverse
        original_code = inverse.__code__
        try:
            inverse.__code__ = (lambda current, before: before).__code__
            fault("warm same function changed code", lambda: proof(raw, ROOT))
        finally:
            inverse.__code__ = original_code
        check("warm function code recovery", proof(raw, ROOT) is predecessors)
        state["git_error"] = OSError("synthetic fresh read failure")
        fault("warm fresh Git failure", lambda: proof(raw, ROOT))
        state["git_error"] = None
        check("warm read recovery has no reproving", proof(raw, ROOT) is predecessors
              and len(state["calls"]) == 1)
    check("warm fault scope reset", context.get() is None)


def cold_failures(raw, predecessors):
    scope, context = history._holdem_manifest_proof_scope, history._HOLDEM_MANIFEST_PROOF_SCOPE
    proof = history._holdem_victory_particle_proof
    with synthetic_chain(raw, predecessors) as state, scope():
        sentinel = ValueError("first proof failed")
        state["error"] = sentinel
        try:
            proof(raw, ROOT)
        except ValueError as error:
            check("first proof preserves exception identity", error is sentinel)
        else:
            raise AssertionError("first proof unexpectedly passed")
        check("failed proof stores nothing", context.get() == () and len(state["calls"]) == 1)
        state["error"] = None
        check("failed proof recovery fresh", proof(raw, ROOT) is predecessors and len(state["calls"]) == 2)
    for invalid in (list(predecessors), predecessors[:-1], (bytearray(b"x"),) + predecessors[1:]):
        with synthetic_chain(raw, predecessors) as state, scope():
            state["result"] = invalid
            rejects("invalid synthetic proof tuple", lambda: proof(raw, ROOT))
            check("invalid result not retained", context.get() == ())
            state["result"] = predecessors
            check("invalid result recovery reproves", proof(raw, ROOT) is predecessors and len(state["calls"]) == 2)
    for changing in ("head", "disk", "config"):
        with synthetic_chain(raw, predecessors) as state, scope():
            original = history.VICTORY_PARTICLE_APPENDIX

            def mutate():
                if changing == "head":
                    state["head"] = b"3" * 40 + b"\n"
                elif changing == "disk":
                    state["disk"] = raw + b"\n"
                else:
                    history.VICTORY_PARTICLE_APPENDIX = original + "# during proof\n"

            try:
                state["during"] = mutate
                rejects("during proof " + changing + " drift", lambda: proof(raw, ROOT))
                check("during proof failure leaves empty slot " + changing, context.get() == ())
            finally:
                history.VICTORY_PARTICLE_APPENDIX = original
                state.update(head=b"1" * 40 + b"\n", disk=raw, during=None)
            check("during proof recovery fresh " + changing,
                  proof(raw, ROOT) is predecessors and len(state["calls"]) == 2)
    check("all failed contexts reset", context.get() is None)


def matcher_delegation(raw, predecessors):
    """Real new wrapper, synthetic old-matcher delegate; no census substitution."""
    context = history._HOLDEM_MANIFEST_PROOF_SCOPE
    inventory = {"source_hashes": {history.HOLDEM_PATH: sha(raw)}, "untouched": [1, "sentinel"]}
    before = deepcopy(inventory)
    with synthetic_chain(raw, predecessors) as state:
        calls, answers = [], iter((True, False, True))

        def delegated(root, actual, expected):
            calls.append((root, actual, expected, context.get()))
            for _prefix, name in STAGES:
                getattr(history, name)(raw, root)
            return next(answers)

        with patch.object(append, "_HOLDEM_PROOF_SCOPE_OLD_MANIFEST_MATCHES", delegated):
            observed = [append._source_manifest_matches(ROOT, inventory, "manifest") for _ in range(3)]
        check("matcher allowed/rejected/recovery results not cached", observed == [True, False, True])
        check("matcher exact arguments and input preserved", len(calls) == 3
              and all(r == ROOT and i is inventory and e == "manifest" and c == () for r, i, e, c in calls)
              and inventory == before)
        check("each matcher performs fresh synthetic proof", len(state["calls"]) == 3 and context.get() is None)
        error = ValueError("old matcher failure")
        with patch.object(append, "_HOLDEM_PROOF_SCOPE_OLD_MANIFEST_MATCHES", side_effect=error):
            try:
                append._source_manifest_matches(ROOT, inventory, "manifest")
            except ValueError as caught:
                check("matcher exact failure propagated", caught is error)
            else:
                raise AssertionError("matcher swallowed old error")
        check("matcher exception cleanup", context.get() is None)
        legacy = {"source_manifest_sha256": "legacy"}
        sentinel = object()
        old_counts = len(state["git"]), len(state["calls"]), state["reads"]
        with patch.object(append, "_HOLDEM_PROOF_SCOPE_OLD_MANIFEST_MATCHES", return_value=sentinel) as old:
            check("legacy inventory delegates result identity",
                  append._source_manifest_matches(ROOT, legacy, "old") is sentinel
                  and old.call_args.args == (ROOT, legacy, "old"))
        check("legacy inventory has zero new proof I/O", context.get() is None
              and old_counts == (len(state["git"]), len(state["calls"]), state["reads"]))


def protected():
    paths = (Path(__file__).relative_to(ROOT).as_posix(), *REFERENCE_HASHES,
             "tools/order365_ui_receipt_compat.py", "tools/full_body_translation_scope.py",
             history.HOLDEM_PATH, *append.CURRENT_PATHS)
    return {path: sha((ROOT / path).read_bytes()) for path in paths}


def main():
    try:
        before = protected()
        source_preservation()
        raw, predecessors = actual_proof(history._holdem_manifest_proof_scope,
                                         history._HOLDEM_MANIFEST_PROOF_SCOPE)
        scope_boundaries(raw, predecessors)
        warm_faults(raw, predecessors)
        cold_failures(raw, predecessors)
        matcher_delegation(raw, predecessors)
        check("protected source/data bytes unchanged", before == protected())
    except Exception as error:
        print("HOLDEM_MANIFEST_PROOF_SCOPE_SELF_TEST_FAIL cases=%d" % len(CASES))
        print("".join(traceback.format_exception(type(error), error, error.__traceback__)), end="")
        return 1
    print("actual_chain_calls=1 actual_stage_requests=78 actual_predecessors=13 "
          "remaining_cases=synthetic_or_source_preservation fullbody_current50=NOT_RUN")
    print("HOLDEM_MANIFEST_PROOF_SCOPE_SELF_TEST_OK cases=%d historical_cases=0" % len(CASES))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
