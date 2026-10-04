#!/usr/bin/env python3
"""Synthetic453 delegation/site tests; no receipt main, collector, or old suite.

Only the new stdlib-only profiler is imported. The append/exchange objects and
comparison source below are in-memory fakes, not repository admission evidence.
"""
from __future__ import annotations

import ast
import itertools
import sys
import types
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
import ui_receipt_cost_profile as profile

NAMES = ("_correction_comparison", "_fee_comparison", "_legacy_ja_gift_comparison",
         "_legacy_ja_rank_comparison", "_legacy_ja_residual_comparison")
SOURCE_FILE = str(Path(__file__).resolve().with_name("synthetic453_not_a_repository_module.py"))


class Fixture:
    def __init__(self, nested=False, loop=False):
        self.append = types.ModuleType("synthetic453_append")
        self.exchange = types.SimpleNamespace()
        self.answer = object()
        self.document_answer = object()
        self.error = RuntimeError("synthetic original failure")
        self.calls = []
        self.failures = set()
        self.raw = b'{"same":1}'
        self.snapshot = {"ledger": self.raw}
        self.argv = sys.argv
        self.argv_contents = list(sys.argv)

        def delegate(name, *args, **kwargs):
            self.calls.append((name, args, kwargs))
            if name in self.failures:
                raise self.error
            return self.document_answer if name == "_Document" else self.answer

        self.append._Document = lambda raw: delegate("_Document", raw)
        self.append._delegate = delegate
        self.append._answer = self.answer
        self.append._nested = lambda name: None
        parts = []
        for name in NAMES:
            parts.append("def " + name + "(snapshot, before, after):\n")
            if loop:
                parts.append('    for path in ("ui", "ledger"):\n'
                             '        a, b = _Document(before[path]), _Document(after[path])\n'
                             '        doc = _Document(snapshot[path])\n')
            elif nested:
                parts.append('    a = _Document(before["ledger"])\n'
                             '    _nested("' + name + '")\n'
                             '    b, doc = (_Document(raw) for raw in (after["ledger"], snapshot["ledger"]))\n')
            else:
                parts.append('    a, b, doc = (_Document(raw) for raw in (before["ledger"], after["ledger"], snapshot["ledger"]))\n')
            parts.append('    return _answer\n\n')
        self.code = "".join(parts)
        exec(compile(self.code, SOURCE_FILE, "exec"), vars(self.append))
        self.sites = {}
        for function in ast.parse(self.code).body:
            calls = sorted((node for node in ast.walk(function) if isinstance(node, ast.Call)
                            and isinstance(node.func, ast.Name) and node.func.id == "_Document"), key=lambda n: n.lineno)
            if loop:
                self.sites[function.name] = {
                    calls[0].lineno: profile.Site(roles=("before", "after", "before", "after"), local_path="path", max_calls=4),
                    calls[-1].lineno: profile.Site(roles=("dynamic",), local_path="path", max_calls=2, required=False),
                }
                continue
            roles = [("before",), ("after", "dynamic")] if nested else [("before", "after", "dynamic")]
            self.sites[function.name] = {
                call.lineno: profile.Site(roles=role, paths=("ledger",) * len(role), max_calls=len(role))
                for call, role in zip(calls, roles)
            }
        self.append.current_proof = lambda *args, **kwargs: delegate("current_proof", *args, **kwargs)
        self.append.validate_history = lambda *args, **kwargs: delegate("validate_history", *args, **kwargs)
        self.exchange.collect = lambda *args, **kwargs: delegate("collect", *args, **kwargs)
        self.originals = {name: getattr(self.append, name) for name in ("_Document", *NAMES, "current_proof", "validate_history")}
        self.original_collect = self.exchange.collect
        self.profiler = profile.ReceiptCostProfiler(self.append, self.exchange, source_file=SOURCE_FILE,
                                                    sites=self.sites, clock=itertools.count(0, 100).__next__)
        if loop: self.snapshot["ui"] = self.raw

    def call(self, name=NAMES[0]):
        return getattr(self.append, name)(self.snapshot, self.snapshot, self.snapshot)

    def restored(self, test):
        for name, original in self.originals.items():
            test.assertIs(getattr(self.append, name), original, name)
        test.assertIs(self.exchange.collect, self.original_collect)
        test.assertIs(sys.argv, self.argv)
        test.assertEqual(sys.argv, self.argv_contents)


