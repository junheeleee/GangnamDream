#!/usr/bin/env python3
"""Cheap invocation-scope regressions, not Git-proof or Chapter 5 corpus evidence.

The actual receipt context manager, raw admission and normal CLI orchestration
run here. Only expensive proof leaves, the predecessor context, model loading,
and the audit/self-test bodies are doubles. Every patch is invocation-local;
no repository file, historical pin, proof cache or fixture is rewritten.
"""
from __future__ import annotations

import contextlib
import copy
import hashlib
import io
import json
import subprocess
import sys
import unittest
from unittest import mock

import chapter5_human_reject_audit as audit


receipts = audit.ui_receipts
PROOF_ERROR = "ORDER-365: whole current proof rejected: "
FAIL_NOTE = (
    "  NOTE static GREEN cannot close either Chapter 5 human gate; "
    "both exact M49-M60 normal-speed replays remain required\n"
)
NORMAL_OK = (
    "CHAPTER5_HUMAN_REJECT_AUDIT_OK "
    "housing=presentation_only/shared-living-contract/no-old-move-ingress "
    "names=5x-raw-display-ko-en/legacy-gangnam/shared-display-vs-narrative/consumer-split "
    "tutorial=turn1 credits=1of6+beat "
    "timeline=calendar_safe money=dynamic remote=no_copresence/no_fake_reply "
    "scene_context=M54-seven-months/W224-store/casino-message/no-false-recollection "
    "wallet=player_acceptance/mutual-schedule/decline-closes "
    "legacy=bounded/old-flags-preserved sns=detox_bounded "
    "shadow=proposal-terminal/no-fake-agreement "
    "jiyeon=truth-contact-3x-ko-en speakers=hidden_contract/wedding4+custody "
    "instant_legend=preserved ap_surface=public_demo_zero "
    "public_demo=M01-M06/frozen human_gates=pending\n"
)


