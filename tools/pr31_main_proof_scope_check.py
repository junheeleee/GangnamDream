#!/usr/bin/env python3
"""Real-Git Main proof reuse; explicit mocked negatives, no repository writes."""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys
from unittest.mock import patch

import main_game_locale_history as history


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    raw = (ROOT / history.MAIN_GAME_PATH).read_bytes()
    module_raw = Path(history.__file__).read_bytes()
    original_code = history._MAIN_SCOPE_ORIGINAL_PROOF.__code__
    original_profile = sys.getprofile()
    calls = 0
    cases = 0
    failures: list[str] = []
    mocked_negatives: list[str] = []

    def profile(frame, event, arg):
        nonlocal calls
        if event == "call" and frame.f_code is original_code:
            calls += 1

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def reject(label, callback, *, mocked=False):
        nonlocal cases
        cases += 1
        if mocked:
            mocked_negatives.append(label)
        try:
            callback()
        except (ValueError, OSError):
            return
        failures.append(label + ": did not reject")

    def read():
        return history._ending_father_proof(raw, ROOT)

    def nested_wrong_root():
        with history.fresh_main_validation_proof(ROOT / ".git"):
            pass

    real_run = subprocess.run

    def altered_git(ref=None, *, missing_objects=False):
        def run(command, *args, **kwargs):
            if missing_objects and tuple(command[2:]) == ("cat-file", "--batch"):
                return subprocess.CompletedProcess(command, 1, b"", b"mocked missing Git object")
            result = real_run(command, *args, **kwargs)
            if tuple(command[2:]) == ("rev-parse", "--verify", ref):
                result.stdout = b"0" * 40 + b"\n"
            return result
        return run

    try:
        sys.setprofile(profile)
        first = read()
        check(read() == first and len(first) == 14 and calls == 2,
              "standalone calls each execute the real full proof")
        before = calls
        with history.fresh_main_validation_proof(ROOT):
            scoped = read()
            check(scoped == first and calls == before + 1, "first scoped call is a real proof")
            check(history._investment_ap_proof(raw, ROOT) == scoped[1:]
                  and history.modal_font_predecessor(raw, ROOT) == scoped[-1]
                  and calls == before + 1, "predecessor APIs reuse only immutable results")
            with history.fresh_main_validation_proof(ROOT):
                check(read() is scoped and calls == before + 1, "nested same-root scope reuses proof")

            reject("different current raw", lambda: history._ending_father_proof(raw + b"\n", ROOT))
            reject("different root", lambda: history._ending_father_proof(raw, ROOT / ".git"))
            reject("nested different root", nested_wrong_root)
            with patch.object(history, "ENDING_FATHER_HASHES", ("0" * 64, history.ENDING_FATHER_HASHES[1])):
                reject("mocked literal pin mutation", read, mocked=True)
            with patch.object(history, "AP_COPY_OWNERS", ("wrong-owner", *history.AP_COPY_OWNERS[1:])):
                reject("mocked transitive inverse literal mutation", read, mocked=True)
            with patch.object(history, "ending_father_inverse", lambda current, before: before):
                reject("mocked inverse function identity mutation", read, mocked=True)
            replacement_code = (lambda current, before: before).__code__
            inverse_function = history.investment_ap_inverse
            inverse_original_code = inverse_function.__code__
            try:
                inverse_function.__code__ = replacement_code
                reject("mocked inverse code mutation", read, mocked=True)
            finally:
                inverse_function.__code__ = inverse_original_code
            with patch.object(history._modal_git, "__kwdefaults__", {"input": b"changed"}):
                reject("mocked helper keyword default mutation", read, mocked=True)
            for ref in ("HEAD^{commit}", "HEAD^{tree}", "HEAD:" + history.MAIN_GAME_PATH):
                with patch.object(subprocess, "run", altered_git(ref)):
                    reject("mocked changed Git binding " + ref, read, mocked=True)
            real_read = Path.read_bytes
            for target, label in ((ROOT / history.MAIN_GAME_PATH, "Main disk"),
                                  (Path(history.__file__).resolve(), "proof module disk")):
                def changed_read(path, selected=target):
                    value = real_read(path)
                    return value + b"\n" if path.resolve() == selected.resolve() else value
                with patch.object(Path, "read_bytes", changed_read):
                    reject("mocked " + label + " drift", read, mocked=True)
            check(read() is scoped and calls == before + 1,
                  "rejected warm mutations never refresh or replace proof")
        check(calls == before + 2 and history._MAIN_INVOCATION_SCOPE.get() is None,
              "successful exit fully reproves Git and clears scope")

        before = calls
        with history.fresh_main_validation_proof(ROOT):
            check(read() == first, "next invocation same values")
        check(calls == before + 2, "next invocation rereads real immutable evidence")

        # The positive above uses real Git throughout. These two exit probes
        # simulate failed Git observations; they do not delete objects or move
        # HEAD, and must not be described as physical repository-mutation tests.
        def exit_probe(*, missing_objects=False):
            observation = None
            try:
                with history.fresh_main_validation_proof(ROOT):
                    read()
                    changed = altered_git(None, missing_objects=True) if missing_objects else altered_git("HEAD^{commit}")
                    observation = patch.object(subprocess, "run", changed)
                    observation.start()
                # The context must raise before reaching here.
            finally:
                if observation is not None:
                    observation.stop()
        for missing, label in ((False, "mocked HEAD drift at exit"),
                               (True, "mocked missing immutable Git object at exit")):
            reject(label, lambda: exit_probe(missing_objects=missing), mocked=True)
            check(history._MAIN_INVOCATION_SCOPE.get() is None, label + " scope cleanup")
    finally:
        sys.setprofile(original_profile)
    check((ROOT / history.MAIN_GAME_PATH).read_bytes() == raw
          and Path(history.__file__).read_bytes() == module_raw,
          "actual Main/proof-module disk bytes preserved")
    print(json.dumps({"check": "PR31_MAIN_PROOF_SCOPE", "cases": cases,
                      "full_proof_calls": calls, "failures": failures,
                      "positive_evidence": "real Git, counted with sys.setprofile",
                      "negative_evidence": "parameter changes and explicitly mocked observations",
                      "mocked_negatives": mocked_negatives}, ensure_ascii=False))
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