class ProfileCheck(unittest.TestCase):
    def assert_totals(self, summary):
        rows, total = summary["documents"], summary["documents_total"]
        for field in ("calls", "failures", "bytes", "total_ns"):
            self.assertEqual(total[field], sum(row[field] for row in rows), field)
        for row in rows + summary["functions"]:
            self.assertGreaterEqual(row["calls"], 1)
            self.assertGreaterEqual(row["failures"], 0)
            self.assertLessEqual(row["failures"], row["calls"])
            self.assertGreaterEqual(row["total_ns"], 0)

    def test_all_five_generator_roles_identical_raw_and_return_identity(self):
        fixture = Fixture()
        with fixture.profiler.installed(argv=["synthetic453", "--default"]):
            self.assertEqual(sys.argv, ["synthetic453", "--default"])
            for name in NAMES:
                self.assertIs(fixture.call(name), fixture.answer)
        fixture.restored(self)
        summary = fixture.profiler.summary()
        self.assertEqual(summary["errors"], [])
        self.assertTrue(summary["restored"])
        self.assert_totals(summary)
        self.assertEqual(summary["documents_total"]["calls"], 15)
        self.assertEqual(summary["documents_total"]["bytes"], 15 * len(fixture.raw))
        self.assertEqual(summary["documents_total"]["failures"], 0)
        self.assertEqual(summary["documents_total"]["total_ns"], 1500)
        self.assertTrue(all(row["calls"] == 1 and row["total_ns"] == 700 for row in summary["functions"]))
        for name in NAMES:
            rows = [row for row in summary["documents"] if row["comparison"] == name]
            self.assertEqual({row["role"] for row in rows}, {"before", "after", "dynamic"})
            self.assertEqual(len(rows), 3)
            self.assertTrue(all(row["path"] == "ledger" and row["calls"] == 1 for row in rows))
            self.assertTrue(all(row["caller_function"] == "<genexpr>" for row in rows))
        self.assertEqual(len(fixture.calls), 15)
        self.assertTrue(all(name == "_Document" and args[0] is fixture.raw and kwargs == {}
                            for name, args, kwargs in fixture.calls))

    def test_delegate_arguments_identity_and_single_invocation(self):
        fixture = Fixture(); token = object()
        with fixture.profiler.installed():
            for owner, name in ((fixture.append, "current_proof"), (fixture.append, "validate_history"), (fixture.exchange, "collect")):
                self.assertIs(getattr(owner, name)(token, marker=token), fixture.answer)
            self.assertIs(fixture.append._Document(fixture.raw), fixture.document_answer)
        fixture.restored(self)
        self.assertEqual([row[0] for row in fixture.calls], ["current_proof", "validate_history", "collect", "_Document"])
        for name, args, kwargs in fixture.calls[:3]:
            self.assertIs(args[0], token); self.assertIs(kwargs["marker"], token)
        summary = fixture.profiler.summary(); self.assert_totals(summary)
        self.assertEqual(summary["documents_total"]["calls"], 1)
        self.assertEqual(summary["documents"][0]["role"], "other")

    def test_direct_pair_and_dynamic_two_path_loop(self):
        fixture = Fixture(loop=True)
        with fixture.profiler.installed(): self.assertIs(fixture.call(), fixture.answer)
        fixture.restored(self)
        summary = fixture.profiler.summary(); self.assert_totals(summary)
        self.assertEqual(summary["errors"], [])
        self.assertEqual(summary["documents_total"]["calls"], 6)
        self.assertEqual(len(summary["documents"]), 6)
        self.assertEqual({(row["path"], row["role"]) for row in summary["documents"]},
                         {(path, role) for path in ("ui", "ledger") for role in ("before", "after", "dynamic")})
        self.assertTrue(all(row["caller_function"] == NAMES[0] and row["calls"] == 1 for row in summary["documents"]))

    def test_original_exception_identity_and_failure_counts(self):
        for name in ("_Document", "current_proof", "validate_history", "collect"):
            with self.subTest(delegate=name):
                fixture = Fixture(); fixture.failures.add(name)
                try:
                    with fixture.profiler.installed(argv=["synthetic453"]):
                        if name == "_Document": fixture.call()
                        else: getattr(fixture.exchange if name == "collect" else fixture.append, name)()
                except RuntimeError as error:
                    self.assertIs(error, fixture.error)
                else: self.fail("original exception disappeared")
                fixture.restored(self)
                self.assertEqual(len(fixture.calls), 1)
                summary = fixture.profiler.summary(); self.assert_totals(summary)
                if name == "_Document":
                    self.assertEqual(summary["documents_total"]["failures"], 1)
                    self.assertEqual(summary["documents_total"]["calls"], 1)
                expected_name = NAMES[0] if name == "_Document" else "collector" if name == "collect" else name
                self.assertEqual([(r["name"], r["calls"], r["failures"]) for r in summary["functions"]],
                                 [(expected_name, 1, 1)])
                self.assertTrue(summary["restored"])

    def test_external_exception_restores_all_aliases_and_original_argv(self):
        fixture = Fixture(); error = LookupError("synthetic body failure")
        try:
            with fixture.profiler.installed(argv=["synthetic453", "normal"]):
                self.assertIs(fixture.call(), fixture.answer)
                sys.argv.append("changed temporary argv")
                raise error
        except LookupError as actual:
            self.assertIs(actual, error)
        else: self.fail("body exception disappeared")
        fixture.restored(self)

    def test_nested_comparison_context_returns_to_outer_site(self):
        for inner_failure in (False, True):
            with self.subTest(inner_failure=inner_failure):
                fixture = Fixture(nested=True)
                def nested(name):
                    if name != NAMES[0]: return
                    if not inner_failure: return fixture.call(NAMES[1])
                    fixture.failures.add("_Document")
                    try: fixture.call(NAMES[1])
                    except RuntimeError as error: self.assertIs(error, fixture.error)
                    else: self.fail("inner original exception disappeared")
                    finally: fixture.failures.clear()
                fixture.append._nested = nested
                with fixture.profiler.installed(): self.assertIs(fixture.call(), fixture.answer)
                fixture.restored(self)
                summary = fixture.profiler.summary(); self.assert_totals(summary)
                self.assertEqual(summary["errors"], [])
                self.assertEqual(summary["documents_total"]["calls"], 4 if inner_failure else 6)
                self.assertEqual(summary["documents_total"]["failures"], int(inner_failure))
                for name in NAMES[:2]:
                    rows = [row for row in summary["documents"] if row["comparison"] == name]
                    roles = {"before"} if inner_failure and name == NAMES[1] else {"before", "after", "dynamic"}
                    self.assertEqual({row["role"] for row in rows}, roles)
                    self.assertEqual(sum(row["calls"] for row in rows), len(roles))

    def test_roles_restart_per_invocation_without_result_reuse(self):
        fixture = Fixture()
        with fixture.profiler.installed():
            self.assertIs(fixture.call(), fixture.answer)
            self.assertIs(fixture.call(), fixture.answer)
        fixture.restored(self)
        summary = fixture.profiler.summary(); self.assert_totals(summary)
        self.assertEqual(summary["errors"], [])
        self.assertEqual(len(fixture.calls), 6)
        self.assertTrue(all(row["calls"] == 2 for row in summary["documents"]))
        self.assertEqual({row["role"] for row in summary["documents"]}, {"before", "after", "dynamic"})

    def test_installation_reentry_rejected_without_disturbing_outer_scope(self):
        fixture = Fixture()
        self.assertTrue(fixture.profiler.summary()["restored"])
        with fixture.profiler.installed(argv=["outer453"]):
            self.assertFalse(fixture.profiler.summary()["restored"])
            wrappers = {name: getattr(fixture.append, name) for name in fixture.originals}
            collector, argv = fixture.exchange.collect, sys.argv
            with self.assertRaises(RuntimeError):
                with fixture.profiler.installed(argv=["inner453"]):
                    self.fail("nested installation entered")
            self.assertIs(sys.argv, argv); self.assertEqual(sys.argv, ["outer453"])
            self.assertIs(fixture.exchange.collect, collector)
            for name, wrapper in wrappers.items(): self.assertIs(getattr(fixture.append, name), wrapper)
            self.assertIs(fixture.call(), fixture.answer)
        fixture.restored(self)
        self.assertTrue(fixture.profiler.summary()["restored"])

    def test_unknown_site_reports_classification_error_without_changing_return(self):
        fixture = Fixture()
        fixture.profiler = profile.ReceiptCostProfiler(fixture.append, fixture.exchange, source_file=SOURCE_FILE,
            sites={name: {} for name in NAMES}, clock=itertools.count().__next__)
        with fixture.profiler.installed(): self.assertIs(fixture.call(), fixture.answer)
        fixture.restored(self)
        summary = fixture.profiler.summary(); self.assert_totals(summary)
        self.assertTrue(summary["errors"])
        self.assertEqual(summary["documents_total"]["calls"], 3)

    def test_partial_installation_failure_restores_prior_bindings(self):
        fixture = Fixture()
        class FailOnce(types.SimpleNamespace):
            def __setattr__(self, name, value):
                if self.__dict__.get("armed") and name == NAMES[1]:
                    self.__dict__["armed"] = False
                    raise fixture.error
                super().__setattr__(name, value)
        fixture.append = FailOnce(**vars(fixture.append)); fixture.append.armed = True
        profiler = profile.ReceiptCostProfiler(fixture.append, fixture.exchange, source_file=SOURCE_FILE, sites=fixture.sites)
        try:
            with profiler.installed(argv=["never installed fully"]):
                self.fail("failed installation entered body")
        except RuntimeError as error:
            self.assertIs(error, fixture.error)
        else: self.fail("installation exception disappeared")
        fixture.restored(self)
        self.assertTrue(profiler.summary()["restored"])
        self.assertEqual(fixture.calls, [])

    def test_recording_fault_does_not_mask_return_or_original_exception(self):
        for original_fails in (False, True):
            with self.subTest(original_fails=original_fails):
                fixture = Fixture()
                if original_fails: fixture.failures.add("_Document")
                def fail_recording(*args, **kwargs): raise OSError("synthetic metric recording failure")
                fixture.profiler._add = fail_recording
                try:
                    with fixture.profiler.installed():
                        returned = fixture.call()
                except RuntimeError as error:
                    self.assertTrue(original_fails); self.assertIs(error, fixture.error)
                else:
                    self.assertFalse(original_fails); self.assertIs(returned, fixture.answer)
                fixture.restored(self)
                self.assertEqual(len(fixture.calls), 1 if original_fails else 3)
                self.assertTrue(fixture.profiler.summary()["errors"])

    def test_clock_failure_is_separate_from_delegate_outcome(self):
        fixture = Fixture()
        def broken_clock(): raise OSError("synthetic clock failure")
        fixture.profiler.clock = broken_clock
        with fixture.profiler.installed(): self.assertIs(fixture.call(), fixture.answer)
        fixture.restored(self)
        summary = fixture.profiler.summary(); self.assert_totals(summary)
        self.assertTrue(summary["errors"])
        self.assertEqual(summary["documents_total"]["calls"], 3)
        self.assertEqual(summary["documents_total"]["failures"], 0)
        self.assertEqual(summary["documents_total"]["total_ns"], 0)

    def test_source_and_site_ordinal_drift_do_not_suppress_real_calls(self):
        for fault in ("source", "ordinal"):
            with self.subTest(fault=fault):
                fixture = Fixture()
                if fault == "source": fixture.profiler.source_file += ".different"
                else:
                    line = next(iter(fixture.profiler.sites[NAMES[0]]))
                    fixture.profiler.sites[NAMES[0]][line] = profile.Site(("before", "after"), ("ledger", "ledger"))
                with fixture.profiler.installed(): self.assertIs(fixture.call(), fixture.answer)
                fixture.restored(self)
                summary = fixture.profiler.summary(); self.assert_totals(summary)
                self.assertTrue(summary["errors"])
                self.assertEqual(summary["documents_total"]["calls"], 3)
                self.assertEqual(len(fixture.calls), 3)


def main():
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(ProfileCheck))
    print("UI_RECEIPT_COST_PROFILE_CHECK_" + ("OK" if result.wasSuccessful() else "FAIL") +
          " cases=" + str(result.testsRun) + " historical_cases=0")
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
