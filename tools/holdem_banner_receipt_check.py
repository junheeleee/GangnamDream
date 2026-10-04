#!/usr/bin/env python3
"""Bounded banner transition admission; no engine or historical focused suites.

Capture one real seven-stage Git proof and one fresh current UI collector.
Faults then replay captured Git responses. Manifest probes use synthetic
censuses with actual historical source hashes, not new historical PASS claims.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import sys
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import holdem_money_history as history
import ja_translation_pipeline as pipeline
import main_game_locale_history as main_history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
HOLD = "scenes/HoldemClub.gd"
MAIN, SCALP, ARUBA = main_history.MAIN_GAME_PATH, bridge.SCALPING_PHASE_PATH, bridge.ARUBA_FONT_PATH
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
        "tools/holdem_message_pulse_receipt_check.py": "d4deb08c7845487622d43d9207ec2f31c5a5d617a561db134198de26a32a455e",
        "tools/holdem_tutorial_ui_self_test.py": "0cd42d2bab4127ae3d366fbd0b73249910776d97998d870222445ca4dcf308e3",
        "tools/holdem_tutorial_ui.py": "c757176d4a51e2c37b2cdcbf2593463e79a078085885e2b46e80300b03d6c528",
        "tools/ja_translation_pipeline.py": "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b",
        "tools/ja_translation_audit.py": "862aaf7e68ff2ddef3cf6f5222523fa5e3055f232b5dfe8d765dc526a4992714",
        "tools/zh_translation_audit.py": "b185c19170523015fb34ac4f8348468c5e318c9987c1078ac4e4547c31393276",
        "locale/ui_ja.json": "04fa4cbf9c0a9b9355142d782b4c8d34bb924e9a7378233e9005c3aacc82e1a2",
        "locale/ui_zh-CN.json": "052b59ab75a827354111d3c09de53e9d85e46611ab7b050691e1257a330c8152",
        "locale/ui_zh-TW.json": "99395844a6a301263cf92925194076e222eeea3569452696a689639df814700c",
        "content/meta/full_game_localization.json": "3317d981e97ac0d7ce25434601b7c89f8d698d3e1d46e62d8a31394b5d119b76",
    }
    protected = (HOLD, MAIN, SCALP, ARUBA, *frozen, "scenes/TutorialOverlay.gd",
                 "systems/TexasHoldem.gd", "tools/full_game_localization.py",
                 "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/main_game_locale_history.py", "tools/audit_scope.json",
                 "tools/holdem_banner_receipt_check.py")
    unchanged = {path: sha((ROOT / path).read_bytes()) for path in protected}
    check("old focused files and translation bytes pinned", all(unchanged[p] == value for p, value in frozen.items()))
    for path, marker, count, expected in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_BANNER_HISTORY_445\n", 755,
         "d5316f7e3eab0be53f5f35dd813e36969d9397d40df561d821f61015672150d8"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_BANNER_APPEND_445\n", 1954,
         "bf031e41ba1b9b0e0f483e3d86fd03763a2de2771f361fb1549c9187af6a8f7c"),
    ):
        value = (ROOT / path).read_bytes()
        prefix = value.split(marker, 1)[0]
        check("unchanged complete prefix " + path, value.count(marker) == 1
              and len(prefix.splitlines()) == count and sha(prefix) == expected)
    raw = (ROOT / HOLD).read_bytes()
    check("independent new product pins", history.HOLDEM_PATH == HOLD
          and history.BANNER_BEFORE_COMMIT == "c0035fbf68e5435ddb94a7d5a290ee0879a4aef5"
          and history.BANNER_AFTER_COMMIT == "ddece4ce18fa811b7ed7d9130f82d81c4cd757e1"
          and history.BANNER_TREES == ("89793593195acf1dca7e5f2ddb3401d8976a1b30", "c8acad6105c808e8f4a97f2f075d9b96d48c3736")
          and history.BANNER_BLOBS == ("6b1e43f4547be5aa8f2aae54b3f730c40f7d437c", "6a878a78adb2c02a902a09b33ccde0bba1eb0fe6")
          and history.BANNER_HASHES == ("cfc4987793e22738d8d7474f8cb821c072276e6d8c9390cf05ff5f1ef2a68ee4",
                                       "634d8a603ba4e38263696523963c2f2ad040adaeccec781a82f682977c02a721"))
    real_git, trace, responses = history._git, [], {}
    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value
    with patch.object(history, "_git", side_effect=traced):
        predecessors = history._holdem_banner_proof(raw, ROOT)
    previous = predecessors[0]
    stages = (
        (history.BEFORE_COMMIT, history.AFTER_COMMIT, history.TREES, history.HASHES),
        (history.CANVAS_BEFORE_COMMIT, history.CANVAS_AFTER_COMMIT, history.CANVAS_TREES, history.CANVAS_HASHES),
        (history.BETTING_BEFORE_COMMIT, history.BETTING_AFTER_COMMIT, history.BETTING_TREES, history.BETTING_HASHES),
        (history.ASYNC_BEFORE_COMMIT, history.ASYNC_AFTER_COMMIT, history.ASYNC_TREES, history.ASYNC_HASHES),
        (history.CARD_COLOR_BEFORE_COMMIT, history.CARD_COLOR_AFTER_COMMIT, history.CARD_COLOR_TREES, history.CARD_COLOR_HASHES),
        (history.MESSAGE_PULSE_BEFORE_COMMIT, history.MESSAGE_PULSE_AFTER_COMMIT, history.MESSAGE_PULSE_TREES, history.MESSAGE_PULSE_HASHES),
        (history.BANNER_BEFORE_COMMIT, history.BANNER_AFTER_COMMIT, history.BANNER_TREES, history.BANNER_HASHES),
    )
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("real seven-stage batch with six added request entries", len(requests) == 42
          and len(predecessors) == 7
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    object_ids, cursor = [], 0
    packet = responses[(("cat-file", "--batch"), batch)]
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        object_ids.append(oid)
        cursor = end + 2 + int(size)
    check("forty-two request rows represent thirty-six distinct objects",
          cursor == len(packet) and len(set(object_ids)) == 36
          and len(set(object_ids[-6:]) - set(object_ids[:-6])) == 5)
    expected_trace = [("rev-parse", "HEAD"), ("cat-file", "--batch")]
    for index, (before, after, _trees, _hashes) in enumerate(stages):
        expected_trace.append(("diff", "--name-status", "-z", before, after))
        if index:
            expected_trace.append(("merge-base", "--is-ancestor", stages[index - 1][1], before))
    expected_trace += [("merge-base", "--is-ancestor", history.BANNER_AFTER_COMMIT, "HEAD"),
                       ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")]
    check("real transition and current binding queries exact", [args for args, _ in trace] == expected_trace)
    old, new = (part.encode() for part in history.BANNER_REPLACEMENT)
    check("whole-function inverse and exact four-line increase", history.holdem_banner_inverse(raw, previous) == previous
          and raw.count(b"\n") == previous.count(b"\n") + 4
          and old.startswith(b"func _show_table_banner(") and new.startswith(b"func _show_table_banner("))
    mutations = (
        ("outside function", raw + b"\n"), ("mutable raw", bytearray(raw)),
        ("duplicate function", raw + new), ("old function", raw.replace(new, old, 1)),
        ("timer", raw.replace(new, new.replace(b"tween_interval(duration)", b"tween_interval(duration + 1.0)"), 1)),
        ("tag", raw.replace(new, new.replace(b'&"holdem_table_banner"', b'&"unowned"', 1), 1)),
        ("hide all", raw.replace(new, new.replace(b'child.get_meta(&"holdem_table_banner", false) == true', b'true'), 1)),
        ("empty guard", raw.replace(new, new.replace(b"if text.is_empty():", b"if false:"), 1)),
        ("bottom margin", raw.replace(new, new.replace(b"panel.size.y - 24.0", b"panel.size.y - 12.0"), 1)),
    )
    for label, changed in mutations:
        check("effective pure mutation " + label, changed != raw or type(changed) is not bytes)
        rejects("pure inverse rejects " + label, lambda value=changed: history.holdem_banner_inverse(value, previous))
    with patch.object(history, "_holdem_banner_proof", return_value=predecessors):
        check("seven public predecessor meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_banner_predecessor, history.holdem_message_pulse_predecessor,
            history.holdem_card_color_predecessor, history.holdem_async_predecessor,
            history.holdem_betting_predecessor, history.holdem_canvas_predecessor,
            history.holdem_money_predecessor)) == predecessors)

    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured-Git replay request")
        return responses[(args, kwargs.get("input"))]
    for label, prefix, transform in (
        ("forged object bytes", ("cat-file",), lambda value: value[:-2] + b"X\n"),
        ("trailing batch", ("cat-file",), lambda value: value + b"x"),
        ("new extra product path", ("diff", "--name-status", "-z", history.BANNER_BEFORE_COMMIT), lambda value: value + b"M\0other.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.BANNER_BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, start=prefix, mutate=transform, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(start)] == start else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured-Git replay " + label, lambda: history.holdem_banner_predecessor(raw, ROOT))
    for target in (("merge-base", "--is-ancestor", history.MESSAGE_PULSE_AFTER_COMMIT, history.BANNER_BEFORE_COMMIT),
                   ("merge-base", "--is-ancestor", history.BANNER_AFTER_COMMIT, "HEAD"), ("rev-parse", "HEAD")):
        calls = [0]
        def unavailable(where, *args, **kwargs):
            if args == target:
                calls[0] += 1
                if target[0] == "merge-base" or calls[0] == 2:
                    raise ValueError("synthetic unavailable ancestry/final HEAD")
            return replay(where, *args, **kwargs)
        with patch.object(history, "_git", side_effect=unavailable):
            rejects("captured-Git replay unavailable " + str(target), lambda: history.holdem_banner_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        with patch.object(Path, "read_bytes", return_value=raw + b"\n"):
            rejects("initial disk binding", lambda: history.holdem_banner_predecessor(raw, ROOT))
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("final disk binding", lambda: history.holdem_banner_predecessor(raw, ROOT))
        rejects("old raw cannot pose as current", lambda: history.holdem_money_predecessor(previous, ROOT))
        with patch.object(history, "holdem_banner_inverse", return_value=raw):
            rejects("wrong stage inverse return", lambda: history.holdem_banner_predecessor(raw, ROOT))
    with patch.object(history, "BANNER_TREES", (history.BANNER_TREES[0],)), \
            patch.object(history, "_git", side_effect=AssertionError("malformed stage reached Git")):
        rejects("new descriptor cannot truncate", lambda: history.holdem_banner_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic next-call fault")):
        rejects("success does not cache failure", lambda: history.holdem_banner_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("captured-Git replay recovery", history._holdem_banner_proof(raw, ROOT) == predecessors)

    baselines, main_rows = [], []
    real_collect, real_main = pipeline._HOLDEM_MONEY_OLD_COLLECT, main_history._log_body_font_proof
    def capture_baseline(contract=None):
        result = real_collect(contract)
        baselines.append(result)
        return result
    def capture_main(value, where=None):
        result = real_main(value, where)
        main_rows.append(result)
        return result
    with patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", side_effect=capture_baseline), \
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one fresh current collector", not current.errors and len(baselines) == 1
          and not baselines[0].errors and bool(main_rows))
    views = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    calls = [tuple(sorted(rows, key=lambda c: (c.path, c.line, c.api))) for rows, _errors in views]
    check("all sixty-one UI calls including coordinates unchanged", len(calls[0]) == 61
          and all(not errors for _rows, errors in views) and calls[0] == calls[1]
          and tuple(c for c in current.calls if c.path == HOLD) == calls[0])
    retired = {ko for ko, _en in history.RETIRED_PAIRS}
    identity = lambda entry: (entry.key, entry.source, entry.source_hash, entry.context_id, entry.format_template)
    baseline = baselines[0]
    check("all surviving Entry identities and money census preserved", len(baseline.calls) - len(current.calls) == 3
          and set(baseline.blueprint) - set(current.blueprint) == retired
          and not (set(current.blueprint) - set(baseline.blueprint))
          and tuple(map(identity, current.entries)) == tuple(identity(e) for e in baseline.entries if e.source not in retired)
          and current.stats["parameter_money_formatter_migrations"] == 3)
    main_raw, scalp_raw, aruba_raw = ((ROOT / path).read_bytes() for path in (MAIN, SCALP, ARUBA))
    main_previous = main_rows[0]
    check("captured Main source population", len(main_previous) == 12 and all(value == main_previous for value in main_rows))
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
    check("twenty-two distinct actual historical tuples", len(views) == len(allowed) == 22)
    def bound(value, expected, result, where):
        if where != ROOT or value != expected:
            raise ValueError("synthetic current source binding mismatch")
        return result
    with patch.object(history, "_holdem_banner_proof", side_effect=lambda value, where=None: bound(value, raw, predecessors, where)), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, main_previous, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits all twenty-two actual tuples", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main, SCALP: scalp, ARUBA: aruba})
                    for main, scalp, aruba in itertools.product(tuple(map(sha, (main_raw, *main_previous))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("synthetic new-Holdem peer mixtures rejected", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        check("unowned changes and unknown manifests rejected", not bridge._source_manifest_matches(
            ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"])
            and not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        rejects("forged current census digest", lambda: bridge._source_manifest_matches(
            ROOT, {**source, "source_manifest_sha256": "bad"}, "bad"))
        rejects("pre-banner raw is not a current census", lambda: bridge._source_manifest_matches(
            ROOT, census(hold_views[1]), bridge.exchange.digest(hold_views[1])))
    check("synthetic source census not mutated", source == preserved)
    check("protected source tools translations and receipts unchanged", all(
        sha((ROOT / path).read_bytes()) == digest for path, digest in unchanged.items()))
    check("unique focused case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_BANNER_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
