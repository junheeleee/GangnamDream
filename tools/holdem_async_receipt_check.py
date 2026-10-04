#!/usr/bin/env python3
"""Bounded async-source admission; no historical suite or engine execution.

One fresh collector supplies the comparison inventory. Git fault cases replay
captured responses; manifest cases are synthetic censuses with real raw hashes.
Runtime action ownership itself is exercised by the separate isolated game run.
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
    protected = (HOLD, MAIN, SCALP, ARUBA, *bridge.CURRENT_PATHS,
                 "tools/holdem_money_history.py", "tools/holdem_money_receipt_check.py",
                 "tools/holdem_canvas_width_check.py", "tools/holdem_betting_receipt_check.py",
                 "tools/holdem_async_receipt_check.py", "tools/ja_translation_pipeline.py",
                 "tools/ja_translation_audit.py", "tools/ui_translation_append.py",
                 "tools/main_game_locale_history.py", "tools/audit_scope.json")
    unchanged = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / HOLD).read_bytes()
    check("independent async product pins", history.HOLDEM_PATH == HOLD
          and history.ASYNC_BEFORE_COMMIT == "031c3c2f8639e5c03f569e6f1509aee8ad38dcda"
          and history.ASYNC_AFTER_COMMIT == "aa21f0b08a21f839194fc2147869534c8c6b4ec2"
          and history.ASYNC_TREES == ("081c1926783f2c58d22f568d7b403f89f30a7d7c", "87007677e516ac1a79a39b53dccc0cd030b42a37")
          and history.ASYNC_BLOBS == ("ae11e6b873bd621649803637f43d79bc7e89b1d4", "bf36544000f94319b32ea6b299694a9644c8ebf4")
          and history.ASYNC_HASHES == ("4a8ae2c046e59ab4c2425bbb2270a552c73fbc76398c75079d45179f8748114f",
                                     "35c2a7124160bfbab0e9b039aad496d2059131d83222f87eeb12ef344e5a0e5c"))
    prefix = (ROOT / "tools/holdem_money_history.py").read_bytes().split(
        b"\n\n# BEGIN_HOLDEM_ASYNC_ACTION_HISTORY_438\n", 1)[0]
    check("old history collector audit and focused bytes preserved",
          sha(prefix) == "f78bc8c8da44e61a2947ce1325b21cb28b866cff9f220a92d6acc81f3515968f"
          and unchanged["tools/holdem_betting_receipt_check.py"] == "338985d15c4b69f52a3cdb18bd47b99e35f7eeb32f6119f066493d0ba8476d69"
          and unchanged["tools/holdem_canvas_width_check.py"] == "7e0c9d65ca9122a2f96522c14be4d592743317dec7dfa765506ac99897556453"
          and unchanged["tools/holdem_money_receipt_check.py"] == "406203ef21558e8b60fb886cb46bcf2a1ae6dfe4db3656aa91dc4057ef990fa1"
          and unchanged["tools/ja_translation_pipeline.py"] == "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b"
          and unchanged["tools/ja_translation_audit.py"] == "7c41b636b124d818642f177ad4ec57bd4fa0ac745832844ba3ae79865c7e4e81")
    real_git, trace, responses = history._git, [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_git", side_effect=traced):
        betting, canvas, money, previous = history._holdem_async_proof(raw, ROOT)
    stages = ((history.BEFORE_COMMIT, history.AFTER_COMMIT, history.TREES),
              (history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, history.CANVAS_TREES),
              (history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT, history.BETTING_TREES),
              (history.ASYNC_BEFORE_COMMIT, history.ASYNC_AFTER_COMMIT, history.ASYNC_TREES))
    requests = tuple(request for before, after, trees in stages
                     for request in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    check("real twenty-four-object batch and five raw pins",
          len(requests) == 24 and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and (sha(previous), sha(money)) == history.HASHES
          and (sha(money), sha(canvas)) == history.CANVAS_HASHES
          and (sha(canvas), sha(betting)) == history.BETTING_HASHES
          and (sha(betting), sha(raw)) == history.ASYNC_HASHES)
    expected = [("rev-parse", "HEAD"), ("cat-file", "--batch")]
    for index, (before, after, _trees) in enumerate(stages):
        expected.append(("diff", "--name-status", "-z", before, after))
        if index:
            expected.append(("merge-base", "--is-ancestor", stages[index - 1][1], before))
    expected += [("merge-base", "--is-ancestor", history.ASYNC_AFTER_COMMIT, "HEAD"),
                 ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")]
    check("real four transitions and current HEAD admission", [args for args, _ in trace] == expected)
    suffix = history.ASYNC_APPENDIX.encode()
    check("all four whole inverses retain exact earlier bytes", suffix.count(b"\n") == 58
          and len(history.ASYNC_REPLACEMENTS) == 11
          and history.holdem_async_inverse(raw, betting) == betting
          and history.holdem_betting_inverse(betting, canvas) == canvas
          and history.holdem_canvas_inverse(canvas, money) == money
          and history.holdem_money_inverse(money, previous) == previous)
    for label, mutant in (
        ("extra edit", raw + b"\n"), ("duplicate helper", raw + suffix),
        ("missing entry guard", raw.replace(b"if not _begin_player_action(): return", b'AudioManager.play("click")', 1)),
        ("wrong token guard", raw.replace(b"generation != _action_generation", b"generation == _action_generation", 1)),
        ("changed UI literal", raw.replace("프리플랍".encode(), "프리플랍!".encode(), 1)),
        ("mutable", bytearray(raw)),
    ):
        rejects("pure async inverse " + label, lambda value=mutant: history.holdem_async_inverse(value, betting))
    with patch.object(history, "_holdem_async_proof", return_value=(betting, canvas, money, previous)):
        check("four public predecessor meanings", history.holdem_async_predecessor(raw, ROOT) == betting
              and history.holdem_betting_predecessor(raw, ROOT) == canvas
              and history.holdem_canvas_predecessor(raw, ROOT) == money
              and history.holdem_money_predecessor(raw, ROOT) == previous)
    with patch.object(history, "ASYNC_TREES", (history.ASYNC_TREES[0],)), \
            patch.object(history, "_git", side_effect=AssertionError("malformed descriptor reached Git")):
        rejects("pin pair cannot silently truncate", lambda: history.holdem_async_predecessor(raw, ROOT))

    # One fresh current collector captures its own unchanged comparison. The
    # legacy collector is not called separately and no old focused is imported.
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
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main), \
            patch.object(history, "_git", side_effect=traced):
        current = pipeline.collect_ui_inventory()
    check("one fresh current collector", not current.errors and len(baseline_rows) == 1
          and not baseline_rows[0].errors and bool(main_rows))
    baseline = baseline_rows[0]
    views = [pipeline.parse_ui_calls(HOLD, source.decode()) for source in (betting, raw)]
    calls = [tuple(sorted(rows, key=lambda c: (c.path, c.line, c.api))) for rows, _errors in views]
    check("all sixty-one UiCall tuples including owner and line unchanged", len(calls[0]) == 61
          and all(not errors for _rows, errors in views) and calls[0] == calls[1]
          and tuple(c for c in current.calls if c.path == HOLD) == calls[0])
    retired = {ko for ko, _en in history.RETIRED_PAIRS}
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("retirement and all surviving Entry identities unchanged", len(baseline.calls) - len(current.calls) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and tuple(map(identity, current.entries)) == tuple(identity(e) for e in baseline.entries if e.source not in retired))
    observations, errors = pipeline.collect_ui_parameterized_observations()
    owners = [(o.path, o.function) for o in observations if o.state == "money_migrated"]
    check("actual money observations remain three", not errors and len(owners) == 3
          and owners.count((HOLD, "_fmt")) == 1 and current.stats["parameter_money_formatter_migrations"] == 3)
    ja = json.loads((ROOT / "locale/ui_ja.json").read_bytes())
    accepted = json.loads((ROOT / "content/meta/full_game_localization.json").read_bytes())["accepted"]
    retained_ja = {"%.1f억": "%.1f億", "%d만": "%d万", "%d원": "%dウォン"}
    check("retained Japanese three remain original and receipt-free", retired == set(retained_ja)
          and all(ja.get(key) == value for key, value in retained_ja.items())
          and isinstance(accepted, dict) and bool(accepted) and all(isinstance(rows, dict) for rows in accepted.values())
          and all("ui:" + key + ":/" + key not in rows for key in retired for rows in accepted.values()))

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]
    real_parse = pipeline.parse_ui_calls
    for field, mutate in (("line", lambda value: value + 1), ("function", lambda value: value + "_wrong")):
        def distorted(path, text, name=field, change=mutate):
            rows, errors = real_parse(path, text)
            if path == HOLD and text == raw.decode():
                rows = list(rows)
                rows[0] = replace(rows[0], **{name: change(getattr(rows[0], name))})
            return rows, errors
        with patch.object(history, "_git", side_effect=replay), patch.object(pipeline, "parse_ui_calls", side_effect=distorted):
            rejects("collector rejects forged " + field, lambda: pipeline._holdem_money_call_views(raw))

    # The following failures replay captured Git replies, not new actual runs.
    for label, target, change in (
        ("missing object", ("cat-file",), lambda value: b"missing\n"),
        ("forged object", ("cat-file",), lambda value: value.replace(b"tree ", b"Tree ", 1)),
        ("trailing bytes", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.ASYNC_BEFORE_COMMIT), lambda value: value + b"M\0neighbor.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.BETTING_BLOBS[1].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=change, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history.holdem_async_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.BETTING_AFTER_COMMIT, history.ASYNC_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.ASYNC_AFTER_COMMIT, "HEAD"), ("rev-parse", "HEAD")):
        seen = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                seen[0] += 1
                if target[0] == "merge-base" or seen[0] == 2:
                    raise ValueError("synthetic unavailable ancestry or final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("replayed unavailable " + str(target), lambda: history.holdem_async_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success cannot cache the next failure", lambda: history.holdem_async_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("replayed recovery", history._holdem_async_proof(raw, ROOT) == (betting, canvas, money, previous))
        with patch.object(history, "holdem_async_inverse", return_value=raw):
            rejects("stage loop rejects wrong inverse result", lambda: history.holdem_async_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("initial disk mismatch", lambda: history.holdem_async_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("final disk mismatch", lambda: history.holdem_async_predecessor(raw, ROOT))
        rejects("old437 raw cannot pass on438 disk", lambda: history.holdem_money_predecessor(betting, ROOT))

    main_raw, scalp_raw, aruba_raw = ((ROOT / p).read_bytes() for p in (MAIN, SCALP, ARUBA))
    predecessors = main_rows[0]
    check("captured Main history population", len(predecessors) == 12 and all(value == predecessors for value in main_rows))
    scalp_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    aruba_old = bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    hold_views = [{**hashes, HOLD: sha(value)} for value in (raw, betting, canvas, money, previous)]
    views = [*hold_views, {**hold_views[-1], MAIN: sha(predecessors[0])}]
    views += [{**hold_views[-1], MAIN: sha(value), SCALP: sha(scalp_old)} for value in predecessors]
    views += [{**views[-1], ARUBA: sha(aruba_old)}]
    allowed = {bridge.exchange.digest(value) for value in views}
    source = census(hashes)
    preserved = copy.deepcopy(source)
    check("nineteen distinct actual history tuples", len(views) == len(allowed) == 19)
    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic source binding mismatch")
        return result
    with patch.object(history, "_git", side_effect=replay), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, predecessors, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits all nineteen real tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, HOLD: h, MAIN: m, SCALP: s, ARUBA: a})
                    for h, m, s, a in itertools.product(tuple(map(sha, (raw, betting, canvas, money))),
                        tuple(map(sha, (main_raw, *predecessors))), (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic later-Holdem phantoms rejected", len(phantoms) == 204
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned source and unknown manifest rejected",
              not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
              and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current digest", lambda: bridge._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        for index, stale in enumerate(hold_views[1:]):
            rejects("stale current census " + str(index), lambda value=stale: bridge._source_manifest_matches(ROOT, census(value), bridge.exchange.digest(value)))
    check("supplied synthetic census untouched", source == preserved)

    # Unchanged outer admission, with its old core explicitly a test double.
    head = "f" * 40
    result = {**source, "evidence": {"head": head}}
    def admission(raws=None, heads=None):
        with patch.object(Path, "read_bytes", side_effect=raws or (raw, raw)), \
                patch.object(history, "holdem_money_predecessor", return_value=previous), \
                patch.object(bridge, "_git", side_effect=heads or (head.encode(), head.encode())), \
                patch.object(bridge, "_HOLDEM_MONEY_OLD_CURRENT_PROOF", return_value=result):
            return bridge.current_proof(ROOT, "synthetic baseline", {})
    check("current438 outer proof retains core result", admission() is result)
    rejects("current438 outer raw mismatch", lambda: admission(raws=(raw, raw + b"\n")))
    rejects("current438 outer HEAD mismatch", lambda: admission(heads=(head.encode(), b"0" * 40)))
    check("protected sources dictionaries receipts and tools unchanged", all(sha((ROOT / p).read_bytes()) == value for p, value in unchanged.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_ASYNC_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
