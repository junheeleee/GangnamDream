#!/usr/bin/env python3
"""One table-label delta, one real proof/collector, and captured fault replay.

No historical test suite or private runtime artifact is executed or required.
Translation product pins are bound only after the actual official acceptance.
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
HOLD = history.HOLDEM_PATH
MAIN, SCALP, ARUBA = main_history.MAIN_GAME_PATH, bridge.SCALPING_PHASE_PATH, bridge.ARUBA_FONT_PATH
KEYS = ("팟", "공개 카드", "보유 칩", "베팅")
TEXTS = {"ja": ("ポット", "共通カード", "持ちチップ", "ベット"),
         "zh-CN": ("底池", "公共牌", "持有筹码", "下注"),
         "zh-TW": ("底池", "公共牌", "持有籌碼", "下注")}
PRODUCT_BEFORE = "7e84de58d6857c47cd3edd0343c715c26b61dadf"
PRODUCT_AFTER = "3090b03f5d972429fc3ac9f5d5602de0ebe8bfed"
PRODUCT_HASHES = {
    "locale/ui_ja.json": ("dfe4a83473850ec1bb61a8b3300cbc3ee7630fefb136979777221e77971ac463", "5f0c05425a5ddd11de4138002e18a9808d6174ced146954f40b274d7a09d5108"),
    "locale/ui_zh-CN.json": ("844edfd0638e0123b26530d3b46094819d5cbf1748bbd674bf36ca5147ea98bd", "56aa8c8320624223159f6d0034121aef0b8699ec51788c095b96627be2b3e863"),
    "locale/ui_zh-TW.json": ("30bd5b069601c00fcf0a68c49eb547f765d041153d36d2db58d4e8a7fc14721c", "b589d1887d3660c9f3122e371ef5b28d06c258c23ddad18bfa6d8f5bef312ce0"),
    "content/meta/full_game_localization.json": ("6186aaa75eb4c796ece79b066a12705d2cd28bfdbc70a237bef2b5db533f017b", "c74abb2c2c760855ac5fa794096ea89b9383dbbd0a2f567b3eff26794b65464b"),
}
PRODUCT_MANIFEST = "e5033187efce408aacaa5945e210ae66d0554dadf64eb2ca720153d25cec6224"
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


def bound(raw, expected, result, root=None):
    if root not in (None, ROOT) or raw != expected:
        raise ValueError("captured source binding differs")
    return result


def main():
    if any(value is None for value in (PRODUCT_BEFORE, PRODUCT_AFTER, PRODUCT_HASHES, PRODUCT_MANIFEST)):
        raise ValueError("ORDER-449 official translation product pins are not bound")
    protected = (*bridge.CURRENT_PATHS, HOLD, MAIN, SCALP, ARUBA, "systems/TexasHoldem.gd",
                 "scenes/TutorialOverlay.gd", "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", "tools/zh_translation_audit.py",
                 "tools/full_game_localization.py", "tools/holdem_banner_locale_receipt_check.py",
                 "tools/holdem_table_labels_receipt_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_TABLE_LABELS_HISTORY_449\n",
         "ad7ef41df091d595911863eccb2e52c5bc9fa9afbe284d784733fa006accc3c4"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_TABLE_LABELS_APPEND_449\n",
         "a558dea0b08e5f44f1875e5be1f94233c7704a26b02f40ae875a2316acbb34f1"),
    ):
        check("complete frozen prefix " + path, observed[path].count(marker) == 1
              and sha(observed[path].split(marker)[0]) == digest)
    collector_raw = observed["tools/ja_translation_pipeline.py"]
    check("sealed collector whole predecessor", sha(pipeline.holdem_table_labels_pipeline_predecessor(collector_raw))
          == "1a2878b702867a4baa22f0ce2480a749af4cb0c48ee070bba0e4396c8062ef32")
    rejects("collector appendix mutation", lambda: pipeline.holdem_table_labels_pipeline_predecessor(
        collector_raw.replace(b'"holdem_table_labels_added_calls": 5', b'"holdem_table_labels_added_calls": 6', 1)))
    check("prior focused remains unchanged and is not executed", observed["tools/holdem_banner_locale_receipt_check.py"]
          == bridge._git(ROOT, "show", "6608fc8a77ab4eeeb62cd909a67540a219fb4027:tools/holdem_banner_locale_receipt_check.py"))

    raw = observed[HOLD]
    check("actual display-only source pins", history.TABLE_LABELS_BEFORE_COMMIT == "6608fc8a77ab4eeeb62cd909a67540a219fb4027"
          and history.TABLE_LABELS_AFTER_COMMIT == "bf26b99fda084d90992fd4ac7f81349237eb3add"
          and history.TABLE_LABELS_TREES == ("3a8d3789988daea794d45e503ca42e27c6020cb2", "81c9f7eb08ba8815b0debf68fd8d0d08e26b24d8")
          and history.TABLE_LABELS_BLOBS == ("6b62466601cf2b7f5473a44ed3654e3fd10c5a2a", "76726b4709e14088b6c724a3279cf2cd3b0a54ab")
          and history.TABLE_LABELS_HASHES == ("766070551b1d23b9f1c70e74dc7419994b38c2b9c9911e449a649417bbb1d273",
                                             "0696814bcc6cf561b98b27eb342afaa50c25fbb25e85eab7e0b887eefc00e8d5"))
    real_git, trace, responses = history._git, [], {}
    def record(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=record):
        predecessors = history._holdem_table_labels_proof(raw, ROOT)
    previous = predecessors[0]
    prefixes = ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_", "MESSAGE_PULSE_", "BANNER_", "BANNER_LOCALE_", "TABLE_LABELS_")
    stages = tuple(tuple(getattr(history, prefix + key) for key in ("BEFORE_COMMIT", "AFTER_COMMIT", "TREES", "HASHES"))
                   for prefix in prefixes)
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("one actual nine-stage 54-request proof", len(predecessors) == 9 and len(requests) == 54
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    packet, cursor, ids = responses[(("cat-file", "--batch"), batch)], 0, []
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        ids.append(oid)
        cursor = end + 2 + int(size)
    check("46 distinct object identities and five newly added identities", cursor == len(packet)
          and len(set(ids)) == 46 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    check("exact five-line inverse preserves line count", len(history.TABLE_LABELS_REPLACEMENTS) == 5
          and raw.count(b"\n") == previous.count(b"\n")
          and history.holdem_table_labels_inverse(raw, previous) == previous)
    for name, changed in (
        ("outside byte", raw + b"\n"),
        ("amount", raw.replace(b'_fmt(_pot)]', b'_fmt(_pot + 1)]', 1)),
        ("zero bet condition", raw.replace(b'\tif bet > 0:\n', b'\tif bet >= 0:\n', 1)),
        ("pot spacing", raw.replace(b'"%s  %s" % [_tr(', b'"%s %s" % [_tr(', 1)),
        ("wrong Korean source", raw.replace('"보유 칩", "STACK"'.encode(), '"상금", "STACK"'.encode(), 1)),
    ):
        if changed == raw:
            raise AssertionError("ineffective source mutation " + name)
        rejects("exact inverse rejects " + name, lambda changed=changed: history.holdem_table_labels_inverse(changed, previous))
    with patch.object(history, "_holdem_table_labels_proof", return_value=predecessors):
        check("all nine predecessor meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_table_labels_predecessor, history.holdem_banner_locale_predecessor,
            history.holdem_banner_predecessor, history.holdem_message_pulse_predecessor,
            history.holdem_card_color_predecessor, history.holdem_async_predecessor,
            history.holdem_betting_predecessor, history.holdem_canvas_predecessor,
            history.holdem_money_predecessor)) == predecessors)
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured Git request")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, change in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.TABLE_LABELS_BEFORE_COMMIT), lambda value: value + b"M\0outside.gd\0"),
        ("stale current blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.TABLE_LABELS_BLOBS[0].encode() + b"\n"),
    ):
        def fault(root, *args, prefix=prefix, change=change, **kwargs):
            value = replay(root, *args, **kwargs)
            return change(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured Git " + name, lambda: history.holdem_table_labels_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay), patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
        rejects("captured final raw reread mismatch", lambda: history.holdem_table_labels_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("captured fresh Git failure")):
        rejects("success never caches next failure", lambda: history.holdem_table_labels_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        check("captured recovery", history.holdem_table_labels_predecessor(raw, ROOT) == previous)

    old_views, main_views = [], []
    real_rebind, real_main = pipeline._HOLDEM_TABLE_LABELS_OLD_REBIND, main_history._log_body_font_proof
    def capture_rebind(inventory, value, contract=None):
        result = real_rebind(inventory, value, contract)
        old_views.append(result)
        return result
    def capture_main(value, root=None):
        result = real_main(value, root)
        main_views.append(result)
        return result
    source_bound = lambda value, root=None: bound(value, raw, predecessors, root)
    with patch.object(history, "_holdem_table_labels_proof", side_effect=source_bound), \
         patch.object(pipeline, "_HOLDEM_TABLE_LABELS_OLD_REBIND", side_effect=capture_rebind), \
         patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one current collector and exact predecessor rebind", not current.errors and len(old_views) == 1 and bool(main_views))
    old_inventory = old_views[0]
    old_calls = tuple(c for c in old_inventory.calls if c.path == HOLD)
    live_calls = tuple(c for c in current.calls if c.path == HOLD)
    added = tuple(pipeline.UiCall(HOLD, function, line, "legacy", ko, en) for function, line, ko, en in (
        ("_render_table", 548, "팟", "POT"), ("_build_table_surface", 611, "팟", "POT"),
        ("_build_table_surface", 639, "공개 카드", "BOARD"), ("_build_holdem_seat", 783, "보유 칩", "STACK"),
        ("_build_holdem_seat", 785, "베팅", "BET")))
    check("retained66 plus five interleaved actual calls", len(old_calls) == 66 and len(live_calls) == 71
          and live_calls == tuple(sorted((*old_calls, *added), key=lambda c: (c.path, c.line, c.api))))
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("all retained Entry identities and order", tuple(identity(e) for e in current.entries if e.source not in KEYS)
          == tuple(identity(e) for e in old_inventory.entries)
          and {e.source for e in current.entries} - {e.source for e in old_inventory.entries} == set(KEYS)
          and all(e.key == "ui::holdem-table::" + hashlib.sha1(e.source.encode()).hexdigest()
                  for e in current.entries if e.source in KEYS))
    check("honest call key and money census", len(current.calls) == len(old_inventory.calls) + 5
          and len(current.legacy_entries) == len(old_inventory.legacy_entries) + 4
          and current.stats["holdem_table_labels_added_calls"] == 5 and current.stats["holdem_table_labels_added_keys"] == 4
          and current.stats["parameter_money_formatter_migrations"] == 3)

    main_raw, scalp_raw, aruba_raw = (observed[path] for path in (MAIN, SCALP, ARUBA))
    main_previous = main_views[0]
    check("captured Main predecessor population", len(main_previous) == 12 and all(row == main_previous for row in main_views))
    scalp_old, aruba_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw), bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    views = [{**hashes, HOLD: sha(value)} for value in (raw, *predecessors)]
    oldest = views[-1]
    views.append({**oldest, MAIN: sha(main_previous[0])})
    views.extend({**oldest, MAIN: sha(value), SCALP: sha(scalp_old)} for value in main_previous)
    views.append({**views[-1], ARUBA: sha(aruba_old)})
    allowed, supplied = {bridge.exchange.digest(value) for value in views}, census(hashes)
    saved = copy.deepcopy(supplied)
    check("24 distinct actual source lineage tuples", len(views) == len(allowed) == 24)
    with patch.object(history, "_holdem_table_labels_proof", side_effect=source_bound), \
         patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, root=None: bound(value, main_raw, main_previous, root)), \
         patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda root, value: bound(value, scalp_raw, scalp_old, root)), \
         patch.object(bridge, "aruba_font_predecessor", side_effect=lambda root, value: bound(value, aruba_raw, aruba_old, root)):
        check("synthetic census admits actual lineage only", all(bridge._source_manifest_matches(ROOT, supplied, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main, SCALP: scalp, ARUBA: aruba})
                    for main, scalp, aruba in itertools.product(tuple(map(sha, (main_raw, *main_previous))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("new Holdem rejects 51 phantom peer mixtures", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, supplied, digest) for digest in phantoms))
        rejects("stale supplied source census", lambda: bridge._source_manifest_matches(ROOT, census(views[1]), bridge.exchange.digest(views[1])))
        check("unknown source manifest rejected", not bridge._source_manifest_matches(ROOT, supplied, "0" * 64))
    check("supplied census is never mutated", supplied == saved)
    receipt_checks(current, observed)
    check("all observed product and support bytes preserved", all((ROOT / path).read_bytes() == value for path, value in observed.items())
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)])
    check("unique focused names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_TABLE_LABELS_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


def receipt_checks(current, observed):
    before = bridge._snapshot(ROOT, PRODUCT_BEFORE, bridge.CURRENT_PATHS)
    after = bridge._snapshot(ROOT, PRODUCT_AFTER, bridge.CURRENT_PATHS)
    check("observed four-path translation product", set(PRODUCT_HASHES) == set(bridge.CURRENT_PATHS)
          and all((sha(before[path]), sha(after[path])) == PRODUCT_HASHES[path] and after[path] == observed[path] for path in before)
          and bridge._git(ROOT, "rev-parse", PRODUCT_AFTER + "^").decode().strip() == PRODUCT_BEFORE
          and bridge._git(ROOT, "diff", "--name-status", "-z", PRODUCT_BEFORE, PRODUCT_AFTER)
          == b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(bridge.CURRENT_PATHS)))
    old, new = ({path: bridge._loads(value) for path, value in snapshot.items()} for snapshot in (before, after))
    ledger = bridge.LEDGER_PATH
    leaves = [bridge.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context") for key in KEYS]
    inventory = {"leaves": leaves}
    check("four actual new keys and twelve exact regional values", all(key in current.blueprint for key in KEYS)
          and all(all(key not in old[path] and new[path][key] == text for key, text in zip(KEYS, TEXTS[locale]))
                  for locale, path in zip(bridge.CURRENT_LOCALES, bridge.CURRENT_UI_PATHS)))
    change = bridge.validate_append(before, after, inventory)
    check("12 official new receipts in three batches", change["receipts"] == 12 and change["batches"] == 3
          and change["ui_by_locale"] == {locale: 4 for locale in TEXTS}
          and change["source_manifests"] == {PRODUCT_BEFORE: PRODUCT_MANIFEST}
          and len(old[ledger]["batches"]) == 224 and len(new[ledger]["batches"]) == 227
          and sum(map(len, old[ledger]["accepted"].values())) == 41741
          and sum(map(len, new[ledger]["accepted"].values())) == 41753
          and all(row["order"] == "ORDER-449" and set(row["roots"]) == set(KEYS) for row in new[ledger]["batches"][224:]))
    check("official export source is an actual ancestor", bridge._git(ROOT, "merge-base", "--is-ancestor", PRODUCT_BEFORE, PRODUCT_AFTER) == b"")
    def mutated(path, edit):
        document = copy.deepcopy(new[path])
        edit(document)
        if path == ledger:
            document["accepted_sha256"] = bridge.exchange.digest(document["accepted"])
        return {**after, path: bridge._ordered(document)}
    for name, path, edit in (
        ("old target", "locale/ui_ja.json", lambda doc: doc.__setitem__("폴드", "outside")),
        ("new target receipt mismatch", "locale/ui_ja.json", lambda doc: doc.__setitem__(KEYS[0], "間違い")),
        ("stale source hash", ledger, lambda doc: doc["accepted"]["ja"][leaves[0].id].__setitem__("source_sha256", "0" * 64)),
        ("wrong batch count", ledger, lambda doc: doc["batches"][224].__setitem__("source_leaves", 5)),
        ("old batch", ledger, lambda doc: doc["batches"][0].__setitem__("order", "outside")),
    ):
        rejects("synthetic receipt " + name, lambda path=path, edit=edit: bridge.validate_append(before, mutated(path, edit), inventory))
    rejects("missing actual source Leaf", lambda: bridge.validate_append(before, after, {"leaves": leaves[1:]}))
    rejects("raw bytes outside exact append", lambda: bridge.validate_append(
        before, {**after, "locale/ui_ja.json": after["locale/ui_ja.json"] + b"\n"}, inventory))


if __name__ == "__main__":
    raise SystemExit(main())
