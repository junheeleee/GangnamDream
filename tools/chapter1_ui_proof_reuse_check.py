#!/usr/bin/env python3
"""Bounded ORDER-408 scope regressions, not a whole-current admission audit.

The Git prefix check is real. Control-flow tests use the real receipt context,
raw guards, saved Chapter1/267 delegate and both font comparison call sites,
but replace expensive proof leaves and font inverses with invocation-local
spies. Injected Git/HEAD faults are synthetic, not modified Git objects. The
separate Chapter1 normal run owns actual immutable/current receipt admission,
historical inverses, corpus diagnostics and timing. No repository writes,
cross-call proof cache, Godot, old self-test suite or renderer claims here.
"""
from __future__ import annotations

import contextlib
import copy
import hashlib
import subprocess
import sys
import unittest
from pathlib import Path
from unittest import mock

import chapter1_core_loop_v2_causal_ledger_check as chapter1


receipts = chapter1.ui_receipts
ROOT = Path(__file__).resolve().parents[1]
CHAPTER_PATH = "tools/chapter1_core_loop_v2_causal_ledger_check.py"
DECLARATION = "ed476048c7c2e2aa21d3cc64eb4a8b2941b0ba73"
PREVIOUS_PRODUCT = "9e3705a8d1b631adcd9f5aff861b6883e2696867"
PREFIX_SHA256 = "c94edb2a95d717d07b05c5182c633e70ee8ef7e5d2a7c5704a0691f6bb1066f5"
BEGIN = b"# BEGIN_CHAPTER1_UI_PROOF_REUSE_408\n"
END = b"# END_CHAPTER1_UI_PROOF_REUSE_408\n\n"
PROOF_ERROR = "ORDER-365: whole current proof rejected: "
OLD_DELEGATE = chapter1._UI_PROOF_REUSE_OLD_SNAPSHOT_ERRORS
CURRENT_SOURCE_ERRORS = receipts.current_source_errors


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


class PrefixTests(unittest.TestCase):
    def test_real_git_prefix_main_and_267_delegate_are_preserved(self):
        originals = []
        for revision in (DECLARATION, PREVIOUS_PRODUCT):
            result = subprocess.run(
                ("git", "--no-replace-objects", "show", revision + ":" + CHAPTER_PATH),
                cwd=ROOT, capture_output=True, check=True, timeout=30)
            self.assertEqual(sha(result.stdout), PREFIX_SHA256)
            originals.append(result.stdout)
        self.assertEqual(*originals)
        current = (ROOT / CHAPTER_PATH).read_bytes()
        self.assertEqual(current.count(BEGIN), 1)
        self.assertEqual(current.count(END), 1)
        prefix, rest = current.split(BEGIN, 1)
        appendix, suffix = rest.split(END, 1)
        self.assertTrue(appendix)
        self.assertEqual(suffix, b'if __name__ == "__main__":\n    sys.exit(main())\n')
        self.assertEqual(prefix + suffix, originals[0])
        self.assertIn(b"# END_NEW_RUN_LOG_CHAPTER_267\n\n", prefix)
        self.assertIs(OLD_DELEGATE, chapter1._new_run_chapter_snapshot_errors)
        self.assertIs(chapter1._audited_source_snapshot_errors,
                      chapter1._ui_proof_reuse_snapshot_errors)
        self.assertIsNot(chapter1._NEW_RUN_OLD_SNAPSHOT_ERRORS, OLD_DELEGATE)