class ProofScopeTests(unittest.TestCase):
    def setUp(self):
        self.stack = contextlib.ExitStack()
        self.addCleanup(self.stack.close)
        # Isolate this test's context without assuming the caller's context is
        # empty. Cleanup returns the original values even when an assertion fails.
        for variable in (receipts._ACTIVE_PROOF, receipts._ACTIVE_CURRENT):
            token = variable.set(None)
            self.stack.callback(variable.reset, token)
        self.trace = []
        self.previous_depth = 0
        self.model = object()
        self.proof = {p: (b"old:" + p.encode(), b"base:" + p.encode())
                      for p in receipts.CURRENT_PATHS}
        self.raw = {p: json.dumps({"fixture": p, "version": 1}).encode()
                    for p in receipts.ui_append.CURRENT_PATHS}
        self.ja_raw = b'{"fixture":"Japanese baseline"}\n'

        def patch(owner, name, **kwargs):
            return self.stack.enter_context(mock.patch.object(owner, name, **kwargs))

        self.read = patch(receipts, "_read_proof", side_effect=self._read)
        self.verify = patch(receipts, "_verify_transition", side_effect=self._verify)
        self.previous = patch(receipts.previous, "fresh_validation_proof",
                              side_effect=self._previous)
        self.previous_source = patch(receipts.previous, "source_errors", return_value=[])
        self.objects = patch(receipts.ui_append, "_objects", return_value=[self.ja_raw])
        # Synthetic Japanese bytes bind to their real SHA; this replaces a leaf
        # dependency only. Immutable historical constants on disk are untouched.
        patch(receipts, "JA_BASELINE_SHA256",
              new=hashlib.sha256(self.ja_raw).hexdigest())
        self.current = patch(receipts.ui_append, "current_proof", side_effect=self._current)
        self.body = patch(audit, "validate_model", return_value=[])
        self.loader = patch(audit, "_load_model", return_value=self.model)
        self.old_self = patch(audit, "run_self_test", return_value=10)
        self.public_self = patch(audit, "_reviewed_public_source_self_tests", return_value=20)
        self.parser_self = patch(audit, "_order308_parser_source_self_tests", return_value=30)
        # Accidental real Git/proof execution is an immediate test failure.
        patch(subprocess, "run", side_effect=AssertionError("unexpected subprocess in cheap test"))

    def _read(self):
        self.trace.append("read")
        return copy.deepcopy(self.proof)

    def _verify(self, pairs):
        self.trace.append("verify")
        self.assertEqual(pairs, tuple((p, *self.proof[p]) for p in receipts.CURRENT_PATHS))

    @contextlib.contextmanager
    def _previous(self):
        self.trace.append("previous-enter")
        self.previous_depth += 1
        try:
            yield
        finally:
            self.previous_depth -= 1
            self.trace.append("previous-exit")

    def _current(self, root, commit, baseline):
        self.trace.append("current")
        self.assertEqual(root, receipts.ROOT)
        self.assertEqual(commit, receipts.AFTER_COMMIT)
        self.assertEqual(baseline, {**{p: v[1] for p, v in self.proof.items()},
                                    "locale/ui_ja.json": self.ja_raw})
        return {"raw": copy.deepcopy(self.raw), "evidence": {"synthetic": True}}

    def _clean(self):
        self.assertIsNone(receipts._ACTIVE_PROOF.get())
        self.assertIsNone(receipts._ACTIVE_CURRENT.get())
        self.assertEqual(self.previous_depth, 0)

    def _active(self):
        self.assertEqual(receipts._ACTIVE_PROOF.get(), self.proof)
        self.assertEqual(receipts._ACTIVE_CURRENT.get()["raw"], self.raw)
        self.assertEqual(self.previous_depth, 1)

    def _cli(self, args=()):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = audit.main(list(args))
        return code, out.getvalue(), err.getvalue()

    def _entry_error(self, exception):
        self.read.side_effect = exception
        self.assertEqual(audit._validate_current_model(self.model), [PROOF_ERROR + str(exception)])
        self.read.assert_called_once_with()
        self.body.assert_not_called()
        self.current.assert_not_called()
        self._clean()

    def test_reuses_proof_for_four_body_admissions(self):
        def body(model):
            self.assertIs(model, self.model)
            self._active()
            # Match the repeated-admission shape without executing its expensive
            # model validators: all current dictionary/ledger paths use real guards.
            for _ in range(4):
                with receipts.fresh_validation_proof():
                    for path, raw in self.raw.items():
                        self.assertEqual(receipts.source_errors(raw, path), [])
            return []
        self.body.side_effect = body
        self.assertEqual(audit._validate_current_model(self.model), [])
        self.read.assert_called_once_with()
        self.current.assert_called_once()
        self.previous.assert_called_once_with()
        self.verify.assert_called_once()
        self.objects.assert_called_once_with(receipts.ROOT, [
            (receipts.AFTER_COMMIT + ":locale/ui_ja.json", receipts.JA_BASELINE_BLOB, "blob")])
        self.previous_source.assert_called_once_with(self.proof[receipts.LEDGER_PATH][0], receipts.LEDGER_PATH)
        self._clean()

    def test_returns_original_error_list_and_preserves_order(self):
        errors = ["second validator", "first validator", "second validator"]
        def body(_model):
            self._active()
            self.trace.append("validate")
            return errors
        self.body.side_effect = body
        self.assertIs(audit._validate_current_model(self.model), errors)
        self.assertEqual(self.trace, ["read", "previous-enter", "verify", "current", "validate", "previous-exit"])
        self._clean()

    def test_next_invocation_reads_new_proof(self):
        observed = []
        self.body.side_effect = lambda _model: observed.append(copy.deepcopy(receipts._ACTIVE_CURRENT.get()["raw"])) or []
        self.assertEqual(audit._validate_current_model(self.model), [])
        self._clean()
        self.raw = {p: raw + b" " for p, raw in self.raw.items()}
        self.assertEqual(audit._validate_current_model(self.model), [])
        self.assertNotEqual(*observed)
        self.assertEqual(self.read.call_count, 2)
        self.assertEqual(self.current.call_count, 2)
        self._clean()

    def _warm_rejection(self, exception):
        self.assertEqual(audit._validate_current_model(self.model), [])
        self.read.side_effect = exception
        self.assertEqual(audit._validate_current_model(self.model), [PROOF_ERROR + str(exception)])
        self.assertEqual(self.read.call_count, 2)
        self.body.assert_called_once_with(self.model)
        self.current.assert_called_once()
        self._clean()

    def test_success_then_missing_proof_rejected(self):
        self._warm_rejection(OSError("synthetic missing Git object"))

    def test_success_then_altered_proof_rejected(self):
        self._warm_rejection(ValueError("synthetic altered Git object"))

    def test_per_raw_mismatch_rejected_within_shared_scope(self):
        def body(_model):
            for path, raw in self.raw.items():
                for changed in (raw + b"\n", b" " + raw, b"old:" + path.encode()):
                    with self.subTest(path=path, changed=changed):
                        self.assertEqual(receipts.source_errors(changed, path), [
                            "ORDER-365: current proof rejected: ORDER-365: current raw differs from Git " + path])
                self.assertEqual(receipts.source_errors(raw, path), [])
            return []
        self.body.side_effect = body
        self.assertEqual(audit._validate_current_model(self.model), [])
        self.read.assert_called_once_with()
        self.current.assert_called_once()
        self._clean()

    def test_wrong_raw_type_rejected_without_extra_proof(self):
        path = receipts.UI_PATHS[0]
        self.body.side_effect = lambda _model: receipts.source_errors(self.raw[path].decode(), path)
        self.assertEqual(audit._validate_current_model(self.model), [
            "ORDER-365: current source is not raw bytes " + path])
        self.read.assert_called_once_with()
        self._clean()

    def test_nested_invocation_restores_outer_context(self):
        with receipts.fresh_validation_proof():
            proof, current = receipts._ACTIVE_PROOF.get(), receipts._ACTIVE_CURRENT.get()
            self.assertEqual(audit._validate_current_model(self.model), [])
            self.assertIs(receipts._ACTIVE_PROOF.get(), proof)
            self.assertIs(receipts._ACTIVE_CURRENT.get(), current)
            self.assertEqual(self.previous_depth, 1)
        self.read.assert_called_once_with()
        self.current.assert_called_once()
        self._clean()

    def _body_raises(self, exception):
        self.body.side_effect = exception
        with self.assertRaises(type(exception)) as caught:
            audit._validate_current_model(self.model)
        self.assertIs(caught.exception, exception)
        self.body.assert_called_once_with(self.model)
        self.read.assert_called_once_with()
        self.current.assert_called_once()
        self.assertEqual(self.trace[-1], "previous-exit")
        self._clean()

    def test_body_value_error_propagates_and_cleans_up(self):
        self._body_raises(ValueError("programming error, not entry failure"))

    def test_body_unexpected_error_propagates_and_cleans_up(self):
        self._body_raises(RuntimeError("unexpected body failure"))

    def test_late_entry_failure_cleans_previous_context(self):
        exception = ValueError("synthetic current append proof unavailable")
        self.current.side_effect = exception
        self.assertEqual(audit._validate_current_model(self.model), [PROOF_ERROR + str(exception)])
        self.body.assert_not_called()
        self.read.assert_called_once_with()
        self.current.assert_called_once()
        self.assertEqual(self.trace[-1], "previous-exit")
        self._clean()

    def test_entry_os_error(self):
        self._entry_error(OSError("entry OS error"))

    def test_entry_value_error(self):
        self._entry_error(ValueError("entry value error"))

    def test_entry_key_error(self):
        self._entry_error(KeyError("entry missing key"))

    def test_entry_type_error(self):
        self._entry_error(TypeError("entry type error"))

    def test_entry_index_error(self):
        self._entry_error(IndexError("entry index error"))

    def test_entry_timeout(self):
        self._entry_error(subprocess.TimeoutExpired(["git", "synthetic-only"], 30))

    def test_main_normal_success_protocol(self):
        self.assertEqual(self._cli(), (0, NORMAL_OK, ""))
        self.loader.assert_called_once_with()
        self.body.assert_called_once_with(self.model)
        self.read.assert_called_once_with()
        self.old_self.assert_not_called()
        self._clean()

    def test_main_normal_validation_failure_protocol(self):
        self.body.return_value = ["first", "second"]
        self.assertEqual(self._cli(), (1,
            "CHAPTER5_HUMAN_REJECT_AUDIT_FAIL errors=2\n  ERROR first\n  ERROR second\n" + FAIL_NOTE, ""))
        self.body.assert_called_once_with(self.model)
        self.read.assert_called_once_with()
        self._clean()

    def test_main_proof_failure_protocol(self):
        self.read.side_effect = ValueError("missing immutable proof")
        self.assertEqual(self._cli(), (1,
            "CHAPTER5_HUMAN_REJECT_AUDIT_FAIL errors=1\n  ERROR " + PROOF_ERROR + "missing immutable proof\n" + FAIL_NOTE, ""))
        self.body.assert_not_called()
        self.read.assert_called_once_with()
        self._clean()

    def test_main_load_failure_skips_proof(self):
        exceptions = (OSError("missing model"), ValueError("bad model"), json.JSONDecodeError("bad JSON", "x", 0))
        for exception in exceptions:
            with self.subTest(exception=type(exception).__name__):
                self.loader.side_effect = exception
                self.assertEqual(self._cli(), (1, "", "CHAPTER5_HUMAN_REJECT_AUDIT_FAIL load=" + str(exception) + "\n"))
        self.read.assert_not_called()
        self.body.assert_not_called()
        self._clean()

    def test_main_self_test_skips_proof(self):
        self.assertEqual(self._cli(["--self-test"]), (0, "CHAPTER5_HUMAN_REJECT_SELF_TEST_OK cases=60\n", ""))
        self.old_self.assert_called_once_with()
        self.public_self.assert_called_once_with()
        self.parser_self.assert_called_once_with()
        self.loader.assert_not_called()
        self.read.assert_not_called()
        self.body.assert_not_called()
        self._clean()

    def test_main_self_test_failure_skips_proof(self):
        self.old_self.side_effect = AssertionError("self sentinel")
        self.assertEqual(self._cli(["--self-test"]), (1, "", "CHAPTER5_HUMAN_REJECT_SELF_TEST_FAIL self sentinel\n"))
        self.public_self.assert_not_called()
        self.parser_self.assert_not_called()
        self.loader.assert_not_called()
        self.read.assert_not_called()
        self._clean()

    def test_main_body_exception_propagates(self):
        exception = ValueError("body sentinel")
        self.body.side_effect = exception
        with self.assertRaises(ValueError) as caught:
            self._cli()
        self.assertIs(caught.exception, exception)
        self.body.assert_called_once_with(self.model)
        self.read.assert_called_once_with()
        self._clean()

    def test_context_exit_exception_not_reclassified(self):
        exception = ValueError("context exit, not entry")
        @contextlib.contextmanager
        def failing_exit():
            with self._previous():
                yield
            raise exception
        self.previous.side_effect = failing_exit
        with self.assertRaises(ValueError) as caught:
            audit._validate_current_model(self.model)
        self.assertIs(caught.exception, exception)
        self.body.assert_called_once_with(self.model)
        self.read.assert_called_once_with()
        self._clean()


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ProofScopeTests)
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(suite)
    marker = "OK" if result.wasSuccessful() else "FAIL"
    print(f"CHAPTER5_PROOF_SCOPE_SELF_TEST_{marker} cases={result.testsRun}")
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
