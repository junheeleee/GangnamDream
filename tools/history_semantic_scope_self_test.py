#!/usr/bin/env python3
"""Bounded operation-local pure reuse controls; never translation acceptance.

Default: prepared owner/lifetime/adversarial controls with explicit pure stubs.
--actual: two original read_proof calls per plain arm and small live-edge controls.
No collector, official main, old suite, engine, source/ledger write or global cache.
"""
from __future__ import annotations

import argparse
import asyncio
import contextlib
import contextvars
import copy
import hashlib
import json
import sys
import threading
import time
from pathlib import Path
from unittest import mock

import asset_one_billion_log_history as B
import order470_source_compat as F

ROOT = Path(__file__).resolve().parents[1]


class Checks:
    def __init__(self):
        self.rows = []

    def check(self, ok, label):
        self.rows.append({"label": label, "passed": bool(ok)})

    def reject(self, action, label):
        try:
            action()
        except (ValueError, TypeError, KeyError, OSError, RuntimeError):
            self.check(True, label)
        else:
            self.check(False, label)


def b_cache():
    return B._PURE_SEMANTIC_OWNER.get()["cache"]


def f_cache():
    return F._SEMANTIC_MEMO.get()[1]


def invoke_b(before, after):
    return B._memoized_receipt_semantics(ROOT, before, after)


def invoke_f(inputs=(b"before", b"after"), calculate=lambda: b"result"):
    return F._memoized_semantics("prepared", inputs, calculate)


