#!/usr/bin/env python3
"""Bounded localized-banner admission, not historical suite re-execution.

One real eight-stage source proof and one current collector are observed.
Faults use captured Git replay or synthetic inventories/snapshots; those are
not new historical PASS claims. No private artifacts or engine are required.
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
MAIN, SCALP, ARUBA = main_history.MAIN_GAME_PATH, bridge.SCALPING_PHASE_PATH, bridge.ARUBA_FONT_PATH
KEY = "새 핸드"
TEXTS = {"ja": "新しいハンド", "zh-CN": "新一手牌", "zh-TW": "新一手牌"}
PRODUCT_BEFORE = "5ac51c9b437147f95363d1ceaf86b05b7d0a8266"
PRODUCT_AFTER = "739e64b1fed4d8f080707823224ff0cf526e6b97"
PRODUCT_HASHES = {
    "locale/ui_ja.json": ("4e36e13606f483779d8551c14b8900e7c7518ea37f4083f495007d654dc17c8c", "ef4cb956fe532886f0a3af4e0d5ac06c660b6d821ed4acdf6d005816ea6d5a0b"),
    "locale/ui_zh-CN.json": ("052b59ab75a827354111d3c09de53e9d85e46611ab7b050691e1257a330c8152", "844edfd0638e0123b26530d3b46094819d5cbf1748bbd674bf36ca5147ea98bd"),
    "locale/ui_zh-TW.json": ("99395844a6a301263cf92925194076e222eeea3569452696a689639df814700c", "30bd5b069601c00fcf0a68c49eb547f765d041153d36d2db58d4e8a7fc14721c"),
    "content/meta/full_game_localization.json": ("599da71c72b7e159c2bbf668fd2eba963ccd9f5195e06827ca9514f8802b73cb", "06c1f4c48ca1c81ee3d72a7dee62c07df4a1eeaba63321045ce0dd1a08035d80"),
}
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


def bound(value, expected, result, where=None):
    if where not in (None, ROOT) or value != expected:
        raise ValueError("synthetic source binding mismatch")
    return result


def main():
    protected = (*bridge.CURRENT_PATHS, HOLD, MAIN, SCALP, ARUBA,
                 "systems/TexasHoldem.gd", "scenes/TutorialOverlay.gd",
                 "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py",
                 "tools/zh_translation_audit.py", "tools/full_game_localization.py",
                 "tools/holdem_banner_locale_receipt_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    old_tests = ("holdem_money_receipt_check.py", "holdem_canvas_width_check.py",
                 "holdem_betting_receipt_check.py", "holdem_async_receipt_check.py",
                 "holdem_card_color_receipt_check.py", "holdem_message_pulse_receipt_check.py",
                 "holdem_banner_receipt_check.py", "holdem_rank_ja_receipt_check.py",
                 "holdem_tutorial_ui_self_test.py")
    for name in old_tests:
        path = "tools/" + name
        check("old focused bytes preserved " + name, (ROOT / path).read_bytes()
              == bridge._git(ROOT, "show", history.BANNER_LOCALE_BEFORE_COMMIT + ":" + path))
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_BANNER_LOCALE_HISTORY_447\n",
         "16707422b1c828fe5db2c2d41c64358fae2efdc5e3e77c6521827e4aeac7c4db"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_BANNER_LOCALE_APPEND_447\n",
         "e7dbd57abbbccc0cbc1886a496b931699d81faac2202cfd20780da7f66c15984"),
    ):
        raw = observed[path]
        check("complete old prefix " + path, raw.count(marker) == 1
              and sha(raw.split(marker)[0]) == digest)
    pipeline_raw = observed["tools/ja_translation_pipeline.py"]
    old_pipeline = pipeline.holdem_banner_locale_pipeline_predecessor(pipeline_raw)
    check("sealed collector restores complete predecessor", sha(old_pipeline)
          == "a16971c199dd2deeb76abb786a7eace97a1eaf31c89349bae7108b1d2249ec8b")
    rejects("collector appendix mutation rejected", lambda: pipeline.holdem_banner_locale_pipeline_predecessor(
        pipeline_raw.replace(b'"holdem_banner_locale_added_calls": 5', b'"holdem_banner_locale_added_calls": 6', 1)))

    raw = observed[HOLD]
    check("independent new source product pins", history.BANNER_LOCALE_BEFORE_COMMIT
          == "3eb2fccf3c41246d3c374d6c1de5274b1567a7d1" and history.BANNER_LOCALE_AFTER_COMMIT
          == "8a184316012c6d7856f8fe5dcd47be703bd834ca"
          and history.BANNER_LOCALE_TREES == ("9492b89eeacc70303620ad693d4a2889de0b06e0", "fea431e3281dbbaf79ac831176f7e2a2b846e17b")
          and history.BANNER_LOCALE_BLOBS == ("6a878a78adb2c02a902a09b33ccde0bba1eb0fe6", "6b62466601cf2b7f5473a44ed3654e3fd10c5a2a")
          and history.BANNER_LOCALE_HASHES == ("634d8a603ba4e38263696523963c2f2ad040adaeccec781a82f682977c02a721",
                                               "766070551b1d23b9f1c70e74dc7419994b38c2b9c9911e449a649417bbb1d273"))
    real_git, trace, responses = history._git, [], {}
    def traced(where, *args, **kwargs):
        result = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=traced):
        predecessors = history._holdem_banner_locale_proof(raw, ROOT)
    previous = predecessors[0]
    stages = tuple((getattr(history, prefix + "BEFORE_COMMIT"),
                    getattr(history, prefix + "AFTER_COMMIT"),
                    getattr(history, prefix + "TREES"), getattr(history, prefix + "HASHES"))
                   for prefix in ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_",
                                  "MESSAGE_PULSE_", "BANNER_", "BANNER_LOCALE_"))
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("actual eight-stage proof has forty-eight request rows", len(predecessors) == 8
          and len(requests) == 48 and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    ids, cursor = [], 0
    packet = responses[(("cat-file", "--batch"), batch)]
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        ids.append(oid)
        cursor = end + 2 + int(size)
    check("forty-one distinct objects with five new identities", cursor == len(packet)
          and len(set(ids)) == 41 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    expected_trace = [("rev-parse", "HEAD"), ("cat-file", "--batch")]
    for index, (before, after, _trees, _hashes) in enumerate(stages):
        expected_trace.append(("diff", "--name-status", "-z", before, after))
        if index:
            expected_trace.append(("merge-base", "--is-ancestor", stages[index - 1][1], before))
    expected_trace += [("merge-base", "--is-ancestor", history.BANNER_LOCALE_AFTER_COMMIT, "HEAD"),
                       ("rev-parse", "HEAD:" + HOLD), ("rev-parse", "HEAD")]
    check("actual source proof queries and final binding", [args for args, _ in trace] == expected_trace)
    check("exact twelve same-line replacements and nine-line appendix", len(history.BANNER_LOCALE_REPLACEMENTS) == 12
          and raw.count(b"\n") - previous.count(b"\n") == 9
          and history.holdem_banner_locale_inverse(raw, previous) == previous)
    mutations = (
        ("outside bytes", raw + b"\n"),
        ("mutable bytes", bytearray(raw)),
        ("phase rule", raw.replace(b'1 if banner in ["TURN", "RIVER"] else 3',
                                   b'2 if banner in ["TURN", "RIVER"] else 3', 1)),
        ("action duration", raw.replace(b'_action_label(action).to_upper(), Color("#5de89c"), 0.45',
                                       b'_action_label(action).to_upper(), Color("#5de89c"), 0.95', 1)),
        ("AI spacing", raw.replace(b'"%s  %s" % [_opp_name(opp_idx)', b'"%s %s" % [_opp_name(opp_idx)', 1)),
        ("wrong new source", raw.replace('"새 핸드", "New Hand"'.encode(), '"다음 핸드", "New Hand"'.encode(), 1)),
        ("missing uppercase", raw.replace(b'"New Hand").to_upper()', b'"New Hand")', 1)),
        ("extra helper code", raw + b"\t_phase = Phase.RESULT\n"),
    )
    for name, value in mutations:
        check("effective source mutation " + name, value != raw or type(value) is not bytes)
        rejects("exact inverse rejects " + name, lambda value=value: history.holdem_banner_locale_inverse(value, previous))
    with patch.object(history, "_holdem_banner_locale_proof", return_value=predecessors):
        check("eight public predecessor meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_banner_locale_predecessor, history.holdem_banner_predecessor,
            history.holdem_message_pulse_predecessor, history.holdem_card_color_predecessor,
            history.holdem_async_predecessor, history.holdem_betting_predecessor,
            history.holdem_canvas_predecessor, history.holdem_money_predecessor)) == predecessors)
    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured-Git replay")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, transform in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("new extra path", ("diff", "--name-status", "-z", history.BANNER_LOCALE_BEFORE_COMMIT),
         lambda value: value + b"M\0outside.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.BANNER_LOCALE_BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=prefix, transform=transform, **kwargs):
            value = replay(where, *args, **kwargs)
            return transform(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured-Git replay " + name, lambda: history.holdem_banner_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        with patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
            rejects("fresh final source read", lambda: history.holdem_banner_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("synthetic fresh Git loss")):
        rejects("prior success does not cache failure", lambda: history.holdem_banner_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("captured-Git recovery", history._holdem_banner_locale_proof(raw, ROOT) == predecessors)

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
    source_bound = lambda value, where=None: bound(value, raw, predecessors, where)
    with patch.object(history, "_holdem_banner_locale_proof", side_effect=source_bound), \
            patch.object(pipeline, "_HOLDEM_MONEY_OLD_COLLECT", side_effect=capture_baseline), \
            patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one fresh current UI collector", not current.errors and len(baselines) == 1
          and not baselines[0].errors and bool(main_rows))
    parsed = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    old_calls, live_calls = (tuple(sorted(calls, key=lambda c: (c.path, c.line, c.api))) for calls, _errors in parsed)
    added = tuple(pipeline.UiCall(HOLD, "_phase_banner_label", 1784 + i, "legacy", ko, en)
                  for i, (ko, en) in enumerate((("새 핸드", "New Hand"), ("플랍", "Flop"),
                                                ("턴", "Turn"), ("리버", "River"), ("쇼다운", "Showdown"))))
    check("all old sixty-one identities plus five actual EOF calls", not any(errors for _calls, errors in parsed)
          and len(old_calls) == 61 and live_calls == (*old_calls, *added)
          and tuple(c for c in current.calls if c.path == HOLD) == live_calls)
    baseline = baselines[0]
    retired = {ko for ko, _en in history.RETIRED_PAIRS}
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    identities = lambda entries: {e.source: (e.key, e.source_hash, e.context_id, e.format_template) for e in entries}
    old_ids, current_ids = identities(baseline.entries), identities(current.entries)
    check("surviving Entry IDs preserved and one new source", set(old_ids) - set(current_ids) == retired
          and set(current_ids) - set(old_ids) == {KEY}
          and all(current_ids[k] == value for k, value in old_ids.items() if k not in retired)
          and tuple(identity(e) for e in current.entries if e.source != KEY)
          == tuple(identity(e) for e in baseline.entries if e.source not in retired)
          and current_ids[KEY][0] == "ui::holdem-banner::" + hashlib.sha1(KEY.encode()).hexdigest()
          and len(current.calls) == len(baseline.calls) + 2)
    check("current money and new call census honest", current.stats["parameter_money_formatter_migrations"] == 3
          and current.stats["holdem_banner_locale_added_calls"] == 5 and current.stats["holdem_banner_locale_added_keys"] == 1)
    with patch.object(history, "_holdem_banner_locale_proof", side_effect=source_bound):
        rejects("forged supplied predecessor inventory", lambda: pipeline.holdem_money_rebind_inventory(
            replace(baseline, calls=tuple(c for c in baseline.calls if c != next(c for c in baseline.calls if c.path == HOLD))), raw))
    main_raw, scalp_raw, aruba_raw = (observed[p] for p in (MAIN, SCALP, ARUBA))
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
    saved = copy.deepcopy(source)
    check("twenty-three distinct actual historical tuples", len(views) == len(allowed) == 23)
    with patch.object(history, "_holdem_banner_locale_proof", side_effect=source_bound), \
            patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, where=None: bound(value, main_raw, main_previous, where)), \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda where, value: bound(value, scalp_raw, scalp_old, where)), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=lambda where, value: bound(value, aruba_raw, aruba_old, where)):
        check("synthetic census admits exactly the actual lineage", all(bridge._source_manifest_matches(ROOT, source, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main, SCALP: scalp, ARUBA: aruba})
                    for main, scalp, aruba in itertools.product(tuple(map(sha, (main_raw, *main_previous))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("fifty-one new-Holdem phantom mixtures rejected", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, source, digest) for digest in phantoms))
        rejects("stale supplied census rejected", lambda: bridge._source_manifest_matches(
            ROOT, census(hold_views[1]), bridge.exchange.digest(hold_views[1])))
        check("unknown and unowned manifests rejected", not bridge._source_manifest_matches(ROOT, source, "0" * 64)
              and not bridge._source_manifest_matches(ROOT, census({**hashes, "unowned.gd": "changed"}), source["source_manifest_sha256"]))
    check("synthetic census not mutated", source == saved)

    # Real immutable new-translation snapshots, not private export artifacts.
    before = bridge._snapshot(ROOT, PRODUCT_BEFORE, bridge.CURRENT_PATHS)
    after = bridge._snapshot(ROOT, PRODUCT_AFTER, bridge.CURRENT_PATHS)
    check("pinned four-path translation product bytes", set(PRODUCT_HASHES) == set(bridge.CURRENT_PATHS)
          and all((sha(before[p]), sha(after[p])) == PRODUCT_HASHES[p] and after[p] == observed[p] for p in bridge.CURRENT_PATHS)
          and bridge._git(ROOT, "rev-parse", PRODUCT_AFTER + "^").decode().strip() == PRODUCT_BEFORE
          and bridge._git(ROOT, "diff", "--name-status", "-z", PRODUCT_BEFORE, PRODUCT_AFTER)
          == b"".join(b"M\0" + p.encode() + b"\0" for p in sorted(bridge.CURRENT_PATHS)))
    old = {p: bridge._loads(value) for p, value in before.items()}
    new = {p: bridge._loads(value) for p, value in after.items()}
    ledger = bridge.LEDGER_PATH
    leaf = bridge.exchange.Leaf("ui", KEY, "runtime:static_ui", (KEY,), KEY, "ui_static_context")
    inventory = {"leaves": [leaf]}
    check("one actual new source Leaf and exact localized targets", KEY in current.blueprint
          and leaf.id == "ui:새 핸드:/새 핸드" and all(
              KEY not in old[p] and new[p][KEY] == TEXTS[loc]
              for loc, p in zip(bridge.CURRENT_LOCALES, bridge.CURRENT_UI_PATHS)))
    change = bridge.validate_append(before, after, inventory)
    check("three new official locale receipts without reissuance", change["receipts"] == change["batches"] == 3
          and change["ui_by_locale"] == {loc: 1 for loc in TEXTS}
          and change["source_manifests"] == {PRODUCT_BEFORE: "1890a6c44865da19f0095d9efe8569fb7f33fcb49975ecb30762c224727a48b9"}
          and len(old[ledger]["batches"]) == 217 and len(new[ledger]["batches"]) == 220
          and sum(map(len, old[ledger]["accepted"].values())) == 41737
          and sum(map(len, new[ledger]["accepted"].values())) == 41740
          and all(row["order"] == "ORDER-447" and row["roots"] == [KEY] for row in new[ledger]["batches"][217:]))
    check("new receipt source revisions are actual ancestors", all(
        bridge._git(ROOT, "merge-base", "--is-ancestor", revision, PRODUCT_AFTER) == b""
        for revision in change["source_manifests"]))
    # Structural mutations use serialized synthetic data and fail before raw inverse.
    def mutated(path, edit):
        document = copy.deepcopy(new[path])
        edit(document)
        if path == ledger:
            document["accepted_sha256"] = bridge.exchange.digest(document["accepted"])
        return {**after, path: bridge._ordered(document)}
    bad_cases = (
        ("wrong new target", "locale/ui_ja.json", lambda doc: doc.__setitem__(KEY, "次のハンド")),
        ("old target changed", "locale/ui_ja.json", lambda doc: doc.__setitem__("폴드", "outside")),
        ("stale source receipt", ledger, lambda doc: doc["accepted"]["ja"][leaf.id].__setitem__("source_sha256", "0" * 64)),
        ("wrong official count", ledger, lambda doc: doc["batches"][217].__setitem__("source_leaves", 2)),
        ("wrong header", ledger, lambda doc: doc["batches"][217][bridge.HEADERS_FIELD]["ja"].__setitem__("count", 2)),
        ("old batch changed", ledger, lambda doc: doc["batches"][0].__setitem__("order", "outside")),
    )
    for name, path, edit in bad_cases:
        rejects("synthetic new receipt " + name, lambda path=path, edit=edit: bridge.validate_append(
            before, mutated(path, edit), inventory))
    rejects("unknown current source Leaf", lambda: bridge.validate_append(before, after, {"leaves": []}))
    rejects("raw outside append", lambda: bridge.validate_append(
        before, {**after, "locale/ui_ja.json": after["locale/ui_ja.json"] + b"\n"}, inventory))
    check("source product tools translations and HEAD unchanged", all((ROOT / p).read_bytes() == value for p, value in observed.items())
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)])
    check("unique focused case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_BANNER_LOCALE_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
