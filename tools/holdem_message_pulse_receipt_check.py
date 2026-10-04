#!/usr/bin/env python3
"""Exact message-pulse source admission; no engine or historical focused execution.

One real six-stage proof and one fresh collector provide current evidence.
Git faults replay captured responses; manifest cases use synthetic censuses
with actual raw hashes. The separate rendered probe owns message readability.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import sys
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import holdem_money_history as history
import ja_translation_pipeline as pipeline
import main_game_locale_history as main_history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
HOLD = "scenes/HoldemClub.gd"
MAIN = main_history.MAIN_GAME_PATH
SCALP = bridge.SCALPING_PHASE_PATH
ARUBA = bridge.ARUBA_FONT_PATH
CASES: list[str] = []


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
    frozen = {
        "tools/holdem_money_receipt_check.py": "406203ef21558e8b60fb886cb46bcf2a1ae6dfe4db3656aa91dc4057ef990fa1",
        "tools/holdem_canvas_width_check.py": "7e0c9d65ca9122a2f96522c14be4d592743317dec7dfa765506ac99897556453",
        "tools/holdem_betting_receipt_check.py": "338985d15c4b69f52a3cdb18bd47b99e35f7eeb32f6119f066493d0ba8476d69",
        "tools/holdem_async_receipt_check.py": "0d1300dd73ef79b61dccbdaa906b8638c78cfc3b016a7905515069237408cdfc",
        "tools/holdem_card_color_receipt_check.py": "5f766e5c2f36d21586fef3c51255b7ce2a4f708a9d573dc447b3a05839e505b8",
        "tools/ja_translation_pipeline.py": "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b",
        "tools/ja_translation_audit.py": "7c41b636b124d818642f177ad4ec57bd4fa0ac745832844ba3ae79865c7e4e81",
    }
    protected = (HOLD, MAIN, SCALP, ARUBA, *bridge.CURRENT_PATHS, *frozen,
                 "systems/TexasHoldem.gd", "assets/ui/card_front_base.svg",
                 "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/main_game_locale_history.py", "tools/audit_scope.json",
                 "tools/holdem_message_pulse_receipt_check.py")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent message-pulse product pins", history.HOLDEM_PATH == HOLD
          and history.MESSAGE_PULSE_BEFORE_COMMIT == "251f5d98af29b7e2864864ca28a28eacaf17a9e2"
          and history.MESSAGE_PULSE_AFTER_COMMIT == "9dc812d11e54cd34ed45376513753d0cda8b12fa"
          and history.MESSAGE_PULSE_TREES == ("cbdf176f8c41b13db861205beb330400652f616f", "2a7669b34c72b8ef614d1aa3e878a7b133247885")
          and history.MESSAGE_PULSE_BLOBS == ("1485a4e883457e45ae7dd9f2b9d0905265dc5dd0", "6b1e43f4547be5aa8f2aae54b3f730c40f7d437c")
          and history.MESSAGE_PULSE_HASHES == ("5529f970bd5f9a494d048ebc10a3440dffdc388e93f25777d6e4d5c5b70c9bdb",
                                          "cfc4987793e22738d8d7474f8cb821c072276e6d8c9390cf05ff5f1ef2a68ee4"))
    prefix = (ROOT / "tools/holdem_money_history.py").read_bytes().split(
        b"\n\n# BEGIN_HOLDEM_MESSAGE_PULSE_HISTORY_443\n", 1)[0]
    check("entire old history and old focused pins preserved", len(prefix.splitlines()) == 660
          and sha(prefix) == "0a19dad4e34070c50897c877507343c7cc4a2d0c550032f4047593d934466e08"
          and all(unchanged[path] == digest for path, digest in frozen.items()))
    append_prefix = (ROOT / "tools/ui_translation_append.py").read_bytes().split(
        b"\n\n# BEGIN_HOLDEM_MESSAGE_PULSE_APPEND_443\n", 1)[0]
    check("entire previous append implementation preserved", len(append_prefix.splitlines()) == 1930
          and sha(append_prefix) == "8e8d29e7ed8394735fde273d3be42245782157eac5dd2f2c04b395116212aa40")
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        predecessors = history._holdem_message_pulse_proof(raw, ROOT)
    card_color, asynchronous, betting, canvas, money, previous = predecessors
    stages = ((history.BEFORE_COMMIT, history.AFTER_COMMIT, history.TREES, history.HASHES),
              (history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, history.CANVAS_TREES, history.CANVAS_HASHES),
              (history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT, history.BETTING_TREES, history.BETTING_HASHES),
              (history.ASYNC_BEFORE_COMMIT, history.ASYNC_AFTER_COMMIT, history.ASYNC_TREES, history.ASYNC_HASHES),
              (history.CARD_COLOR_BEFORE_COMMIT, history.CARD_COLOR_AFTER_COMMIT, history.CARD_COLOR_TREES, history.CARD_COLOR_HASHES),
              (history.MESSAGE_PULSE_BEFORE_COMMIT, history.MESSAGE_PULSE_AFTER_COMMIT, history.MESSAGE_PULSE_TREES, history.MESSAGE_PULSE_HASHES))
    requests = tuple(request for before, after, trees, _hashes in stages
                     for request in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronological = (previous, money, canvas, betting, asynchronous, card_color, raw)
    check("real thirty-six-object batch and all seven raw states", len(requests) == 36
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronological[i]), sha(chronological[i + 1])) == stage[3]
                  for i, stage in enumerate(stages)))
    expected = [("rev-parse", "HEAD"), ("cat-file", "--batch")]
    for index, (before, after, _trees, _hashes) in enumerate(stages):
        expected.append(("diff", "--name-status", "-z", before, after))
        if index:
            expected.append(("merge-base", "--is-ancestor", stages[index - 1][1], before))
    expected += [("merge-base", "--is-ancestor", history.MESSAGE_PULSE_AFTER_COMMIT, "HEAD"),
                 ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")]
    check("real six transitions and current HEAD binding", [args for args, _ in trace] == expected)
    replacements = (
        (b'\t\t\t_pulse_node(_msg_lbl, 1.04, 0.18)\n', b'\t\t\t# Keep full-width action text inside the clipping viewport.\n'),
        (b'\t_pulse_node(_msg_lbl, 1.08, 0.30)\n', b'\t# Keep full-width showdown text inside the clipping viewport.\n'),
    )
    check("independent two-line inverse and exact whole predecessor",
          history.MESSAGE_PULSE_REPLACEMENTS == tuple(tuple(v.decode() for v in pair) for pair in replacements)
          and raw.count(b"\n") == card_color.count(b"\n")
          and history.holdem_message_pulse_inverse(raw, card_color) == card_color)
    mutants = [("extra edit", raw + b"\n"), ("mutable bytes", bytearray(raw))]
    for i, (old, new) in enumerate(replacements):
        mutants += [(f"duplicate {i}", raw + new), (f"missing {i}", raw.replace(new, b"", 1)),
                    (f"unrepaired {i}", raw.replace(new, old, 1)),
                    (f"partial comment {i}", raw.replace(new, new.replace(b"clipping", b"different"), 1)),
                    (f"line count {i}", raw.replace(new, new.rstrip(b"\n"), 1))]
    for label, mutant in mutants:
        rejects("pure message-pulse inverse " + label, lambda value=mutant: history.holdem_message_pulse_inverse(value, card_color))
    with patch.object(history, "_holdem_message_pulse_proof", return_value=predecessors):
        check("six public predecessor meanings", tuple(function(raw, ROOT) for function in (
            history.holdem_message_pulse_predecessor, history.holdem_card_color_predecessor, history.holdem_async_predecessor,
            history.holdem_betting_predecessor, history.holdem_canvas_predecessor,
            history.holdem_money_predecessor)) == predecessors)
    with patch.object(history, "MESSAGE_PULSE_TREES", (history.MESSAGE_PULSE_TREES[0],)), \
            patch.object(history, "_git", side_effect=AssertionError("malformed descriptor reached Git")):
        rejects("new pin pair cannot silently truncate", lambda: history.holdem_message_pulse_predecessor(raw, ROOT))

    baseline_rows, main_rows = [], []
    old_collect, real_main = pipeline._HOLDEM_MONEY_OLD_COLLECT, main_history._log_body_font_proof
    def capture_baseline(contract=None):
        result = old_collect(contract)
        baseline_rows.append(result)
        return result
    def capture_main(value, where=None):
        result = real_main(value, where)
        main_rows.append(result)
        return result
    with patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", side_effect=capture_baseline), \
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one fresh current collector", not current.errors and len(baseline_rows) == 1
          and not baseline_rows[0].errors and bool(main_rows))
    views = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (card_color, raw)]
    calls = [tuple(sorted(rows, key=lambda c: (c.path, c.line, c.api))) for rows, _errors in views]
    check("all sixty-one UiCall tuples and coordinates unchanged", len(calls[0]) == 61
          and all(not errors for _rows, errors in views) and calls[0] == calls[1]
          and tuple(c for c in current.calls if c.path == HOLD) == calls[0])
    baseline = baseline_rows[0]
    retired = {ko for ko, _en in history.RETIRED_PAIRS}
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("all surviving Entry identities and formatter census unchanged",
          len(baseline.calls) - len(current.calls) == 3 and len(retired) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and tuple(map(identity, current.entries)) == tuple(identity(e) for e in baseline.entries if e.source not in retired)
          and current.stats["parameter_money_formatter_migrations"] == 3)

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]
    real_parse = pipeline.parse_ui_calls
    for field in ("line", "function"):
        def distorted(path, text, name=field):
            rows, errors = real_parse(path, text)
            if path == HOLD and text == raw.decode():
                rows = list(rows)
                value = getattr(rows[0], name)
                rows[0] = replace(rows[0], **{name: value + (1 if name == "line" else "_wrong")})
            return rows, errors
        with patch.object(history, "_git", side_effect=replay), patch.object(pipeline, "parse_ui_calls", side_effect=distorted):
            rejects("collector rejects forged " + field, lambda: pipeline._holdem_money_call_views(raw))
    # These faults replay the one captured Git proof; they are not extra Git runs.
    for label, target, change in (
        ("missing object", ("cat-file",), lambda value: b"missing\n"),
        ("forged object", ("cat-file",), lambda value: value.replace(b"tree ", b"Tree ", 1)),
        ("trailing bytes", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.MESSAGE_PULSE_BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.ASYNC_BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.CARD_COLOR_AFTER_COMMIT, history.MESSAGE_PULSE_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.MESSAGE_PULSE_AFTER_COMMIT, "HEAD"), ("rev-parse", "HEAD")):
        seen = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                seen[0] += 1
                if target[0] == "merge-base" or seen[0] == 2:
                    raise ValueError("synthetic unavailable ancestry or final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success cannot cache the next failure", lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery", history._holdem_message_pulse_proof(raw, ROOT) == predecessors)
        with patch.object(history, "holdem_message_pulse_inverse", return_value=raw):
            rejects("stage loop rejects wrong inverse result", lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("initial disk mismatch", lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("final disk mismatch", lambda: history.holdem_message_pulse_predecessor(raw, ROOT))
        rejects("old441 raw cannot pass on443 disk", lambda: history.holdem_money_predecessor(card_color, ROOT))

    main_raw, scalp_raw, aruba_raw = ((ROOT / path).read_bytes() for path in (MAIN, SCALP, ARUBA))
    main_previous = main_rows[0]
    check("captured Main history population", len(main_previous) == 12
          and all(value == main_previous for value in main_rows))
    scalp_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    aruba_old = bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    hold_views = [{**hashes, HOLD: sha(value)} for value in (raw, *predecessors)]
    views = [*hold_views, {**hold_views[-1], MAIN: sha(main_previous[0])}]
    views += [{**hold_views[-1], MAIN: sha(value), SCALP: sha(scalp_old)} for value in main_previous]
    views += [{**views[-1], ARUBA: sha(aruba_old)}]
    allowed = {bridge.exchange.digest(value) for value in views}
    source = census(hashes)
    preserved = copy.deepcopy(source)
    check("twenty-one distinct actual history tuples", len(views) == len(allowed) == 21)
    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result
    with patch.object(history, "_holdem_message_pulse_proof", side_effect=lambda value, where=None: bound(value, raw, predecessors, where)), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, main_previous, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits twenty-one real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, HOLD: h, MAIN: m, SCALP: s, ARUBA: a})
                    for h, m, s, a in itertools.product(tuple(map(sha, (raw, card_color, asynchronous, betting, canvas, money))),
                        tuple(map(sha, (main_raw, *main_previous))), (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic later-Holdem phantoms rejected", len(phantoms) == 306
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned source and unknown manifest rejected",
              not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
              and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current digest", lambda: bridge._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        for index, stale in enumerate(hold_views[1:]):
            rejects("stale current census " + str(index), lambda value=stale: bridge._source_manifest_matches(ROOT, census(value), bridge.exchange.digest(value)))
    check("supplied synthetic census untouched", source == preserved)
    head = "f" * 40
    result = {**source, "evidence": {"head": head}}
    def admission(raws=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=raws or (raw, raw)), \
                patch.object(history, "holdem_money_predecessor", return_value=previous), \
                patch.object(bridge, "_git", side_effect=heads or (head.encode(), head.encode())), \
                patch.object(bridge, "_HOLDEM_MONEY_OLD_CURRENT_PROOF", return_value=result):
            return bridge.current_proof(ROOT, "synthetic baseline", {})
    check("current443 outer admission retains core result", admission() is result)
    rejects("current443 outer raw mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("current443 outer HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    check("protected source dictionaries receipts and tools unchanged",
          all(sha((ROOT / path).read_bytes()) == digest for path, digest in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_MESSAGE_PULSE_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
