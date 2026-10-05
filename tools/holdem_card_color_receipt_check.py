#!/usr/bin/env python3
"""Exact card-ink source admission; no engine or historical focused execution.

One real five-stage proof and one fresh collector provide current evidence.
Git faults replay captured responses; manifest cases use synthetic censuses
with actual raw hashes. The separate rendered probe owns card readability.
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
        "tools/ja_translation_pipeline.py": "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b",
        "tools/ja_translation_audit.py": "7c41b636b124d818642f177ad4ec57bd4fa0ac745832844ba3ae79865c7e4e81",
    }
    protected = (HOLD, MAIN, SCALP, ARUBA, *bridge.CURRENT_PATHS, *frozen,
                 "systems/TexasHoldem.gd", "assets/ui/card_front_base.svg",
                 "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/main_game_locale_history.py", "tools/audit_scope.json",
                 "tools/holdem_card_color_receipt_check.py")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent card-color product pins", history.HOLDEM_PATH == HOLD
          and history.CARD_COLOR_BEFORE_COMMIT == "fe418e336e7296962686949536711a2e6230bd71"
          and history.CARD_COLOR_AFTER_COMMIT == "99aee1b0dc7db01edd2efe33349bc5570847c011"
          and history.CARD_COLOR_TREES == ("e030d0d5ef3c836dcfc426519cdb97fde77954eb", "2c8b3b8691e9cd53e92aaf340e86f6be234413b8")
          and history.CARD_COLOR_BLOBS == ("bf36544000f94319b32ea6b299694a9644c8ebf4", "1485a4e883457e45ae7dd9f2b9d0905265dc5dd0")
          and history.CARD_COLOR_HASHES == ("35c2a7124160bfbab0e9b039aad496d2059131d83222f87eeb12ef344e5a0e5c",
                                          "5529f970bd5f9a494d048ebc10a3440dffdc388e93f25777d6e4d5c5b70c9bdb"))
    prefix = (ROOT / "tools/holdem_money_history.py").read_bytes().split(
        b"\n\n# BEGIN_HOLDEM_CARD_COLOR_HISTORY_441\n", 1)[0]
    check("entire old history and old focused pins preserved", len(prefix.splitlines()) == 579
          and sha(prefix) == "dbc705397d887fff4b9358bfb66c054e48eb042013e37b5ada79e8aa44d4615b"
          and all(unchanged[path] == digest for path, digest in frozen.items()))
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        predecessors = history._holdem_card_color_proof(raw, ROOT)
    asynchronous, betting, canvas, money, previous = predecessors
    stages = ((history.BEFORE_COMMIT, history.AFTER_COMMIT, history.TREES, history.HASHES),
              (history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, history.CANVAS_TREES, history.CANVAS_HASHES),
              (history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT, history.BETTING_TREES, history.BETTING_HASHES),
              (history.ASYNC_BEFORE_COMMIT, history.ASYNC_AFTER_COMMIT, history.ASYNC_TREES, history.ASYNC_HASHES),
              (history.CARD_COLOR_BEFORE_COMMIT, history.CARD_COLOR_AFTER_COMMIT, history.CARD_COLOR_TREES, history.CARD_COLOR_HASHES))
    requests = tuple(request for before, after, trees, _hashes in stages
                     for request in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronological = (previous, money, canvas, betting, asynchronous, raw)
    check("real thirty-object batch and all six raw states", len(requests) == 30
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronological[i]), sha(chronological[i + 1])) == stage[3]
                  for i, stage in enumerate(stages)))
    expected = [("rev-parse", "HEAD"), ("cat-file", "--batch")]
    for index, (before, after, _trees, _hashes) in enumerate(stages):
        expected.append(("diff", "--name-status", "-z", before, after))
        if index:
            expected.append(("merge-base", "--is-ancestor", stages[index - 1][1], before))
    expected += [("merge-base", "--is-ancestor", history.CARD_COLOR_AFTER_COMMIT, "HEAD"),
                 ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")]
    check("real five transitions and current HEAD binding", [args for args, _ in trace] == expected)
    old = b'\tlbl.add_theme_color_override("font_color", Color(TH.card_color(card)))\n'
    new = b'\tlbl.add_theme_color_override("font_color", Color("#b4232c") if int(card["suit"]) in [1, 2] else Color("#141827"))\n'
    check("independent full-line inverse and exact whole predecessor",
          history.CARD_COLOR_REPLACEMENT == (old.decode(), new.decode())
          and raw.count(b"\n") == asynchronous.count(b"\n")
          and history.holdem_card_color_inverse(raw, asynchronous) == asynchronous)
    for label, mutant in (
        ("extra edit", raw + b"\n"), ("duplicate line", raw + new),
        ("wrong red", raw.replace(b"#b4232c", b"#d73939", 1)),
        ("wrong black", raw.replace(b"#141827", b"#e8eaf0", 1)),
        ("wrong suit", raw.replace(new, new.replace(b"[1, 2]", b"[0, 3]"), 1)),
        ("line count", raw.replace(new, new.rstrip(b"\n"), 1)),
        ("mutable bytes", bytearray(raw)),
    ):
        rejects("pure card-color inverse " + label, lambda value=mutant: history.holdem_card_color_inverse(value, asynchronous))
    with patch.object(history, "_holdem_card_color_proof", return_value=predecessors):
        check("five public predecessor meanings", tuple(function(raw, ROOT) for function in (
            history.holdem_card_color_predecessor, history.holdem_async_predecessor,
            history.holdem_betting_predecessor, history.holdem_canvas_predecessor,
            history.holdem_money_predecessor)) == predecessors)
    with patch.object(history, "CARD_COLOR_TREES", (history.CARD_COLOR_TREES[0],)), \
            patch.object(history, "_git", side_effect=AssertionError("malformed descriptor reached Git")):
        rejects("new pin pair cannot silently truncate", lambda: history.holdem_card_color_predecessor(raw, ROOT))

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
    views = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (asynchronous, raw)]
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
        ("extra product path", ("diff", "--name-status", "-z", history.CARD_COLOR_BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.ASYNC_BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_card_color_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.ASYNC_AFTER_COMMIT, history.CARD_COLOR_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.CARD_COLOR_AFTER_COMMIT, "HEAD"), ("rev-parse", "HEAD")):
        seen = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                seen[0] += 1
                if target[0] == "merge-base" or seen[0] == 2:
                    raise ValueError("synthetic unavailable ancestry or final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_card_color_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success cannot cache the next failure", lambda: history.holdem_card_color_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery", history._holdem_card_color_proof(raw, ROOT) == predecessors)
        with patch.object(history, "holdem_card_color_inverse", return_value=raw):
            rejects("stage loop rejects wrong inverse result", lambda: history.holdem_card_color_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("initial disk mismatch", lambda: history.holdem_card_color_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("final disk mismatch", lambda: history.holdem_card_color_predecessor(raw, ROOT))
        rejects("old438 raw cannot pass on441 disk", lambda: history.holdem_money_predecessor(asynchronous, ROOT))

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
    check("twenty distinct actual history tuples", len(views) == len(allowed) == 20)
    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result
    with patch.object(history, "_holdem_card_color_proof", side_effect=lambda value, where=None: bound(value, raw, predecessors, where)), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, main_previous, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits twenty real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, HOLD: h, MAIN: m, SCALP: s, ARUBA: a})
                    for h, m, s, a in itertools.product(tuple(map(sha, (raw, asynchronous, betting, canvas, money))),
                        tuple(map(sha, (main_raw, *main_previous))), (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic later-Holdem phantoms rejected", len(phantoms) == 255
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
    check("current441 outer admission retains core result", admission() is result)
    rejects("current441 outer raw mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("current441 outer HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    check("protected source dictionaries receipts and tools unchanged",
          all(sha((ROOT / path).read_bytes()) == digest for path, digest in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_CARD_COLOR_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
