#!/usr/bin/env python3
"""The exact five-line hand-net successor, with one current inventory.

Pure arithmetic and captured Git faults are not engine observations. No old
focused suite, private evidence, official exchange or engine is executed.
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
TABLE_KEYS = ("팟", "공개 카드", "보유 칩", "베팅")
DATA_HASHES = {
    "locale/ui_ja.json": "c056e24b20ad6e9711bce82eaaface23edc49d62d4598d397baf08ed5a7b2816",
    "locale/ui_zh-CN.json": "56aa8c8320624223159f6d0034121aef0b8699ec51788c095b96627be2b3e863",
    "locale/ui_zh-TW.json": "b589d1887d3660c9f3122e371ef5b28d06c258c23ddad18bfa6d8f5bef312ce0",
    bridge.LEDGER_PATH: "095d5e46dca4c4ddabcfde1f255565ff18f6cc913997238ca22ea812c102f53d",
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


def bound(raw, expected, result, root=None):
    if root not in (None, ROOT) or raw != expected:
        raise ValueError("captured source binding differs")
    return result


def census(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def pure_hand_net_checks(raw):
    """Source-bound arithmetic examples, not a replay of GDScript or poker rules."""
    text = raw.decode()
    check("snapshot is after insufficient-stack guard and before blinds",
          text.count("var _hand_start_stack: int = 0") == 1
          and text.count("\t_hand_start_stack = _player_stack\n") == 1
          and text.index("\tif _player_stack < BIG_BLIND:\n")
          < text.index("\t_hand_start_stack = _player_stack\n")
          < text.index("\t_post_blind(0, SMALL_BLIND, true)"))
    check("both payout branches share one hand-relative arithmetic expression",
          text.count("\t\thand_net = _player_stack - _hand_start_stack\n") == 2
          and text.count('_fmt(hand_net)])\n') == 1
          and '\t_showdown_net = hand_net\n' in text and '\t\t"net": hand_net,\n' in text)
    check("gross pot detail and real session cash expression remain distinct",
          '_showdown_detail = _tr("%s · POT %s 정산", "%s · POT %s settled") % [hand_rank_name, _fmt(_pot)]' in text
          and '\tvar net := _player_stack - _buy_in\n' in text
          and '\tGameState.add_money(float(_player_stack - _buy_in))\n' in text)
    samples = ((100_000, 90_000, 30_000, True, 120_000, 20_000),
               (120_000, 110_000, 30_000, False, 110_000, -10_000))
    outputs = []
    for start, before_payout, pot, won, wanted_stack, wanted_net in samples:
        settled = before_payout + (pot if won else 0)
        outputs.append((settled, settled - start))
        check("pure " + ("first win" if won else "next-hand loss"),
              (settled, settled - start) == (wanted_stack, wanted_net))
    check("pure two-hand totals equal unchanged session settlement",
          outputs[-1][0] - 100_000 == sum(net for _stack, net in outputs) == 10_000)
    check("street reset cannot reset the new hand baseline",
          '_player_bet = 0\n' in text.split('func _advance_phase() -> void:', 1)[1].split('func _do_showdown()', 1)[0]
          and '_hand_start_stack' not in text.split('func _advance_phase() -> void:', 1)[1].split('func _do_showdown()', 1)[0]
          and all(before_payout + (pot if won else 0) - start == wanted_net
                  for start, before_payout, pot, won, _wanted_stack, wanted_net in samples))


def main():
    protected = (*bridge.CURRENT_PATHS, HOLD, MAIN, SCALP, ARUBA, "systems/TexasHoldem.gd",
                 "scenes/TutorialOverlay.gd", "autoloads/GameState.gd", "autoloads/MetaProgression.gd",
                 "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", "tools/zh_translation_audit.py",
                 "tools/full_game_localization.py", "tools/holdem_residual_locale_check.py",
                 "tools/holdem_hand_net_receipt_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_HAND_NET_HISTORY_452\n",
         "a3f9a90526f1a7c6eec3860f8b54d71dc2e89f551b6e5f2340ba255483db4edc"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_HAND_NET_APPEND_452\n",
         "1d468c812117545917d02cfec6efe84949ebe18fe14fbe6bf5fb65f8bcd12339"),
    ):
        check("complete frozen prefix " + path, observed[path].count(marker) == 1
              and sha(observed[path].split(marker)[0]) == digest)
    check("collector and previous focused are sealed, never re-executed here",
          sha(observed["tools/ja_translation_pipeline.py"]) == "f45887eb301871177cbd47d3c5013e4a5a68a3e578cdb1e1a3a6a42c81b621ca"
          and sha(observed["tools/holdem_residual_locale_check.py"]) == "3cb1668061c87c670ef1d4535bb48230dd6a0f148e8fa10fdd6ada46a9d47244")
    check("all four accepted dictionaries and ledger bytes are unchanged",
          set(DATA_HASHES) == set(bridge.CURRENT_PATHS)
          and all(sha(observed[path]) == digest for path, digest in DATA_HASHES.items()))
    ledger = bridge._loads(observed[bridge.LEDGER_PATH])
    check("451 final canonical receipt and coverage stay unchanged",
          sum(len(rows) for rows in ledger["accepted"].values()) == 41755 and len(ledger["batches"]) == 228
          and ledger["accepted_sha256"] == bridge.exchange.digest(ledger["accepted"])
          and ledger["batches"][-1]["order"] == "ORDER-451"
          and ledger["batches"][-1]["receipt_sha256_by_locale"]["ja"] == "6012dda18bc67c32603dc6fcf4a4ce631fe4a2bee62d35c90ca9b06b8b977109"
          and tuple(len(bridge._loads(observed[p])) for p in bridge.CURRENT_UI_PATHS) == (3053, 1776, 1776))
    raw = observed[HOLD]
    check("actual five-line product pins",
          history.HAND_NET_BEFORE_COMMIT == "1a31721cb583586c8a4649a4c4950e82ab02fbe1"
          and history.HAND_NET_AFTER_COMMIT == "ffc99a1f7ee19f6f8de36eed4729395a83dbdf65"
          and history.HAND_NET_TREES == ("9c356359cc6a50f40bd6e98994908313f47d0ec9", "23214ad2801ac7af00644fc8e341803b989beecd")
          and history.HAND_NET_BLOBS == ("8567df0f9c02a969b08bf49d2415d349e0e14ab1", "5ef770fb2f05653ef4203038ed01826173e98858")
          and history.HAND_NET_HASHES == ("680c36f92b2d6d6615c24fa0bb1b36d0f51c59436004eb58170d370d481783b7",
                                          "be542f9f6f583a6a2bb2cf849a8d5b56bcd4ec306912a3465fbb9e0a87467e75"))
    real_git, trace, responses = history._git, [], {}
    def record(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=record):
        predecessors = history._holdem_hand_net_proof(raw, ROOT)
    previous = predecessors[0]
    prefixes = ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_", "MESSAGE_PULSE_", "BANNER_",
                "BANNER_LOCALE_", "TABLE_LABELS_", "SEAT_HEIGHT_", "FOLDED_LOCALE_", "HAND_NET_")
    stages = tuple(tuple(getattr(history, prefix + key) for key in ("BEFORE_COMMIT", "AFTER_COMMIT", "TREES", "HASHES"))
                   for prefix in prefixes)
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("one actual twelve-stage 72-request proof", len(predecessors) == 12 and len(requests) == 72
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    packet, cursor, ids = responses[(("cat-file", "--batch"), batch)], 0, []
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        ids.append(oid)
        cursor = end + 2 + int(size)
    check("61 distinct identities with five newly added identities", cursor == len(packet)
          and len(set(ids)) == 61 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    check("whole inverse changes only the five declared rows",
          history.holdem_hand_net_inverse(raw, previous) == previous and raw.count(b"\n") == previous.count(b"\n")
          and [i for i, (a, b) in enumerate(zip(previous.splitlines(), raw.splitlines()), 1) if a != b]
          == [49, 355, 1207, 1210, 1218])
    parsed = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    check("all 71 UiCall coordinates owners and literals unchanged", not any(errors for _calls, errors in parsed)
          and len(parsed[0][0]) == 71 and parsed[0][0] == parsed[1][0])
    for name, changed in (
        ("outside byte", raw + b"\n"),
        ("buy-in instead of hand baseline", raw.replace(b"hand_net = _player_stack - _hand_start_stack", b"hand_net = _player_stack - _buy_in", 1)),
        ("gross victory message", raw.replace(b"_fmt(hand_net)])", b"_fmt(_pot)])", 1)),
        ("post-blind baseline", raw.replace(b"_hand_start_stack = _player_stack\n", b"_hand_start_stack = _player_stack - SMALL_BLIND\n", 1)),
        ("real payout", raw.replace(b"_player_stack += _pot\n", b"_player_stack += _pot + 1\n", 1)),
    ):
        if changed == raw:
            raise AssertionError("ineffective source mutation " + name)
        rejects("exact inverse rejects " + name, lambda changed=changed: history.holdem_hand_net_inverse(changed, previous))
    pure_hand_net_checks(raw)
    source_bound = lambda value, root=None: bound(value, raw, predecessors, root)
    with patch.object(history, "_holdem_hand_net_proof", side_effect=source_bound):
        check("all twelve public predecessors retain their exact meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_hand_net_predecessor, history.holdem_folded_locale_predecessor,
            history.holdem_seat_height_predecessor, history.holdem_table_labels_predecessor,
            history.holdem_banner_locale_predecessor, history.holdem_banner_predecessor,
            history.holdem_message_pulse_predecessor, history.holdem_card_color_predecessor,
            history.holdem_async_predecessor, history.holdem_betting_predecessor,
            history.holdem_canvas_predecessor, history.holdem_money_predecessor)) == predecessors
              and history._holdem_folded_locale_proof(raw, ROOT) == predecessors[1:]
              and history._holdem_seat_height_proof(raw, ROOT) == predecessors[2:]
              and history._holdem_table_labels_proof(raw, ROOT) == predecessors[3:])
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured Git request")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, change in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.HAND_NET_BEFORE_COMMIT), lambda value: value + b"M\0outside.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.HAND_NET_BLOBS[0].encode() + b"\n"),
    ):
        def fault(root, *args, prefix=prefix, change=change, **kwargs):
            value = replay(root, *args, **kwargs)
            return change(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured Git " + name, lambda: history.holdem_hand_net_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay), patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
        rejects("captured final raw reread mismatch", lambda: history.holdem_hand_net_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("captured fresh Git failure")):
        rejects("success never caches the next failure", lambda: history.holdem_hand_net_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        rejects("unsupported current source", lambda: history.holdem_hand_net_predecessor(raw + b"\n", ROOT))
        check("captured recovery", history.holdem_hand_net_predecessor(raw, ROOT) == previous)

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
    with patch.object(history, "_holdem_hand_net_proof", side_effect=source_bound), \
         patch.object(pipeline, "_HOLDEM_TABLE_LABELS_OLD_REBIND", side_effect=capture_rebind), \
         patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one current collector using unchanged rebind", not current.errors and len(old_views) == 1 and bool(main_views))
    retained = old_views[0]
    identity = lambda entry: (entry.key, entry.source, entry.source_hash, entry.context_id, entry.format_template)
    check("same current 71 calls and all retained Entry identities",
          tuple(c for c in current.calls if c.path == HOLD) == tuple(parsed[0][0])
          and len(current.calls) == len(retained.calls) + 5
          and tuple(identity(e) for e in current.entries if e.source not in TABLE_KEYS) == tuple(identity(e) for e in retained.entries)
          and {e.source for e in current.entries} - {e.source for e in retained.entries} == set(TABLE_KEYS)
          and all(e.key == "ui::holdem-table::" + hashlib.sha1(e.source.encode()).hexdigest()
                  for e in current.entries if e.source in TABLE_KEYS)
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
    check("27 distinct actual source lineage tuples", len(views) == len(allowed) == 27)
    with patch.object(history, "_holdem_hand_net_proof", side_effect=source_bound), \
         patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, root=None: bound(value, main_raw, main_previous, root)), \
         patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda root, value: bound(value, scalp_raw, scalp_old, root)), \
         patch.object(bridge, "aruba_font_predecessor", side_effect=lambda root, value: bound(value, aruba_raw, aruba_old, root)):
        check("synthetic census admits the actual source lineage", all(bridge._source_manifest_matches(ROOT, supplied, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main, SCALP: scalp, ARUBA: aruba})
                    for main, scalp, aruba in itertools.product(tuple(map(sha, (main_raw, *main_previous))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("new Holdem rejects 51 phantom peer mixtures", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, supplied, digest) for digest in phantoms))
        rejects("stale supplied source census", lambda: bridge._source_manifest_matches(ROOT, census(views[1]), bridge.exchange.digest(views[1])))
        rejects("tampered census digest", lambda: bridge._source_manifest_matches(ROOT, {**supplied, "source_manifest_sha256": "0" * 64}, "0" * 64))
        check("unknown source manifest rejected", not bridge._source_manifest_matches(ROOT, supplied, "0" * 64))
    check("supplied census is never mutated", supplied == saved)
    check("all observed product and support bytes preserved", all((ROOT / path).read_bytes() == value for path, value in observed.items())
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)])
    check("unique focused names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_HAND_NET_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