class ScopedControlFlowTests(unittest.TestCase):
    """Real orchestration/guards; synthetic proof leaves, explicitly not admission."""

    def setUp(self):
        self.stack = contextlib.ExitStack()
        self.addCleanup(self.stack.close)
        for variable in (receipts._ACTIVE_PROOF, receipts._ACTIVE_CURRENT):
            token = variable.set(None)
            self.stack.callback(variable.reset, token)
        self.trace = []
        self.previous_depth = 0
        self.proof = {p: (b"old:" + p.encode(), b"base:" + p.encode())
                      for p in receipts.CURRENT_PATHS}
        # Actual submitted raw files still pass the real per-raw equality guard;
        # their admission certificate is synthetic in this test class only.
        self.raw = {p: (ROOT / p).read_bytes() for p in receipts.ui_append.CURRENT_PATHS}
        self.ja_raw = b'{"synthetic":"Japanese baseline"}\n'
        self.font_raw = {p: (ROOT / p).read_bytes() for p in receipts.RUNTIME_COMPARISON_PATHS}
        self.claims = {p: sha(raw) for p, raw in self.font_raw.items()}
        self.read = self.patch(receipts, "_read_proof", side_effect=self._read)
        self.verify = self.patch(receipts, "_verify_transition", side_effect=self._verify)
        self.previous = self.patch(receipts.previous, "fresh_validation_proof",
                                   side_effect=self._previous)
        self.patch(receipts.previous, "source_errors", return_value=[])
        self.patch(receipts.ui_append, "_objects", return_value=[self.ja_raw])
        self.patch(receipts, "JA_BASELINE_SHA256", new=sha(self.ja_raw))
        self.current = self.patch(receipts.ui_append, "current_proof", side_effect=self._current)
        self.admission = self.patch(receipts, "current_source_errors", side_effect=self._admission)
        self.job_font = self.patch(receipts, "_runtime_predecessor",
                                   side_effect=lambda raw: self._font("job", raw))
        self.aruba_font = self.patch(receipts.ui_append, "aruba_font_predecessor",
                                     side_effect=lambda root, raw: self._font("aruba", raw))
        self.body = self.patch(chapter1, "_UI_PROOF_REUSE_OLD_SNAPSHOT_ERRORS", wraps=OLD_DELEGATE)
        # Any accidentally unbounded proof/history work fails immediately.
        self.patch(subprocess, "run", side_effect=AssertionError("unexpected subprocess in scoped control-flow test"))

    def patch(self, owner, name, **kwargs):
        return self.stack.enter_context(mock.patch.object(owner, name, **kwargs))

    def _read(self):
        self.trace.append("read")
        return copy.deepcopy(self.proof)

    def _verify(self, pairs):
        self.assertEqual(pairs, tuple((p, *self.proof[p]) for p in receipts.CURRENT_PATHS))

    @contextlib.contextmanager
    def _previous(self):
        self.previous_depth += 1
        try:
            yield
        finally:
            self.previous_depth -= 1

    def _current(self, root, revision, baseline):
        self.assertEqual(root, receipts.ROOT)
        self.assertEqual(revision, receipts.AFTER_COMMIT)
        self.assertEqual(baseline, {**{p: v[1] for p, v in self.proof.items()},
                                    "locale/ui_ja.json": self.ja_raw})
        return {"raw": dict(self.raw), "evidence": {"synthetic": True}}

    def _admission(self):
        self.trace.append("admission")
        return CURRENT_SOURCE_ERRORS()

    def _font(self, name, raw):
        self.trace.append(name)
        self.assertIsNotNone(receipts._ACTIVE_PROOF.get())
        self.assertIsNotNone(receipts._ACTIVE_CURRENT.get())
        # Identity inverse is a spy only, never historical font proof evidence.
        return raw

    def _clean(self):
        self.assertIsNone(receipts._ACTIVE_PROOF.get())
        self.assertIsNone(receipts._ACTIVE_CURRENT.get())
        self.assertEqual(self.previous_depth, 0)

    def _run(self):
        before = copy.deepcopy(self.claims)
        result = chapter1._audited_source_snapshot_errors(self.claims)
        self.assertEqual(self.claims, before)
        return result

    def test_actual_delegate_three_outer_reads_become_one_same_result(self):
        before = copy.deepcopy(self.claims)
        old_errors = OLD_DELEGATE(self.claims)
        self.assertEqual(old_errors, [])
        self.assertEqual(self.read.call_count, 3)
        self.assertEqual(self.current.call_count, 3)
        self.assertEqual(self.trace, ["admission", "read", "read", "job", "read", "aruba"])
        self._clean()
        for spy in (self.read, self.current, self.previous, self.verify,
                    self.admission, self.job_font, self.aruba_font):
            spy.reset_mock()
        self.trace.clear()
        self.assertEqual(self._run(), old_errors)
        self.assertEqual(self.claims, before)
        for spy in (self.read, self.current, self.previous, self.verify,
                    self.admission, self.job_font, self.aruba_font, self.body):
            self.assertEqual(spy.call_count, 1)
        self.assertEqual(self.trace, ["read", "admission", "job", "aruba"])
        self._clean()

    def test_267_admission_and_both_comparison_diagnostics_keep_order(self):
        self.claims = {"autoloads/GameState.gd": "invalid-digest", **self.claims}
        self.patch(chapter1.locale_history, "new_run_log_source_errors",
                   return_value=["synthetic ORDER-267 diagnostic"])
        self.admission.side_effect = None
        self.admission.return_value = ["synthetic admission diagnostic"]
        expected = ["synthetic ORDER-267 diagnostic", "synthetic admission diagnostic",
                    "source: audited source digest is not exact SHA-256 autoloads/GameState.gd",
                    "ORDER-365: runtime comparison rejected: ORDER-365: ORDER-372 current admission failed before runtime comparison",
                    "ORDER-365: runtime comparison rejected: ORDER-365: ORDER-377 current admission failed before runtime comparison"]
        self.assertEqual(OLD_DELEGATE(self.claims), expected)
        self.assertEqual(self._run(), expected)
        self.body.assert_called_once_with(self.claims)
        self.job_font.assert_not_called()
        self.aruba_font.assert_not_called()
        self._clean()

    def test_original_error_list_identity_order_duplicates_and_input_preserved(self):
        errors = ["second", "first", "second"]
        self.body.return_value = errors
        self.assertIs(self._run(), errors)
        self.assertEqual(errors, ["second", "first", "second"])
        self.body.assert_called_once_with(self.claims)
        self._clean()

    def test_entry_failure_gathers_delegate_diagnostics_without_mutating_them(self):
        exc = ValueError("synthetic missing Git proof")
        errors = ["267 diagnostic", "admission diagnostic", "comparison diagnostic"]
        self.read.side_effect = exc
        self.body.return_value = errors
        self.assertEqual(self._run(), [PROOF_ERROR + str(exc), *errors])
        self.assertEqual(errors, ["267 diagnostic", "admission diagnostic", "comparison diagnostic"])
        self.body.assert_called_once_with(self.claims)
        self._clean()

    def test_entry_failure_then_successful_real_fallback_cannot_false_pass(self):
        exc = ValueError("synthetic transient first Git failure")
        attempts = 0

        def once():
            nonlocal attempts
            attempts += 1
            if attempts == 1:
                raise exc
            return self._read()

        self.read.side_effect = once
        self.assertEqual(self._run(), [PROOF_ERROR + str(exc)])
        self.body.assert_called_once_with(self.claims)
        self.assertEqual(self.read.call_count, 4)  # failed entry + old admission/two inverses
        self.assertEqual(self.current.call_count, 3)
        self.job_font.assert_called_once()
        self.aruba_font.assert_called_once()
        self._clean()

    def test_exact_first_error_is_not_duplicated_or_reordered(self):
        exc = ValueError("synthetic unavailable proof")
        errors = ["267 diagnostic", PROOF_ERROR + str(exc), "other diagnostic"]
        self.read.side_effect = exc
        self.body.return_value = errors
        self.assertIs(self._run(), errors)
        self.assertEqual(errors, ["267 diagnostic", PROOF_ERROR + str(exc), "other diagnostic"])
        self.body.assert_called_once()
        self._clean()

    def test_all_narrow_entry_exceptions_preserve_first_failure(self):
        failures = (OSError("missing"), ValueError("changed"), KeyError("missing"),
                    TypeError("type"), IndexError("short"), subprocess.TimeoutExpired("git", 1))
        self.body.return_value = []
        for exc in failures:
            with self.subTest(exception=type(exc).__name__):
                self.read.side_effect = exc
                self.body.reset_mock()
                self.assertEqual(self._run(), [PROOF_ERROR + str(exc)])
                self.body.assert_called_once_with(self.claims)
                self._clean()

    def test_unexpected_entry_exception_propagates_without_delegate(self):
        exc = RuntimeError("unexpected proof failure")
        self.read.side_effect = exc
        with self.assertRaises(RuntimeError) as caught:
            self._run()
        self.assertIs(caught.exception, exc)
        self.body.assert_not_called()
        self._clean()

    def test_delegate_exceptions_propagate_once_and_restore_tokens(self):
        for exc in (ValueError("delegate narrow type"), RuntimeError("delegate other type")):
            with self.subTest(exception=type(exc).__name__):
                self.body.reset_mock()
                self.body.side_effect = exc
                with self.assertRaises(type(exc)) as caught:
                    self._run()
                self.assertIs(caught.exception, exc)
                self.body.assert_called_once_with(self.claims)
                self._clean()

    def test_failed_entry_delegate_exception_is_not_retried(self):
        self.read.side_effect = ValueError("entry failure")
        exc = ValueError("delegate failure after entry failure")
        self.body.side_effect = exc
        with self.assertRaises(ValueError) as caught:
            self._run()
        self.assertIs(caught.exception, exc)
        self.read.assert_called_once()
        self.body.assert_called_once_with(self.claims)
        self._clean()

    def test_late_entry_failure_restores_predecessor_before_fallback(self):
        exc = ValueError("synthetic changed HEAD at current-proof admission")
        self.current.side_effect = exc

        def fallback(_claims):
            self._clean()
            return ["delegate diagnostic"]

        self.body.side_effect = fallback
        self.assertEqual(self._run(), [PROOF_ERROR + str(exc), "delegate diagnostic"])
        self.previous.assert_called_once()
        self.body.assert_called_once()
        self._clean()

    def test_exit_exception_is_not_reclassified_or_retried(self):
        exc = ValueError("context exit failure")

        @contextlib.contextmanager
        def broken_exit():
            with self._previous():
                yield
            raise exc

        self.previous.side_effect = broken_exit
        self.body.return_value = []
        with self.assertRaises(ValueError) as caught:
            self._run()
        self.assertIs(caught.exception, exc)
        self.body.assert_called_once()
        self.read.assert_called_once()
        self._clean()

    def test_nested_success_and_exception_keep_both_original_context_objects(self):
        with receipts.fresh_validation_proof():
            proof = receipts._ACTIVE_PROOF.get()
            current = receipts._ACTIVE_CURRENT.get()
            self.assertEqual(self._run(), [])
            self.assertIs(receipts._ACTIVE_PROOF.get(), proof)
            self.assertIs(receipts._ACTIVE_CURRENT.get(), current)
            exc = ValueError("nested delegate failure")
            self.body.side_effect = exc
            with self.assertRaises(ValueError) as caught:
                self._run()
            self.assertIs(caught.exception, exc)
            self.assertIs(receipts._ACTIVE_PROOF.get(), proof)
            self.assertIs(receipts._ACTIVE_CURRENT.get(), current)
            self.assertEqual(self.previous_depth, 1)
            self.read.assert_called_once()
            self.current.assert_called_once()
        self._clean()

    def test_success_then_new_git_failure_then_recovery_has_no_cross_call_cache(self):
        self.body.return_value = []
        self.assertEqual(self._run(), [])
        self._clean()
        exc = OSError("synthetic next invocation missing Git object")
        self.read.side_effect = exc
        self.assertEqual(self._run(), [PROOF_ERROR + str(exc)])
        self._clean()
        self.read.side_effect = self._read
        self.assertEqual(self._run(), [])
        self.assertEqual(self.read.call_count, 3)
        self.assertEqual(self.current.call_count, 2)
        self.assertEqual(self.body.call_count, 3)
        self._clean()

    def test_success_then_new_head_failure_is_fresh(self):
        self.body.return_value = []
        self.assertEqual(self._run(), [])
        exc = ValueError("synthetic next invocation HEAD/raw mismatch")
        self.current.side_effect = exc
        self.assertEqual(self._run(), [PROOF_ERROR + str(exc)])
        self.assertEqual(self.read.call_count, 2)
        self.assertEqual(self.current.call_count, 2)
        self.assertEqual(self.body.call_count, 2)
        self._clean()

    def test_new_current_raw_rejected_and_historical_projection_blocked_then_recovers(self):
        self.assertEqual(self._run(), [])
        path = receipts.UI_PATHS[0]
        original = self.raw[path]
        self.raw[path] = original + b"\n"
        errors = self._run()
        self.assertEqual(errors, [
            "ORDER-365: current proof rejected: ORDER-365: current raw differs from Git " + path,
            "ORDER-365: runtime comparison rejected: ORDER-365: ORDER-372 current admission failed before runtime comparison",
            "ORDER-365: runtime comparison rejected: ORDER-365: ORDER-377 current admission failed before runtime comparison"])
        self.assertEqual(self.job_font.call_count, 1)
        self.assertEqual(self.aruba_font.call_count, 1)
        self._clean()
        self.raw[path] = original
        self.assertEqual(self._run(), [])
        self.assertEqual(self.read.call_count, 3)
        self.assertEqual(self.current.call_count, 3)
        self.assertEqual(self.job_font.call_count, 2)
        self.assertEqual(self.aruba_font.call_count, 2)
        self._clean()

    def test_shared_scope_still_rejects_each_dictionary_and_ledger_raw_mutant(self):
        def body(_claims):
            for path, raw in self.raw.items():
                self.assertEqual(receipts.source_errors(raw, path), [])
                for mutant in (raw + b"\n", b" " + raw, b"historical rollback"):
                    with self.subTest(path=path):
                        self.assertEqual(receipts.source_errors(mutant, path), [
                            "ORDER-365: current proof rejected: ORDER-365: current raw differs from Git " + path])
            return []

        self.body.side_effect = body
        self.assertEqual(self._run(), [])
        self.read.assert_called_once()
        self._clean()

    def test_shared_scope_keeps_each_font_hash_bound_to_submitted_raw(self):
        def body(_claims):
            for path, raw in self.font_raw.items():
                observed, errors = receipts.runtime_observed_hash(
                    path, sha(raw), raw + b"\n", current_admitted=True)
                owner = "ORDER-372" if path == receipts.RUNTIME_PATH else "ORDER-377"
                self.assertEqual(observed, sha(raw))
                self.assertEqual(errors, ["ORDER-365: runtime comparison rejected: ORDER-365: "
                                          + owner + " runtime observation is not bound to current raw"])
            return []

        self.body.side_effect = body
        self.assertEqual(self._run(), [])
        self.job_font.assert_not_called()
        self.aruba_font.assert_not_called()
        self.read.assert_called_once()
        self._clean()


def main() -> int:
    suite = unittest.TestSuite((unittest.defaultTestLoader.loadTestsFromTestCase(PrefixTests),
                               unittest.defaultTestLoader.loadTestsFromTestCase(ScopedControlFlowTests)))
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(suite)
    if not result.wasSuccessful():
        return 1
    print("CHAPTER1_UI_PROOF_REUSE_CHECK_OK "
          f"cases={result.testsRun} prefix=real_git scope=scoped_doubles "
          "outer_reads=3_to_1 immutable_current_admission=separate_normal_required")
    return 0


if __name__ == "__main__":
    sys.exit(main())
