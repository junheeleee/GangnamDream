#!/usr/bin/env python3
"""Bounded Holdem-money proof, current census and retained-JA regression checks.

One fresh current collector supplies its captured comparison inventory. Git
faults replay captured immutable responses; manifest cases use a synthetic
census containing real source hashes, not a second whole-project collection.
No old focused suite, engine, checkout, receipt write or source write is run.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import json
import sys
from dataclasses import replace
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
PAIRS = (("%.1f억", "₩%.1fB"), ("%d만", "₩%dK"), ("%d원", "₩%d"))
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
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py",
                 "tools/ui_translation_append.py", "tools/main_game_locale_history.py",
                 "tools/audit_scope.json", "tools/log_body_font_receipt_check.py")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent product pins", history.HOLDEM_PATH == HOLD and history.RETIRED_PAIRS == PAIRS
          and history.BEFORE_COMMIT == "373aef46b10d3a39485b0f545618ae9da998b94b"
          and history.AFTER_COMMIT == "265119c8ff87f3c3fe8d2d3d2a1692bea5bed4b1"
          and history.TREES == ("a29429ba0ef2b6ca39a5ae086649d0169f15b01a", "d115ba581c6213c89d2a71ca644403f74cd3bf8b")
          and history.BLOBS == ("a8d8ba57ac3a0566234eaa90d2ff6c09ee4e2f49", "e0721b114ff0546d6b45ecdea429e5134016a074")
          and history.HASHES == ("62981d4f2a45b20e068da7462e3452c432e6c009a9c02a16719de4cb84312d90",
                                 "247701a481721d1ec02672a83086ea8bc48da2b4d12ca34890c795c25ba87c1f"))
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        previous = history.holdem_money_predecessor(raw, ROOT)
    requests = (history.BEFORE_COMMIT, history.AFTER_COMMIT, *history.TREES,
                history.BEFORE_COMMIT + ":" + HOLD, history.AFTER_COMMIT + ":" + HOLD)
    batch = ("\n".join(requests) + "\n").encode()
    check("real six-object batch and raw pins", [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and (sha(previous), sha(raw)) == history.HASHES)
    check("real only-path ancestry and current HEAD admission", [args for args, _ in trace] == [
        ("rev-parse", "HEAD"), ("cat-file", "--batch"),
        ("diff", "--name-status", "-z", history.BEFORE_COMMIT, history.AFTER_COMMIT),
        ("merge-base", "--is-ancestor", history.AFTER_COMMIT, "HEAD"),
        ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")])
    old, new = (part.encode() for part in history.FMT_REPLACEMENT)
    check("independent entire formatter and pure inverse", new == b'func _fmt(amount) -> String:\n\treturn LocaleManager.format_whole_won(int(amount))\n'
          and raw.replace(new, old, 1) == previous and history.holdem_money_inverse(raw, previous) == previous)
    for label, mutant in (("extra edit", raw + b"\n"), ("duplicate", raw + new),
                          ("missing", raw.replace(new, b"", 1)), ("mutable", bytearray(raw)),
                          ("missing int cast", raw.replace(b"format_whole_won(int(amount))", b"format_whole_won(amount)", 1))):
        rejects("pure inverse " + label, lambda value=mutant: history.holdem_money_inverse(value, previous))

    # Capture the saved comparison inventory during ONE fresh live collection;
    # neither it nor the expensive Main proof is rerun for synthetic cases.
    baseline_rows, main_rows = [], []
    old_collect = pipeline._HOLDEM_MONEY_OLD_COLLECT
    real_main = main_history._log_body_font_proof

    def capture_baseline(contract=None):
        result = old_collect(contract)
        baseline_rows.append(result)
        return result

    def capture_main(value, where=None):
        result = real_main(value, where)
        main_rows.append(result)
        return result

    with patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", side_effect=capture_baseline), \
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main), \
            patch.object(history, "_git", side_effect=traced):
        current = pipeline.collect_ui_inventory()
    check("fresh current collector and single saved delegate", not current.errors and len(baseline_rows) == 1
          and not baseline_rows[0].errors and bool(main_rows))
    baseline = baseline_rows[0]
    before_calls = tuple(c for c in baseline.calls if c.path == HOLD)
    actual_calls = tuple(c for c in current.calls if c.path == HOLD)
    retired = set(JA)
    check("actual three calls and three unique keys retired", len(baseline.calls) - len(current.calls) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and not any(c.korean in retired for c in current.calls)
          and tuple(c for c in before_calls if c.korean not in retired) == actual_calls)
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("every remaining Entry identity preserved", tuple(map(identity, current.entries)) ==
          tuple(identity(e) for e in baseline.entries if e.source not in retired))
    check("actual census counts minus3", all(current.stats[k] == baseline.stats[k] - 3 for k in (
        "source_calls", "legacy_calls", "legacy_api_calls", "legacy_keys", "parameter_total_ui_call_occurrences",
        "parameter_legacy_pair_call_occurrences", "parameter_legacy_korean_source_keys")))
    observations, observation_errors = pipeline.collect_ui_parameterized_observations()
    money = [(o.path, o.function) for o in observations if o.state == "money_migrated"]
    check("actual observation adds one money owner", not observation_errors and len(money) == 3
          and money.count((HOLD, "_fmt")) == 1
          and {p for p, _f in money} == {HOLD, "scenes/CommitmentTask.gd", "scenes/SeoulCycleBoard.gd"}
          and baseline.stats["parameter_money_formatter_migrations"] == 2
          and current.stats["parameter_money_formatter_migrations"] == 3)
    ja_actual = json.loads((ROOT / "locale/ui_ja.json").read_bytes())
    with patch.object(history, "_git", side_effect=traced):
        retained, errors = audit.holdem_money_retained_ja_entries(current, ja_actual)
        pipeline_previous = pipeline.holdem_money_pipeline_predecessor((ROOT / "tools/ja_translation_pipeline.py").read_bytes())
    check("immutable original JA3 retained and receipt-free", not errors and set(retained) == retired
          and audit.HOLDEM_RETAINED_JA == JA and audit.HOLDEM_RETAINED_JA_BLOB == "750f9692b662082d93214318c743d3eccd102249")
    check("collector predecessor remains byte-identical", sha(pipeline_previous) == "55a3b65670765fdf8aedb75e78fbbd94b0306e97f873c5e4a8580b9e171e9e27")

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]

    # These are memory-replayed Git fault cases, not additional real Git runs.
    for label, prefix, change in (
        ("missing object", ("cat-file",), lambda value: b"missing\n"),
        ("forged object payload", ("cat-file",), lambda value: value.replace(b"tree ", b"Tree ", 1)),
        ("trailing object bytes", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff",), lambda value: value + b"M\0neighbor.gd\0"),
        ("wrong HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, target=prefix, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(target)] == target else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_money_predecessor(raw, ROOT))
    for target in (("merge-base",), ("rev-parse", "HEAD")):
        calls = [0]
        def unavailable(where, *args, **kwargs):
            if args[:len(target)] == target:
                calls[0] += 1
                if target == ("merge-base",) or calls[0] == 2:
                    raise ValueError("synthetic unavailable or changed HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_money_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success cannot cache away next Git failure", lambda: history.holdem_money_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery after fault", history.holdem_money_predecessor(raw, ROOT) == previous)
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("current disk bytes mismatch", lambda: history.holdem_money_predecessor(raw, ROOT))
        with patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", return_value=replace(baseline, calls=tuple(c for c in baseline.calls if c.path != HOLD))):
            check("supplied stale collector cannot be admitted", bool(pipeline.collect_ui_inventory().errors))

    main_raw, scalp_raw, aruba_raw = ((ROOT / p).read_bytes() for p in (MAIN, SCALP, ARUBA))
    predecessors = main_rows[0]
    check("captured Main history population stable", len(predecessors) == 12 and all(v == predecessors for v in main_rows))
    scalp_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    aruba_old = bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    old_hashes = {**hashes, HOLD: sha(previous)}
    views = [hashes, old_hashes, {**old_hashes, MAIN: sha(predecessors[0])}]
    views += [{**old_hashes, MAIN: sha(value), SCALP: sha(scalp_old)} for value in predecessors]
    views += [{**views[-1], ARUBA: sha(aruba_old)}]
    allowed = {bridge.exchange.digest(v) for v in views}
    source = census(hashes)
    preserved = copy.deepcopy(source)
    check("sixteen actual history tuples", len(views) == len(allowed) == 16)

    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result

    with patch.object(history, "_git", side_effect=replay), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, predecessors, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits all sixteen real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main_sha, SCALP: scalp_sha, ARUBA: aruba_sha})
                    for main_sha, scalp_sha, aruba_sha in itertools.product(
                        tuple(map(sha, (main_raw, *predecessors))), (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic new-Holdem Cartesian phantoms rejected", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned source and unknown manifest rejected", not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
              and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current digest", lambda: bridge._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        rejects("old Holdem cannot masquerade as current census", lambda: bridge._source_manifest_matches(ROOT, census(old_hashes), bridge.exchange.digest(old_hashes)))
    check("manifest census untouched", source == preserved)

    # Only the new outer current_proof wrapper is targeted; the old core is a
    # labelled double, not a claimed execution of its collector/history suite.
    head = "f" * 40
    result = {**source, "evidence": {"head": head}}
    def admission(value=None, raws=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=raws or (raw, raw)), \
                patch.object(history, "holdem_money_predecessor", return_value=previous), \
                patch.object(bridge, "_git", side_effect=heads or (head.encode(), head.encode())), \
                patch.object(bridge, "_HOLDEM_MONEY_OLD_CURRENT_PROOF", return_value=result if value is None else value):
            return bridge.current_proof(ROOT, "synthetic baseline", {})
    check("outer current proof preserves core result", admission() is result)
    rejects("outer source reread mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("outer HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    rejects("inner HEAD mismatch", lambda: admission({**result, "evidence": {"head": "0" * 40}}))
    rejects("returned stale source census", lambda: admission({**census(old_hashes), "evidence": {"head": head}}))

    ledger = json.loads((ROOT / bridge.LEDGER_PATH).read_bytes())
    with patch.object(history, "_git", side_effect=replay):
        for key in JA:
            missing = dict(ja_actual); missing.pop(key)
            changed = {**ja_actual, key: JA[key] + "!"}
            check("retained JA missing/changed rejected " + key, all(audit.holdem_money_retained_ja_entries(current, value)[1] for value in (missing, changed)))
            leaf = "ui:" + key + ":/" + key.replace("~", "~0").replace("/", "~1")
            results = []
            for locale in ("ja", "zh-CN", "zh-TW"):
                fault_ledger = {**ledger, "accepted": {**ledger["accepted"], locale: {**ledger["accepted"][locale], leaf: {"synthetic": True}}}}
                with patch.object(audit, "read_json", return_value=fault_ledger):
                    results.append(bool(audit.holdem_money_retained_ja_entries(current, ja_actual)[1]))
            check("retired receipt rejected in every locale " + key, all(results))
        live = replace(current, calls=(*current.calls, next(c for c in before_calls if c.korean in retired)))
        check("retained source cannot remain live", bool(audit.holdem_money_retained_ja_entries(live, ja_actual)[1]))
    check("protected source dictionaries receipts and tools unchanged", all(sha((ROOT / p).read_bytes()) == value for p, value in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_MONEY_RECEIPT_CHECK_OK cases={len(CASES)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