def prepared(checks):
    before = {p: ("before:" + p).encode() for p in B.PATHS}
    after = {p: ("after:" + p).encode() for p in B.PATHS}
    calls = {"B": 0, "F": 0}

    def pure_b(old, new):
        calls["B"] += 1
        if old != before or new != after:
            raise ValueError("prepared exact inputs differ")
        return B.RECEIPT_PARENT

    def pure_f():
        calls["F"] += 1
        return b"result"

    with mock.patch.object(B, "_receipt_semantics", pure_b):
        with B.pure_semantic_scope(ROOT):
            retained = b_cache()
            checks.check(invoke_b(before, after) == B.RECEIPT_PARENT, "B prepared cold")
            checks.check(invoke_b(dict(before), dict(after)) == B.RECEIPT_PARENT and calls["B"] == 1,
                         "B prepared warm exact raw equality")
            checks.check(len(retained) == 1 and all(type(v) is str for v in retained.values()),
                         "B one successful immutable value only")
        checks.check(not retained and B._PURE_SEMANTIC_OWNER.get() is None,
                     "B normal teardown erases retained dictionary")
        for _ in range(2):
            with B.pure_semantic_scope(ROOT):
                checks.check(not b_cache(), "B separate operation starts cold")
                invoke_b(before, after)
        checks.check(calls["B"] == 3, "B two operations calculate independently")
        def nested_b():
            with B.pure_semantic_scope(ROOT):
                invoke_b(before, after)
                retained = b_cache()
                def enter_nested():
                    with B.pure_semantic_scope(ROOT):
                        pass
                checks.reject(enter_nested, "B nested owner is explicitly rejected")
                checks.check(not retained, "B rejected nesting clears retained success")
                checks.reject(lambda: invoke_b(before, after), "B rejected nesting poisons owner")
        checks.reject(nested_b, "B rejected nesting rejects outer normal exit")

        mutations = []
        for side in (0, 1):
            for path in B.PATHS:
                old, new = dict(before), dict(after)
                (old if side == 0 else new)[path] += b"\n"
                mutations.append((old, new, "raw side%d %s" % (side, path)))
            for kind in ("missing", "extra", "type"):
                old, new = dict(before), dict(after)
                target = old if side == 0 else new
                if kind == "missing":
                    target.pop(B.PATHS[0])
                elif kind == "extra":
                    target["unowned"] = b"unowned"
                else:
                    target[B.PATHS[0]] = bytearray(target[B.PATHS[0]])
                mutations.append((old, new, "%s side%d" % (kind, side)))
        mutations.extend([(list(before), after, "map type before"),
                          (before, list(after), "map type after")])
        for old, new, label in mutations:
            retained = None
            def mutate():
                nonlocal retained
                with B.pure_semantic_scope(ROOT):
                    invoke_b(before, after)
                    retained = b_cache()
                    checks.reject(lambda: invoke_b(old, new), "B prepared rejects " + label)
                    checks.check(not retained, "B caught failure clears " + label)
                    checks.reject(lambda: invoke_b(before, after), "B caught failure poisons " + label)
            checks.reject(mutate, "B caught failure rejects owner exit " + label)
            checks.check(retained is not None and not retained, "B rejected owner final clear " + label)

    for bad in ({"mutable": True}, b"not-parent", None, "wrong-parent"):
        mode = {"bad": False}
        def result_b(old, new):
            return bad if mode["bad"] else B.RECEIPT_PARENT
        def reject_result():
            with mock.patch.object(B, "_receipt_semantics", result_b):
                with B.pure_semantic_scope(ROOT):
                    invoke_b(before, after)
                    retained = b_cache()
                    changed = dict(after)
                    changed[B.PATHS[0]] += b"\n"
                    mode["bad"] = True
                    checks.reject(lambda: invoke_b(before, changed), "B rejects non-parent immutable result " + type(bad).__name__)
                    checks.check(not retained, "B invalid result clears successful cache")
        checks.reject(reject_result, "B invalid result poisons owner exit")

    for module, call, cache in ((B, lambda: invoke_b(before, after), b_cache),
                               (F, lambda: invoke_f(calculate=pure_f), f_cache)):
        label = "B" if module is B else "F"
        patch = mock.patch.object(B, "_receipt_semantics", pure_b) if module is B else contextlib.nullcontext()
        with patch:
            for exception in (ValueError, KeyboardInterrupt):
                retained = None
                try:
                    with module.pure_semantic_scope(ROOT):
                        call()
                        retained = cache()
                        raise exception("prepared consumer escape")
                except exception:
                    pass
                checks.check(retained is not None and not retained, label + " escape clears " + exception.__name__)
                checks.check(module._ACTIVE.get() is None, label + " escape restores active proof token")

            def wrong_root():
                with module.pure_semantic_scope(ROOT / "unowned"):
                    pass
            checks.reject(wrong_root, label + " rejects wrong root")
            async def async_entry():
                with module.pure_semantic_scope(ROOT):
                    call()
            checks.reject(lambda: asyncio.run(async_entry()), label + " rejects async event-loop entry")

            for other_context in ("copy", "thread"):
                retained = None
                outcomes = []
                def sharing():
                    try:
                        call()
                    except (ValueError, RuntimeError):
                        outcomes.append("rejected")
                    else:
                        outcomes.append("accepted")
                def owner():
                    nonlocal retained
                    with module.pure_semantic_scope(ROOT):
                        call()
                        retained = cache()
                        copied = contextvars.copy_context()
                        if other_context == "copy":
                            copied.run(sharing)
                        else:
                            thread = threading.Thread(target=copied.run, args=(sharing,))
                            thread.start()
                            thread.join(timeout=5)
                            checks.check(not thread.is_alive(), label + " other thread terminated")
                        checks.check(outcomes == ["rejected"], label + " rejects " + other_context + " sharing")
                        checks.check(not retained, label + " cross-context clears retained cache")
                checks.reject(owner, label + " cross-context poisons owner exit " + other_context)

        binding_changes = [
            (module, "RECEIPT_PARENT", "0" * 40),
            (module, "product_inverse", lambda *a, **k: b"wrong"),
            (module._Document, "ws", lambda *a: 0),
            (module._Document, "__init__", lambda *a: None),
            (json, "loads", lambda *a, **k: {}),
            (json, "dumps", lambda *a, **k: "{}"),
            (json.JSONEncoder, "encode", lambda *a, **k: "{}"),
            (json.JSONDecoder, "raw_decode", lambda *a, **k: ({}, 0)),
            (copy, "deepcopy", lambda value, *a, **k: value),
            (copy, "_deepcopy_dispatch", {**copy._deepcopy_dispatch, bytes: lambda *a: b"wrong"}),
            (hashlib, "sha256", lambda *a, **k: None),
            (hashlib, "sha1", lambda *a, **k: None),
        ]
        if module is F:
            binding_changes.append((module.re, "compile", lambda *a, **k: None))
        for target, name, value in binding_changes:
            def drift():
                with patch:
                    with module.pure_semantic_scope(ROOT):
                        call()
                        retained = cache()
                        with mock.patch.object(target, name, value):
                            checks.reject(call, label + " rejects binding " + name)
                        checks.check(not retained, label + " binding drift clears " + name)
                        checks.reject(call, label + " binding restore cannot unpoison " + name)
            checks.reject(drift, label + " drift rejects normal owner exit " + name)
        for name, value in (("__code__", (lambda *a, **k: b"wrong").__code__),
                            ("__defaults__", (b"changed-default",))):
            def same_identity_drift():
                with patch:
                    with module.pure_semantic_scope(ROOT):
                        call()
                        retained = cache()
                        with mock.patch.object(module.product_inverse, name, value):
                            checks.reject(call, label + " rejects same identity " + name)
                        checks.check(not retained, label + " same identity drift clears " + name)
            checks.reject(same_identity_drift, label + " same identity drift rejects exit " + name)

        original_disk = module._disk_bytes
        mode = {"drift": False}
        def stable_disk(path):
            raw = original_disk(path)
            return raw + b"\n" if mode["drift"] and Path(path) == Path(module.__file__).resolve() else raw
        def physical_binding():
            with patch, mock.patch.object(module, "_disk_bytes", stable_disk):
                with module.pure_semantic_scope(ROOT):
                    call()
                    retained = cache()
                    mode["drift"] = True
                    checks.reject(call, label + " module bytes drift via stable reader")
                    checks.check(not retained, label + " module drift clears")
        checks.reject(physical_binding, label + " module drift rejects owner exit")
        mode["drift"] = False

    start = calls["F"]
    with F.pure_semantic_scope(ROOT):
        retained = f_cache()
        checks.check(invoke_f(calculate=pure_f) == b"result", "F prepared cold")
        checks.check(invoke_f(calculate=pure_f) == b"result" and calls["F"] == start + 1,
                     "F warm exact key equality")
        invoke_f((b"before\n", b"after"), pure_f)
        checks.check(calls["F"] == start + 2, "F different exact bytes calculate again")
        with F.pure_semantic_scope(ROOT):
            checks.check(f_cache() is retained, "F nested owner shares same bounded operation")
    checks.check(not retained and F._SEMANTIC_MEMO.get() is None,
                 "F normal teardown erases retained dictionary and restores token")
    for result in ({"mutable": True}, ["mutable"]):
        def mutable_result():
            with F.pure_semantic_scope(ROOT):
                invoke_f()
                retained = f_cache()
                checks.reject(lambda: invoke_f((b"changed",), lambda: result), "F rejects mutable result")
                checks.check(not retained, "F mutable rejection clears success")
                checks.reject(invoke_f, "F caught mutable failure poisons operation")
        checks.reject(mutable_result, "F mutable failure rejects owner exit")
    for _ in range(2):
        with F.pure_semantic_scope(ROOT):
            checks.check(not f_cache(), "F separate operation starts cold")
            invoke_f(calculate=pure_f)
    checks.check(calls["F"] == start + 4, "F separate operations calculate independently")

    # These are prepared state-machine edges, not real typed Git observations.
    for label in ("normal", "nested", "ValueError", "KeyboardInterrupt", "exit mismatch"):
        state = {"reads": 0}
        retained = None
        def stable_proof(root):
            state["reads"] += 1
            return {"root": Path(root).resolve(), "head": "second" if label == "exit mismatch"
                    and state["reads"] > 1 else "first"}
        def exercise_fresh():
            nonlocal retained
            with mock.patch.object(F, "_read_proof", stable_proof):
                with F.pure_semantic_scope(ROOT):
                    retained = f_cache()
                    with F.fresh_validation_proof(ROOT) as proof:
                        invoke_f()
                        checks.check(F._ACTIVE.get() is proof, "F prepared ACTIVE bound " + label)
                        if label == "nested":
                            with F.fresh_validation_proof(ROOT) as nested:
                                checks.check(nested is proof, "F prepared nested proof identity")
                            checks.check(F._ACTIVE.get() is proof, "F prepared nested exit retains outer ACTIVE")
                        elif label in ("ValueError", "KeyboardInterrupt"):
                            raise ValueError("prepared") if label == "ValueError" else KeyboardInterrupt("prepared")
                    checks.check(F._ACTIVE.get() is None, "F prepared normal fresh restores ACTIVE " + label)
        if label in ("normal", "nested"):
            exercise_fresh()
        elif label == "KeyboardInterrupt":
            try:
                exercise_fresh()
            except KeyboardInterrupt:
                checks.check(True, "F prepared KeyboardInterrupt propagated")
            else:
                checks.check(False, "F prepared KeyboardInterrupt propagated")
        else:
            checks.reject(exercise_fresh, "F prepared fresh rejects " + label)
        checks.check(state["reads"] == (4 if label == "nested" else 2),
                     "F prepared original entry/exit read counts " + label)
        checks.check(retained is not None and not retained and F._ACTIVE.get() is None
                     and F._SEMANTIC_MEMO.get() is None and F._SEMANTIC_OWNER.get() is None,
                     "F prepared fresh final teardown " + label)

    # B's failure-observation wrapper must poison a real fresh equality failure.
    state = {"reads": 0}
    retained = None
    def changing_b_proof(root):
        state["reads"] += 1
        return {"root": Path(root).resolve(), "head": str(state["reads"])}
    def b_exit_mismatch():
        nonlocal retained
        with mock.patch.object(B, "_read_proof_current", changing_b_proof), mock.patch.object(B, "_receipt_semantics", pure_b):
            with B.pure_semantic_scope(ROOT):
                with B.fresh_validation_proof(ROOT):
                    invoke_b(before, after)
                    retained = b_cache()
    checks.reject(b_exit_mismatch, "B prepared original fresh comparison rejects mismatch")
    checks.check(state["reads"] == 2 and retained is not None and not retained and B._ACTIVE.get() is None,
                 "B prepared equality failure clears success and restores ACTIVE")


