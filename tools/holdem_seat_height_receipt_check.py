#!/usr/bin/env python3
"""One height delta and one current collector; old 449 failure stays a failure.

Captured Git replay and supplied census counterexamples are synthetic evidence.
No old focused suite, official import, engine or private artifact is executed.
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
import holdem_table_labels_receipt_check as labels  # Sealed constants only, no old tests.
import ja_translation_pipeline as pipeline
import main_game_locale_history as main_history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
HOLD = history.HOLDEM_PATH
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


def bound(raw, expected, result, root=None):
    if root not in (None, ROOT) or raw != expected:
        raise ValueError("captured source binding differs")
    return result


def census(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def main():
    protected = (*bridge.CURRENT_PATHS, HOLD, MAIN, SCALP, ARUBA, "systems/TexasHoldem.gd",
                 "scenes/TutorialOverlay.gd", "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", "tools/zh_translation_audit.py",
                 "tools/full_game_localization.py", "tools/holdem_table_labels_receipt_check.py",
                 "tools/holdem_seat_height_receipt_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_SEAT_HEIGHT_HISTORY_450\n",
         "fd8cafd3800ca55143efafd6ab8a8412e7e47afd3d26b9a1bfa9e5c822f25456"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_SEAT_HEIGHT_APPEND_450\n",
         "c2dc6808e5a5bd50199db572b402b173c3f87d6236c2e936d7a14a06f52032bc"),
    ):
        check("complete frozen prefix " + path, observed[path].count(marker) == 1
              and sha(observed[path].split(marker)[0]) == digest)
    check("collector whole bytes unchanged", sha(observed["tools/ja_translation_pipeline.py"])
          == "f45887eb301871177cbd47d3c5013e4a5a68a3e578cdb1e1a3a6a42c81b621ca")
    check("449 focused sealed and never executed", sha(observed["tools/holdem_table_labels_receipt_check.py"])
          == "59f9a42db9c8a3ff8842894ed68df7983a3214c3c20e14dcd4649440df0d5d64" and not labels.CASES)
    raw = observed[HOLD]
    check("actual one-line product pins", history.SEAT_HEIGHT_BEFORE_COMMIT == "9c27eee1bd6e7d58647858467b63b8ce6dab0f01"
          and history.SEAT_HEIGHT_AFTER_COMMIT == "138caec7c696b8da4a037a833a0a6dafbfeafa5d"
          and history.SEAT_HEIGHT_TREES == ("53c9a4f2af63652c12b44636e61e06b887191bbc", "31227138d1ef021d2f5c839ceecebbb9d536baf0")
          and history.SEAT_HEIGHT_BLOBS == ("76726b4709e14088b6c724a3279cf2cd3b0a54ab", "21629ab8c05c2f59ed60399ac40d961ffc9d5781")
          and history.SEAT_HEIGHT_HASHES == ("0696814bcc6cf561b98b27eb342afaa50c25fbb25e85eab7e0b887eefc00e8d5",
                                             "822649f2d8db329c834591fb568424fbacda25be21640ed04f88775429e9a9d9"))
    real_git, trace, responses = history._git, [], {}
    def record(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=record):
        predecessors = history._holdem_seat_height_proof(raw, ROOT)
    previous = predecessors[0]
    prefixes = ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_", "MESSAGE_PULSE_", "BANNER_",
                "BANNER_LOCALE_", "TABLE_LABELS_", "SEAT_HEIGHT_")
    stages = tuple(tuple(getattr(history, prefix + key) for key in ("BEFORE_COMMIT", "AFTER_COMMIT", "TREES", "HASHES"))
                   for prefix in prefixes)
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("one actual ten-stage 60-request proof", len(predecessors) == 10 and len(requests) == 60
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    packet, cursor, ids = responses[(("cat-file", "--batch"), batch)], 0, []
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        ids.append(oid)
        cursor = end + 2 + int(size)
    check("51 distinct object identities and five added identities", cursor == len(packet)
          and len(set(ids)) == 51 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    check("whole inverse changes only line585 height", history.holdem_seat_height_inverse(raw, previous) == previous
          and raw.count(b"\n") == previous.count(b"\n")
          and [(i, a, b) for i, (a, b) in enumerate(zip(previous.splitlines(), raw.splitlines()), 1) if a != b]
          == [(585, b"\ttable.custom_minimum_size = Vector2(0, 360)", b"\ttable.custom_minimum_size = Vector2(0, 420)")])
    parsed = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    check("all 71 UiCall coordinates owners and literals unchanged", not any(errors for _calls, errors in parsed)
          and len(parsed[0][0]) == 71 and parsed[0][0] == parsed[1][0])
    for name, changed in (
        ("outside byte", raw + b"\n"),
        ("height419", raw.replace(b"Vector2(0, 420)", b"Vector2(0, 419)", 1)),
        ("player anchor", raw.replace(b"0.36, 0.72, 0.64, 0.98", b"0.36, 0.72, 0.64, 0.99", 1)),
        ("money", raw.replace(b"_fmt(_pot)]", b"_fmt(_pot + 1)]", 1)),
    ):
        if changed == raw:
            raise AssertionError("ineffective source mutation " + name)
        rejects("exact inverse rejects " + name, lambda changed=changed: history.holdem_seat_height_inverse(changed, previous))
    source_bound = lambda value, root=None: bound(value, raw, predecessors, root)
    with patch.object(history, "_holdem_seat_height_proof", side_effect=source_bound):
        check("all ten public predecessor meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_seat_height_predecessor, history.holdem_table_labels_predecessor,
            history.holdem_banner_locale_predecessor, history.holdem_banner_predecessor,
            history.holdem_message_pulse_predecessor, history.holdem_card_color_predecessor,
            history.holdem_async_predecessor, history.holdem_betting_predecessor,
            history.holdem_canvas_predecessor, history.holdem_money_predecessor)) == predecessors
              and history._holdem_table_labels_proof(raw, ROOT) == predecessors[1:])
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured Git request")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, change in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.SEAT_HEIGHT_BEFORE_COMMIT), lambda value: value + b"M\0outside.gd\0"),
        ("stale current blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.SEAT_HEIGHT_BLOBS[0].encode() + b"\n"),
    ):
        def fault(root, *args, prefix=prefix, change=change, **kwargs):
            value = replay(root, *args, **kwargs)
            return change(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured Git " + name, lambda: history.holdem_seat_height_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay), patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
        rejects("captured final raw reread mismatch", lambda: history.holdem_seat_height_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("captured fresh Git failure")):
        rejects("success never caches next failure", lambda: history.holdem_seat_height_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        rejects("unsupported current source", lambda: history.holdem_seat_height_predecessor(raw + b"\n", ROOT))
        check("captured recovery", history.holdem_seat_height_predecessor(raw, ROOT) == previous)

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
    with patch.object(history, "_holdem_seat_height_proof", side_effect=source_bound), \
         patch.object(pipeline, "_HOLDEM_TABLE_LABELS_OLD_REBIND", side_effect=capture_rebind), \
         patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one current collector with unchanged rebind", not current.errors and len(old_views) == 1 and bool(main_views))
    old_inventory = old_views[0]
    check("current calls equal actual 449 calls", tuple(c for c in current.calls if c.path == HOLD) == tuple(parsed[0][0])
          and len(current.calls) == len(old_inventory.calls) + 5
          and len(current.legacy_entries) == len(old_inventory.legacy_entries) + 4
          and current.stats["holdem_table_labels_added_calls"] == 5 and current.stats["holdem_table_labels_added_keys"] == 4
          and current.stats["parameter_money_formatter_migrations"] == 3)
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("same retained identities and four 449 Entry IDs no new leaf", tuple(identity(e) for e in current.entries if e.source not in labels.KEYS)
          == tuple(identity(e) for e in old_inventory.entries)
          and {e.source for e in current.entries} - {e.source for e in old_inventory.entries} == set(labels.KEYS)
          and all(e.key == "ui::holdem-table::" + hashlib.sha1(e.source.encode()).hexdigest()
                  for e in current.entries if e.source in labels.KEYS))

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
    check("25 distinct actual source lineage tuples", len(views) == len(allowed) == 25)
    with patch.object(history, "_holdem_seat_height_proof", side_effect=source_bound), \
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
        rejects("tampered census digest", lambda: bridge._source_manifest_matches(ROOT, {**supplied, "source_manifest_sha256": "0" * 64}, "0" * 64))
        check("unknown source manifest rejected", not bridge._source_manifest_matches(ROOT, supplied, "0" * 64))
    check("supplied census is never mutated", supplied == saved)
    receipt_checks(current, observed)
    check("all observed product and support bytes preserved", all((ROOT / path).read_bytes() == value for path, value in observed.items())
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)] and not labels.CASES)
    check("unique focused names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_SEAT_HEIGHT_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


def receipt_checks(current, observed):
    """Recheck the existing 449 product, not an import or reissued 449 verdict."""
    before = bridge._snapshot(ROOT, labels.PRODUCT_BEFORE, bridge.CURRENT_PATHS)
    after = bridge._snapshot(ROOT, labels.PRODUCT_AFTER, bridge.CURRENT_PATHS)
    check("observed 449 four-path translation product unchanged", set(labels.PRODUCT_HASHES) == set(bridge.CURRENT_PATHS)
          and all((sha(before[path]), sha(after[path])) == labels.PRODUCT_HASHES[path]
                  and after[path] == observed[path] for path in before)
          and bridge._git(ROOT, "rev-parse", labels.PRODUCT_AFTER + "^").decode().strip() == labels.PRODUCT_BEFORE
          and bridge._git(ROOT, "diff", "--name-status", "-z", labels.PRODUCT_BEFORE, labels.PRODUCT_AFTER)
          == b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(bridge.CURRENT_PATHS)))
    old, new = ({path: bridge._loads(value) for path, value in snapshot.items()} for snapshot in (before, after))
    ledger = bridge.LEDGER_PATH
    leaves = [bridge.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context") for key in labels.KEYS]
    inventory = {"leaves": leaves}
    check("existing four keys and twelve exact regional values", all(key in current.blueprint for key in labels.KEYS)
          and all(all(key not in old[path] and new[path][key] == text for key, text in zip(labels.KEYS, labels.TEXTS[locale]))
                  for locale, path in zip(bridge.CURRENT_LOCALES, bridge.CURRENT_UI_PATHS)))
    change = bridge.validate_append(before, after, inventory)
    check("preserved 12 receipts three batches no new acceptance", change["receipts"] == 12 and change["batches"] == 3
          and change["ui_by_locale"] == {locale: 4 for locale in labels.TEXTS}
          and change["source_manifests"] == {labels.PRODUCT_BEFORE: labels.PRODUCT_MANIFEST}
          and len(old[ledger]["batches"]) == 224 and len(new[ledger]["batches"]) == 227
          and sum(map(len, old[ledger]["accepted"].values())) == 41741
          and sum(map(len, new[ledger]["accepted"].values())) == 41753
          and all(row["order"] == "ORDER-449" and set(row["roots"]) == set(labels.KEYS) for row in new[ledger]["batches"][224:]))
    for name, path, edit in (
        ("target receipt mismatch", "locale/ui_ja.json", lambda doc: doc.__setitem__(labels.KEYS[0], "間違い")),
        ("stale source hash", ledger, lambda doc: doc["accepted"]["ja"][leaves[0].id].__setitem__("source_sha256", "0" * 64)),
        ("old batch", ledger, lambda doc: doc["batches"][0].__setitem__("order", "outside")),
    ):
        document = copy.deepcopy(new[path])
        edit(document)
        if path == ledger:
            document["accepted_sha256"] = bridge.exchange.digest(document["accepted"])
        changed = {**after, path: bridge._ordered(document)}
        rejects("synthetic existing receipt " + name, lambda changed=changed: bridge.validate_append(before, changed, inventory))
    rejects("missing actual source Leaf", lambda: bridge.validate_append(before, after, {"leaves": leaves[1:]}))
    rejects("raw bytes outside exact append", lambda: bridge.validate_append(
        before, {**after, "locale/ui_ja.json": after["locale/ui_ja.json"] + b"\n"}, inventory))


if __name__ == "__main__":
    raise SystemExit(main())
