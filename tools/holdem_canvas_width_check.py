#!/usr/bin/env python3
"""Bounded canvas-width admission checks, without an old focused-suite rerun.

One fresh collector supplies its captured pre434 comparison inventory. Git
faults replay real captured responses; manifest cases are synthetic inventories
using real source hashes, not additional whole-project collection claims.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import json
import sys
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import holdem_money_history as history
import ja_translation_pipeline as pipeline
import ja_translation_audit as audit
import main_game_locale_history as main_history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
HOLD = "scenes/HoldemClub.gd"
MAIN = main_history.MAIN_GAME_PATH
SCALP = bridge.SCALPING_PHASE_PATH
ARUBA = bridge.ARUBA_FONT_PATH
CASES: list[str] = []
JA = {"%.1f억": "%.1f億", "%d만": "%d万", "%d원": "%dウォン"}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def rejects(name, operation):
    try:
        operation()
    except (ValueError, OSError):
        pass
    else:
        raise AssertionError(name + ": unexpectedly admitted")
    CASES.append(name)


def census(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def main():
    protected = (HOLD, MAIN, SCALP, ARUBA, *bridge.CURRENT_PATHS,
                 "tools/holdem_money_history.py", "tools/holdem_money_receipt_check.py",
                 "tools/holdem_canvas_width_check.py", "tools/ja_translation_pipeline.py",
                 "tools/ja_translation_audit.py", "tools/ui_translation_append.py",
                 "tools/main_game_locale_history.py", "tools/audit_scope.json")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent canvas pins", history.HOLDEM_PATH == HOLD
          and history.CANVAS_BEFORE_COMMIT == "dc9bc1e0506e88f942eecf53ea2269980175170b"
          and history.CANVAS_AFTER_COMMIT == "bd573a489b125f119dd1b82b318b2619b6eedb78"
          and history.CANVAS_TREES == ("303422eab50417f8b63f5ebae406bf0502247349", "eb22e3974ebdd5c22b7b73b12c056a42dbddc638")
          and history.CANVAS_BLOBS == ("e0721b114ff0546d6b45ecdea429e5134016a074", "51e882f350356e6f6ea0c2c8ba1dd439b3adc273")
          and history.CANVAS_HASHES == ("247701a481721d1ec02672a83086ea8bc48da2b4d12ca34890c795c25ba87c1f",
                                      "892e70e06b2c8ba584d1b37c661308c9aec0463c4674288f21279e8fc75c6bba"))
    history_raw = (ROOT / "tools/holdem_money_history.py").read_bytes()
    prefix = history_raw.split(b"\n\n# BEGIN_HOLDEM_CANVAS_WIDTH_HISTORY_436\n", 1)[0]
    check("old history pipeline audit and focused remain immutable",
          sha(prefix) == "1493bea18de91217b736847c9e4738f68525d55a0b49b23d089f73ad4d633cca"
          and unchanged["tools/ja_translation_pipeline.py"] == "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b"
          and unchanged["tools/ja_translation_audit.py"] == "7c41b636b124d818642f177ad4ec57bd4fa0ac745832844ba3ae79865c7e4e81"
          and unchanged["tools/holdem_money_receipt_check.py"] == "406203ef21558e8b60fb886cb46bcf2a1ae6dfe4db3656aa91dc4057ef990fa1")
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        intermediate, previous = history._holdem_canvas_proof(raw, ROOT)
    requests = (history.BEFORE_COMMIT, history.AFTER_COMMIT, *history.TREES,
                history.BEFORE_COMMIT + ":" + HOLD, history.AFTER_COMMIT + ":" + HOLD,
                history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, *history.CANVAS_TREES,
                history.CANVAS_BEFORE_COMMIT + ":" + HOLD, history.CANVAS_AFTER_COMMIT + ":" + HOLD)
    batch = ("\n".join(requests) + "\n").encode()
    check("real twelve-object batch and three whole raw pins",
          [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and (sha(previous), sha(intermediate)) == history.HASHES
          and (sha(intermediate), sha(raw)) == history.CANVAS_HASHES)
    check("real two transitions intermediate ancestry and current HEAD admission", [args for args, _ in trace] == [
        ("rev-parse", "HEAD"), ("cat-file", "--batch"),
        ("diff", "--name-status", "-z", history.BEFORE_COMMIT, history.AFTER_COMMIT),
        ("diff", "--name-status", "-z", history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT),
        ("merge-base", "--is-ancestor", history.AFTER_COMMIT, history.CANVAS_BEFORE_COMMIT),
        ("merge-base", "--is-ancestor", history.CANVAS_AFTER_COMMIT, "HEAD"),
        ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")])
    old, new = (part.encode() for part in history.CANVAS_REPLACEMENT)
    check("two-line width inverse then full formatter inverse",
          old.count(b"\n") == new.count(b"\n") == 2
          and history.holdem_canvas_inverse(raw, intermediate) == intermediate
          and history.holdem_money_inverse(intermediate, previous) == previous)
    for label, mutant in (("extra edit", raw + b"\n"), ("duplicate", raw + new),
                          ("missing", raw.replace(new, b"", 1)), ("mutable", bytearray(raw)),
                          ("lost centering", raw.replace(b"-text_width * 0.5", b"-24.0", 1))):
        rejects("pure canvas inverse " + label, lambda value=mutant: history.holdem_canvas_inverse(value, intermediate))
    with patch.object(history, "_holdem_canvas_proof", return_value=(intermediate, previous)):
        check("public API returns correct whole predecessor stage",
              history.holdem_canvas_predecessor(raw, ROOT) == intermediate
              and history.holdem_money_predecessor(raw, ROOT) == previous)

    # Capture the old comparison within ONE fresh current collector. Its actual
    # current calls are also compared directly with the immutable434 source.
    baseline_rows, main_rows = [], []
    old_collect, real_main = pipeline._HOLDEM_MONEY_OLD_COLLECT, main_history._log_body_font_proof

    def capture_baseline(contract=None):
        value = old_collect(contract)
        baseline_rows.append(value)
        return value

    def capture_main(value, where=None):
        result = real_main(value, where)
        main_rows.append(result)
        return result

    with patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", side_effect=capture_baseline), \
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main), \
            patch.object(history, "_git", side_effect=traced):
        current = pipeline.collect_ui_inventory()
    check("one fresh collector and captured comparison", not current.errors and len(baseline_rows) == 1
          and not baseline_rows[0].errors and bool(main_rows))
    baseline = baseline_rows[0]
    intermediate_calls, errors = pipeline.parse_ui_calls(HOLD, intermediate.decode())
    intermediate_calls.sort(key=lambda c: (c.path, c.line, c.api))
    check("actual calls and line locations unchanged from434", not errors
          and tuple(c for c in current.calls if c.path == HOLD) == tuple(intermediate_calls))
    retired = set(JA)
    check("only original three calls and keys remain retired", len(baseline.calls) - len(current.calls) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and not any(c.korean in retired for c in current.calls))
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("remaining Entry identities unchanged", tuple(map(identity, current.entries)) ==
          tuple(identity(e) for e in baseline.entries if e.source not in retired))
    check("current counts preserve434 minus3", all(current.stats[k] == baseline.stats[k] - 3 for k in (
        "source_calls", "legacy_calls", "legacy_api_calls", "legacy_keys", "parameter_total_ui_call_occurrences",
        "parameter_legacy_pair_call_occurrences", "parameter_legacy_korean_source_keys")))
    observations, observation_errors = pipeline.collect_ui_parameterized_observations()
    money = [(o.path, o.function) for o in observations if o.state == "money_migrated"]
    check("actual money observations remain three owners", not observation_errors and len(money) == 3
          and money.count((HOLD, "_fmt")) == 1
          and {p for p, _f in money} == {HOLD, "scenes/CommitmentTask.gd", "scenes/SeoulCycleBoard.gd"}
          and current.stats["parameter_money_formatter_migrations"] == 3)
    with patch.object(history, "_git", side_effect=traced):
        retained, errors = audit.holdem_money_retained_ja_entries(current, json.loads((ROOT / "locale/ui_ja.json").read_bytes()))
    check("immutable JA3 remain source-retired and receipt-free", not errors and set(retained) == retired
          and audit.HOLDEM_RETAINED_JA == JA)

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]

    # Fault cases below use memory-replayed Git, never a second claimed real run.
    for label, target, change in (
        ("missing object", ("cat-file",), lambda value: b"missing\n"),
        ("forged payload", ("cat-file",), lambda value: value.replace(b"tree ", b"Tree ", 1)),
        ("trailing bytes", ("cat-file",), lambda value: value + b"x"),
        ("extra434 path", ("diff", "--name-status", "-z", history.BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("extra436 path", ("diff", "--name-status", "-z", history.CANVAS_BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.BLOBS[1].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_canvas_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.AFTER_COMMIT, history.CANVAS_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.CANVAS_AFTER_COMMIT, "HEAD"),
                   ("rev-parse", "HEAD")):
        calls = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                calls[0] += 1
                if target[0] == "merge-base" or calls[0] == 2:
                    raise ValueError("synthetic unavailable ancestry or final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_canvas_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success does not cache next Git fault", lambda: history.holdem_canvas_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery after fault", history._holdem_canvas_proof(raw, ROOT) == (intermediate, previous))
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("actual disk mismatch", lambda: history.holdem_canvas_predecessor(raw, ROOT))
        rejects("old434 bytes cannot pass on current436 disk", lambda: history.holdem_money_predecessor(intermediate, ROOT))

    main_raw, scalp_raw, aruba_raw = ((ROOT / p).read_bytes() for p in (MAIN, SCALP, ARUBA))
    predecessors = main_rows[0]
    check("captured Main history population", len(predecessors) == 12 and all(v == predecessors for v in main_rows))
    scalp_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    aruba_old = bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    middle_hashes, old_hashes = {**hashes, HOLD: sha(intermediate)}, {**hashes, HOLD: sha(previous)}
    views = [hashes, middle_hashes, old_hashes, {**old_hashes, MAIN: sha(predecessors[0])}]
    views += [{**old_hashes, MAIN: sha(value), SCALP: sha(scalp_old)} for value in predecessors]
    views += [{**views[-1], ARUBA: sha(aruba_old)}]
    allowed = {bridge.exchange.digest(v) for v in views}
    source = census(hashes)
    preserved = copy.deepcopy(source)
    check("seventeen distinct actual history tuples", len(views) == len(allowed) == 17)

    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result

    with patch.object(history, "_git", side_effect=replay), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, predecessors, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits all seventeen real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, HOLD: hold_sha, MAIN: main_sha, SCALP: scalp_sha, ARUBA: aruba_sha})
                    for hold_sha, main_sha, scalp_sha, aruba_sha in itertools.product(
                        (sha(raw), sha(intermediate)), tuple(map(sha, (main_raw, *predecessors))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic new and intermediate Cartesian phantoms rejected", len(phantoms) == 102
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned source and unknown manifest rejected",
              not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
              and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current digest", lambda: bridge._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        for label, stale in (("intermediate434", middle_hashes), ("pre434", old_hashes)):
            rejects("stale current census " + label, lambda value=stale: bridge._source_manifest_matches(ROOT, census(value), bridge.exchange.digest(value)))
    check("synthetic supplied census not mutated", source == preserved)

    # The unchanged outer current_proof is exercised against436 raw; its old
    # core is explicitly a double, not an execution claim for that old suite.
    head = "f" * 40
    result = {**source, "evidence": {"head": head}}
    def admission(raws=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=raws or (raw, raw)), \
                patch.object(history, "holdem_money_predecessor", return_value=previous), \
                patch.object(bridge, "_git", side_effect=heads or (head.encode(), head.encode())), \
                patch.object(bridge, "_HOLDEM_MONEY_OLD_CURRENT_PROOF", return_value=result):
            return bridge.current_proof(ROOT, "synthetic baseline", {})
    check("current436 outer proof retains core result", admission() is result)
    rejects("current436 source reread mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("current436 HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    check("protected sources dictionaries receipts and tools unchanged", all(sha((ROOT / p).read_bytes()) == value for p, value in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_CANVAS_WIDTH_CHECK_OK cases={len(CASES)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