def actual(checks):
    import market_cycle_label_history as M
    import wealth_milestone_log_history as W
    modules = {"B": B, "F": F, "M": M, "W": W}
    results, reference, counts = {}, {}, {}
    # Install one set of identities for BOTH arms. _configuration seals these
    # callables, so recreating a closure per arm is not a comparable proof.
    with contextlib.ExitStack() as instrumentation:
        for name, module in modules.items():
            def git(root, *args, _original=module._git, _name=name, **kwargs):
                counts[_name]["git"] += 1
                counts[_name]["typed"] += args[:2] == ("cat-file", "--batch")
                return _original(root, *args, **kwargs)
            def disk(path, _original=module._disk_bytes, _name=name, _module=module):
                counts[_name]["module_disk" if Path(path) == Path(_module.__file__).resolve()
                              else "product_disk"] += 1
                return _original(path)
            instrumentation.enter_context(mock.patch.object(module, "_git", git))
            instrumentation.enter_context(mock.patch.object(module, "_disk_bytes", disk))
            for attr, counter in (("product_inverse", "product_semantics"),
                                  ("_receipt_semantics", "receipt_semantics")):
                def measured(*args, _original=getattr(module, attr), _name=name,
                             _counter=counter, **kwargs):
                    counts[_name][_counter] += 1
                    return _original(*args, **kwargs)
                instrumentation.enter_context(mock.patch.object(module, attr, measured))
        for scoped in (False, True):
            counts = {name: {"git": 0, "typed": 0, "product_disk": 0, "module_disk": 0,
                             "product_semantics": 0, "receipt_semantics": 0} for name in modules}
            start = time.perf_counter()
            with contextlib.ExitStack() as operation:
                if scoped:
                    operation.enter_context(B.pure_semantic_scope(ROOT))
                    operation.enter_context(F.pure_semantic_scope(ROOT))
                for name in ("B", "F"):
                    for iteration in range(2):
                        print("ORDER486_ACTUAL_PROGRESS arm=%s module=%s iteration=%d" %
                              ("scoped" if scoped else "unscoped", name, iteration + 1), flush=True)
                        proof = modules[name]._read_proof(ROOT)
                        if not scoped and iteration == 0:
                            reference[name] = proof
                        checks.check(proof == reference[name], "actual proof equal %s/%s/%d" % (scoped, name, iteration))
                if scoped:
                    b_retained, f_retained = b_cache(), f_cache()
            elapsed = time.perf_counter() - start
            if scoped:
                checks.check(not b_retained and not f_retained, "actual owner teardown erases both dictionaries")
            results["scoped" if scoped else "unscoped"] = {"seconds": elapsed, "counts": counts,
                                                             "original_B_reads": 2, "original_F_reads": 2}
            print("ORDER486_ACTUAL_ARM " + json.dumps(results["scoped" if scoped else "unscoped"]), flush=True)
    for name in modules:
        for edge in ("git", "typed", "product_disk"):
            checks.check(results["scoped"]["counts"][name][edge] == results["unscoped"]["counts"][name][edge],
                         "actual original edge preserved %s/%s" % (name, edge))
    for name in ("B", "F"):
        checks.check(results["scoped"]["counts"][name]["receipt_semantics"] == 1,
                     "actual %s receipt calculates once per operation" % name)
        checks.check(results["scoped"]["counts"][name]["receipt_semantics"] <
                     results["unscoped"]["counts"][name]["receipt_semantics"],
                     "actual %s pure calculations decrease" % name)

    # Stable readers are installed before admission; response changes reach the
    # original typed/head/product-disk checks, not just callable-identity guards.
    for label in ("HEAD", "type", "disk", "late disk"):
        original_git, original_disk = B._git, B._disk_bytes
        mode = {"value": "good", "reads": 0}
        def live_git(root, *args, **kwargs):
            raw = original_git(root, *args, **kwargs)
            if mode["value"] == "HEAD" and args[:2] == ("rev-parse", "--verify"):
                return ("0" * 40 + "\n").encode()
            if mode["value"] == "type" and args[:2] == ("cat-file", "--batch"):
                return raw.replace(b" commit ", b" blob ", 1)
            return raw
        def live_disk(path):
            raw = original_disk(path)
            if Path(path) == ROOT / B.GAME_STATE_PATH:
                mode["reads"] += 1
                if mode["value"] == "disk" or (mode["value"] == "late disk" and mode["reads"] == 2):
                    return raw + b"\n"
            return raw
        def warm_failure():
            with mock.patch.object(B, "_git", live_git), mock.patch.object(B, "_disk_bytes", live_disk):
                with B.pure_semantic_scope(ROOT):
                    B._read_proof(ROOT)
                    retained = b_cache()
                    mode["value"], mode["reads"] = label, 0
                    if label == "late disk":
                        # B observes product disk once/read. Its normal fresh exit
                        # is the second read; this proves the original exit stays live.
                        with B.fresh_validation_proof(ROOT):
                            pass
                    else:
                        checks.reject(lambda: B._read_proof(ROOT), "B actual warm rejection " + label)
                        checks.check(not retained, "B actual failure clears " + label)
                        mode["value"] = "good"
                        checks.reject(lambda: invoke_b(reference["B"]["source"], reference["B"]["receipts"]),
                                      "B actual caught failure remains poisoned " + label)
        checks.reject(warm_failure, "B actual failed owner rejects exit " + label)
    results["limits"] = "Selected original proof pair; no collector/main/engine/native/human/release observation. Additional module-binding reads are separate."
    # B's original finally edge stays live even after a consumer exception.
    original_git = B._git
    mode = {"bad": False, "calls": 0}
    def final_head(root, *args, **kwargs):
        mode["calls"] += 1
        raw = original_git(root, *args, **kwargs)
        if mode["bad"] and args[:2] == ("rev-parse", "--verify"):
            return ("0" * 40 + "\n").encode()
        return raw
    with mock.patch.object(B, "_git", final_head):
        try:
            with B.pure_semantic_scope(ROOT):
                with B.fresh_validation_proof(ROOT):
                    mode["bad"] = True
                    raise KeyboardInterrupt("actual consumer escape")
        except ValueError:
            checks.check(True, "B actual exceptional fresh exit observes bad HEAD")
        except KeyboardInterrupt:
            checks.check(False, "B actual exceptional fresh exit skipped bad HEAD")
        checks.check(mode["calls"] > 0 and B._ACTIVE.get() is None and B._PURE_SEMANTIC_OWNER.get() is None,
                     "B actual exceptional fresh teardown restores tokens")

    original_git = F._git
    mode = {"bad": False}
    def final_f_head(root, *args, **kwargs):
        raw = original_git(root, *args, **kwargs)
        if mode["bad"] and args[:2] == ("rev-parse", "--verify"):
            return ("0" * 40 + "\n").encode()
        return raw
    def f_warm_failure():
        with mock.patch.object(F, "_git", final_f_head):
            with B.pure_semantic_scope(ROOT), F.pure_semantic_scope(ROOT):
                F._read_proof(ROOT)
                retained = f_cache()
                mode["bad"] = True
                checks.reject(lambda: F._read_proof(ROOT), "F actual warm HEAD rejection")
                checks.check(not retained, "F actual warm rejection clears successes")
                mode["bad"] = False
                checks.reject(invoke_f, "F actual caught HEAD failure poisons operation")
    checks.reject(f_warm_failure, "F actual failed owner rejects normal exit")
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--actual", action="store_true")
    args = parser.parse_args()
    checks = Checks()
    fatal, measurements = None, None
    try:
        if args.actual:
            measurements = actual(checks)
        else:
            prepared(checks)
    except BaseException as error:
        fatal = {"type": type(error).__name__, "message": str(error)}
    passed = fatal is None and bool(checks.rows) and all(row["passed"] for row in checks.rows)
    print(json.dumps({"passed": passed, "mode": "actual" if args.actual else "prepared",
                      "cases": len(checks.rows), "checks": checks.rows,
                      "measurements": measurements, "fatal": fatal}, ensure_ascii=False))
    print("ORDER486_SEMANTIC_SCOPE_OK" if passed else "ORDER486_SEMANTIC_SCOPE_FAIL", flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
