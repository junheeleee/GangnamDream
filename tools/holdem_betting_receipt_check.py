#!/usr/bin/env python3
"""Bounded betting-repair proof and unchanged UI-coordinate admission checks.

One fresh collector supplies its captured comparison inventory. Git faults
replay captured responses; manifest cases use synthetic censuses with real
source hashes. No historical focused suite or engine is imported or executed.
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
                 "tools/holdem_canvas_width_check.py", "tools/holdem_betting_receipt_check.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py",
                 "tools/ui_translation_append.py", "tools/main_game_locale_history.py", "tools/audit_scope.json")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent betting product pins", history.HOLDEM_PATH == HOLD
          and history.BETTING_BEFORE_COMMIT == "8b47d6d6dfcffec9ade6fc5619a4358b9cc69462"
          and history.BETTING_AFTER_COMMIT == "f42861efaaa2f8a219bb7883925766e4ee0e9ce0"
          and history.BETTING_TREES == ("2466bdc7af2f14447597250de8aa21c80e259130", "3848689148de0e84d967904e8bafb78c69cf2b55")
          and history.BETTING_BLOBS == ("51e882f350356e6f6ea0c2c8ba1dd439b3adc273", "ae11e6b873bd621649803637f43d79bc7e89b1d4")
          and history.BETTING_HASHES == ("892e70e06b2c8ba584d1b37c661308c9aec0463c4674288f21279e8fc75c6bba",
                                       "4a8ae2c046e59ab4c2425bbb2270a552c73fbc76398c75079d45179f8748114f"))
    history_raw = (ROOT / "tools/holdem_money_history.py").read_bytes()
    prefix = history_raw.split(b"\n\n# BEGIN_HOLDEM_BETTING_TURN_HISTORY_437\n", 1)[0]
    check("old history pipeline audit and focused bytes preserved",
          sha(prefix) == "0b7e026ac1b548b69cc26456cbf1958578170e5a113cac07f5479efddcf66478"
          and unchanged["tools/ja_translation_pipeline.py"] == "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b"
          and unchanged["tools/ja_translation_audit.py"] == "7c41b636b124d818642f177ad4ec57bd4fa0ac745832844ba3ae79865c7e4e81"
          and unchanged["tools/holdem_money_receipt_check.py"] == "406203ef21558e8b60fb886cb46bcf2a1ae6dfe4db3656aa91dc4057ef990fa1"
          and unchanged["tools/holdem_canvas_width_check.py"] == "7e0c9d65ca9122a2f96522c14be4d592743317dec7dfa765506ac99897556453")
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        canvas, money, previous = history._holdem_betting_proof(raw, ROOT)
    stages = ((history.BEFORE_COMMIT, history.AFTER_COMMIT, history.TREES),
              (history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, history.CANVAS_TREES),
              (history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT, history.BETTING_TREES))
    requests = tuple(request for before, after, trees in stages
                     for request in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    check("real eighteen-object batch and four whole raw pins",
          [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and (sha(previous), sha(money)) == history.HASHES
          and (sha(money), sha(canvas)) == history.CANVAS_HASHES
          and (sha(canvas), sha(raw)) == history.BETTING_HASHES)
    check("real three transitions ancestor links and current HEAD admission", [args for args, _ in trace] == [
        ("rev-parse", "HEAD"), ("cat-file", "--batch"),
        ("diff", "--name-status", "-z", history.BEFORE_COMMIT, history.AFTER_COMMIT),
        ("diff", "--name-status", "-z", history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT),
        ("merge-base", "--is-ancestor", history.AFTER_COMMIT, history.CANVAS_BEFORE_COMMIT),
        ("diff", "--name-status", "-z", history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT),
        ("merge-base", "--is-ancestor", history.CANVAS_AFTER_COMMIT, history.BETTING_BEFORE_COMMIT),
        ("merge-base", "--is-ancestor", history.BETTING_AFTER_COMMIT, "HEAD"),
        ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")])
    suffix = history.BETTING_APPENDIX.encode()
    check("whole betting canvas and formatter inverse chain",
          suffix.count(b"\n") == 26 and len(history.BETTING_REPLACEMENTS) == 10
          and history.holdem_betting_inverse(raw, canvas) == canvas
          and history.holdem_canvas_inverse(canvas, money) == money
          and history.holdem_money_inverse(money, previous) == previous)
    for label, mutant in (
        ("extra edit", raw + b"\n"), ("duplicate appendix", raw + suffix),
        ("missing actor record", raw.replace(b"\t_record_round_action(0, _max_bet > previous_max)\n", b"\n", 1)),
        ("changed pending behavior", raw.replace(b"_round_pending.erase(who)", b"_round_pending.clear()", 1)),
        ("changed UI literal", raw.replace("프리플랍".encode(), "프리플랍!".encode(), 1)),
        ("mutable", bytearray(raw)),
    ):
        rejects("pure betting inverse " + label, lambda value=mutant: history.holdem_betting_inverse(value, canvas))
    with patch.object(history, "_holdem_betting_proof", return_value=(canvas, money, previous)):
        check("three public APIs keep distinct predecessor meanings",
              history.holdem_betting_predecessor(raw, ROOT) == canvas
              and history.holdem_canvas_predecessor(raw, ROOT) == money
              and history.holdem_money_predecessor(raw, ROOT) == previous)

    # One fresh collector, with its existing comparison result captured in situ.
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
    check("one fresh current collector and saved comparison", not current.errors and len(baseline_rows) == 1
          and not baseline_rows[0].errors and bool(main_rows))
    baseline = baseline_rows[0]
    parsed_views = [pipeline.parse_ui_calls(HOLD, source.decode()) for source in (canvas, money, raw)]
    ordered = [tuple(sorted(calls, key=lambda c: (c.path, c.line, c.api))) for calls, _errors in parsed_views]
    check("full actual UiCall tuples including lines unchanged from436 and434",
          all(not errors for _calls, errors in parsed_views) and ordered[0] == ordered[1] == ordered[2]
          and tuple(c for c in current.calls if c.path == HOLD) == ordered[0])
    retired = set(JA)
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("all remaining Entry identities and original retirement preserved",
          len(baseline.calls) - len(current.calls) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and tuple(map(identity, current.entries)) == tuple(identity(e) for e in baseline.entries if e.source not in retired))
    check("unchanged current minus3 counts", all(current.stats[k] == baseline.stats[k] - 3 for k in (
        "source_calls", "legacy_calls", "legacy_api_calls", "legacy_keys", "parameter_total_ui_call_occurrences",
        "parameter_legacy_pair_call_occurrences", "parameter_legacy_korean_source_keys")))
    observations, observation_errors = pipeline.collect_ui_parameterized_observations()
    money_owners = [(o.path, o.function) for o in observations if o.state == "money_migrated"]
    check("actual money observations remain unchanged", not observation_errors and len(money_owners) == 3
          and money_owners.count((HOLD, "_fmt")) == 1
          and current.stats["parameter_money_formatter_migrations"] == 3)
    with patch.object(history, "_git", side_effect=traced):
        retained, errors = audit.holdem_money_retained_ja_entries(current, json.loads((ROOT / "locale/ui_ja.json").read_bytes()))
    check("immutable JA3 remain retired and receipt-free", not errors and set(retained) == retired and audit.HOLDEM_RETAINED_JA == JA)

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]

    # The unchanged collector comparison must still reject even a same-count
    # forged call view. The parser double is limited to this local fault case.
    real_parse = pipeline.parse_ui_calls
    for field, mutate in (("line", lambda value: value + 1), ("english", lambda value: value + "!"),
                          ("function", lambda value: value + "_wrong_owner")):
        def distorted(path, text, name=field, change=mutate):
            calls, errors = real_parse(path, text)
            if path == HOLD and text == raw.decode():
                calls = list(calls)
                calls[0] = replace(calls[0], **{name: change(getattr(calls[0], name))})
            return calls, errors
        with patch.object(history, "_git", side_effect=replay), patch.object(pipeline, "parse_ui_calls", side_effect=distorted):
            rejects("unchanged collector rejects forged " + field, lambda: pipeline._holdem_money_call_views(raw))

    # These faults replay immutable responses; they are not new actual Git runs.
    for label, target, change in (
        ("missing object", ("cat-file",), lambda value: b"missing\n"),
        ("forged payload", ("cat-file",), lambda value: value.replace(b"tree ", b"Tree ", 1)),
        ("trailing bytes", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.BETTING_BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.CANVAS_BLOBS[1].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_betting_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.CANVAS_AFTER_COMMIT, history.BETTING_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.BETTING_AFTER_COMMIT, "HEAD"),
                   ("rev-parse", "HEAD")):
        calls = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                calls[0] += 1
                if target[0] == "merge-base" or calls[0] == 2:
                    raise ValueError("synthetic unavailable ancestry or final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_betting_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success cannot cache the next Git fault", lambda: history.holdem_betting_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery after fault", history._holdem_betting_proof(raw, ROOT) == (canvas, money, previous))
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("current disk mismatch", lambda: history.holdem_betting_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("final source reread mismatch", lambda: history.holdem_betting_predecessor(raw, ROOT))
        for label, stale in (("436", canvas), ("434", money)):
            rejects("old" + label + " bytes cannot pass on437 disk", lambda value=stale: history.holdem_money_predecessor(value, ROOT))

    main_raw, scalp_raw, aruba_raw = ((ROOT / p).read_bytes() for p in (MAIN, SCALP, ARUBA))
    predecessors = main_rows[0]
    check("captured Main history population", len(predecessors) == 12 and all(value == predecessors for value in main_rows))
    scalp_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    aruba_old = bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    canvas_hashes, money_hashes, old_hashes = ({**hashes, HOLD: sha(value)} for value in (canvas, money, previous))
    views = [hashes, canvas_hashes, money_hashes, old_hashes, {**old_hashes, MAIN: sha(predecessors[0])}]
    views += [{**old_hashes, MAIN: sha(value), SCALP: sha(scalp_old)} for value in predecessors]
    views += [{**views[-1], ARUBA: sha(aruba_old)}]
    allowed = {bridge.exchange.digest(value) for value in views}
    source = census(hashes)
    preserved = copy.deepcopy(source)
    check("eighteen distinct actual history tuples", len(views) == len(allowed) == 18)

    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result

    with patch.object(history, "_git", side_effect=replay), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, predecessors, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits all eighteen real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, HOLD: hold_sha, MAIN: main_sha, SCALP: scalp_sha, ARUBA: aruba_sha})
                    for hold_sha, main_sha, scalp_sha, aruba_sha in itertools.product(
                        tuple(map(sha, (raw, canvas, money))), tuple(map(sha, (main_raw, *predecessors))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic later-Holdem Cartesian phantoms rejected", len(phantoms) == 153
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned source and unknown manifest rejected",
              not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
              and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current digest", lambda: bridge._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        for label, stale in (("436", canvas_hashes), ("434", money_hashes), ("373", old_hashes)):
            rejects("stale current census " + label, lambda value=stale: bridge._source_manifest_matches(ROOT, census(value), bridge.exchange.digest(value)))
    check("supplied synthetic census untouched", source == preserved)

    # Only the unchanged outer wrapper is exercised here; its old core is a
    # labelled double, not a claim that an old suite has been executed again.
    head = "f" * 40
    result = {**source, "evidence": {"head": head}}
    def admission(raws=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=raws or (raw, raw)), \
                patch.object(history, "holdem_money_predecessor", return_value=previous), \
                patch.object(bridge, "_git", side_effect=heads or (head.encode(), head.encode())), \
                patch.object(bridge, "_HOLDEM_MONEY_OLD_CURRENT_PROOF", return_value=result):
            return bridge.current_proof(ROOT, "synthetic baseline", {})
    check("current437 outer proof retains core result", admission() is result)
    rejects("current437 outer source reread mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("current437 outer HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    check("protected sources dictionaries receipts and tools unchanged", all(sha((ROOT / p).read_bytes()) == value for p, value in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_BETTING_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
