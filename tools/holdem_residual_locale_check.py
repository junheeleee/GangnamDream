#!/usr/bin/env python3
"""One folded-prefix source delta and two legacy Japanese target corrections.

Captured fault replay and pure locale branches are not engine observations.
No old focused suite, official import, engine or private artifact is executed.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import json
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
DISPATCHER = "        elif commit == LEGACY_RESIDUAL_INTERMEDIATE_COMMIT:\n            before, after, change = _legacy_ja_residual_proof(root, inventory)\n            middle = _snapshot(root, LEGACY_RESIDUAL_INTERMEDIATE_COMMIT, CURRENT_PATHS)\n            require(residual_pending is None and set(paths) == set(CURRENT_PATHS)\n                    and previous == before and successor == middle,\n                    \"legacy JA residual intermediate lineage differs\")\n            residual_pending = (before, middle, after, change)\n            change = {\"ui_by_locale\": {loc: 0 for loc in CURRENT_LOCALES}, \"receipts\": 0, \"batches\": 0, \"source_manifests\": {}}\n        elif commit == LEGACY_RESIDUAL_AFTER_COMMIT:\n            require(residual_pending is not None, \"legacy JA residual final lacks its exact intermediate\")\n            before, middle, after, change = residual_pending\n            require(parents == [LEGACY_RESIDUAL_INTERMEDIATE_COMMIT] and previous == middle and successor == after,\n                    \"legacy JA residual lineage or protected locale differs\")\n            corrections.append((_legacy_ja_residual_comparison, before, after))\n            residual_pending = None\n".encode()
HISTORY_INSERTS = tuple(value.encode() for value in ["    residual_pending = None  # Exact ORDER-451 two-commit delivery only.\n","        require(residual_pending is None or commit == LEGACY_RESIDUAL_AFTER_COMMIT, \"legacy JA residual delivery interrupted\")\n","    require(residual_pending is None, \"legacy JA residual intermediate cannot be a final candidate\")\n"])
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


def preserved_prefix(raw):
    for addition in (DISPATCHER, *HISTORY_INSERTS):
        raw = raw.replace(addition, b"")
    return raw


def main():
    protected = (*bridge.CURRENT_PATHS, HOLD, MAIN, SCALP, ARUBA, "systems/TexasHoldem.gd",
                 "scenes/TutorialOverlay.gd", "tools/holdem_money_history.py", "tools/ui_translation_append.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", "tools/zh_translation_audit.py",
                 "tools/full_game_localization.py", "tools/holdem_seat_height_receipt_check.py",
                 "tools/holdem_residual_locale_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_FOLDED_LOCALE_HISTORY_451\n",
         "f57cb15635d08c6ae0ee49d5166912ad74fbd8e298589947ebae9db3c4990ff5"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_FOLDED_LOCALE_APPEND_451\n",
         "2364184123a35accd96b5095144cf667474fe4fce544f27d13e09e6b2fc7587e"),
    ):
        check("complete frozen prefix " + path, observed[path].count(marker) == 1
              and sha(preserved_prefix(observed[path].split(marker)[0])) == digest)
    check("collector whole bytes unchanged", sha(observed["tools/ja_translation_pipeline.py"])
          == "f45887eb301871177cbd47d3c5013e4a5a68a3e578cdb1e1a3a6a42c81b621ca")
    check("450 focused sealed and not imported or executed", sha(observed["tools/holdem_seat_height_receipt_check.py"])
          == "845873416e51b9ecb2495eabdde30d97db3ab3fb346e1a038641c4e729bf2cf4")
    check("one exact new dispatcher and three pending guards", all(observed["tools/ui_translation_append.py"].count(part) == 1
          for part in (DISPATCHER, *HISTORY_INSERTS)))
    raw = observed[HOLD]
    check("actual one-line product pins", history.FOLDED_LOCALE_BEFORE_COMMIT == "ea29309512066d5eb16452d1669b9f1b9389fe66"
          and history.FOLDED_LOCALE_AFTER_COMMIT == "85f54835ae63aa2f0ec728594fbf699fd0eca07c"
          and history.FOLDED_LOCALE_TREES == ("ccf89ba9c4960cf2b525c50b66848c88c5af4184", "45ac823cca51eb9a365208b1053a048723ed2287")
          and history.FOLDED_LOCALE_BLOBS == ("21629ab8c05c2f59ed60399ac40d961ffc9d5781", "8567df0f9c02a969b08bf49d2415d349e0e14ab1")
          and history.FOLDED_LOCALE_HASHES == ("822649f2d8db329c834591fb568424fbacda25be21640ed04f88775429e9a9d9",
                                               "680c36f92b2d6d6615c24fa0bb1b36d0f51c59436004eb58170d370d481783b7"))
    real_git, trace, responses = history._git, [], {}
    def record(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=record):
        predecessors = history._holdem_folded_locale_proof(raw, ROOT)
    previous = predecessors[0]
    prefixes = ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_", "MESSAGE_PULSE_", "BANNER_",
                "BANNER_LOCALE_", "TABLE_LABELS_", "SEAT_HEIGHT_", "FOLDED_LOCALE_")
    stages = tuple(tuple(getattr(history, prefix + key) for key in ("BEFORE_COMMIT", "AFTER_COMMIT", "TREES", "HASHES"))
                   for prefix in prefixes)
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("one actual eleven-stage 66-request proof", len(predecessors) == 11 and len(requests) == 66
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    packet, cursor, ids = responses[(("cat-file", "--batch"), batch)], 0, []
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split()
        ids.append(oid)
        cursor = end + 2 + int(size)
    check("56 distinct object identities and five added identities", cursor == len(packet)
          and len(set(ids)) == 56 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    check("whole inverse changes only line758 folded prefix", history.holdem_folded_locale_inverse(raw, previous) == previous
          and raw.count(b"\n") == previous.count(b"\n")
          and [(i, a, b) for i, (a, b) in enumerate(zip(previous.splitlines(), raw.splitlines()), 1) if a != b]
          == [(758, *[value.rstrip("\n").encode() for value in history.FOLDED_LOCALE_REPLACEMENT])])
    parsed = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    check("all 71 UiCall coordinates owners and literals unchanged", not any(errors for _calls, errors in parsed)
          and len(parsed[0][0]) == 71 and parsed[0][0] == parsed[1][0])
    for name, changed in (
        ("outside byte", raw + b"\n"),
        ("unexpected locale", raw.replace(b'["ko", "ja", "zh-CN", "zh-TW"]', b'["ko", "ja", "zh-CN", "zh-TW", "en"]', 1)),
        ("spacing", raw.replace(b'else "FOLDED") + "  " if folded', b'else "FOLDED") + " " if folded', 1)),
        ("money", raw.replace(b"_fmt(_pot)]", b"_fmt(_pot + 1)]", 1)),
    ):
        if changed == raw:
            raise AssertionError("ineffective source mutation " + name)
        rejects("exact inverse rejects " + name, lambda changed=changed: history.holdem_folded_locale_inverse(changed, previous))
    pure_prefix_checks(raw, observed)
    source_bound = lambda value, root=None: bound(value, raw, predecessors, root)
    with patch.object(history, "_holdem_folded_locale_proof", side_effect=source_bound):
        check("all eleven public predecessor meanings", tuple(fn(raw, ROOT) for fn in (
            history.holdem_folded_locale_predecessor, history.holdem_seat_height_predecessor,
            history.holdem_table_labels_predecessor,
            history.holdem_banner_locale_predecessor, history.holdem_banner_predecessor,
            history.holdem_message_pulse_predecessor, history.holdem_card_color_predecessor,
            history.holdem_async_predecessor, history.holdem_betting_predecessor,
            history.holdem_canvas_predecessor, history.holdem_money_predecessor)) == predecessors
              and history._holdem_table_labels_proof(raw, ROOT) == predecessors[2:]
              and history._holdem_seat_height_proof(raw, ROOT) == predecessors[1:])
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured Git request")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, change in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff", "--name-status", "-z", history.FOLDED_LOCALE_BEFORE_COMMIT), lambda value: value + b"M\0outside.gd\0"),
        ("stale current blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.FOLDED_LOCALE_BLOBS[0].encode() + b"\n"),
    ):
        def fault(root, *args, prefix=prefix, change=change, **kwargs):
            value = replay(root, *args, **kwargs)
            return change(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured Git " + name, lambda: history.holdem_folded_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay), patch.object(Path, "read_bytes", side_effect=(raw, raw + b"\n")):
        rejects("captured final raw reread mismatch", lambda: history.holdem_folded_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("captured fresh Git failure")):
        rejects("success never caches next failure", lambda: history.holdem_folded_locale_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        rejects("unsupported current source", lambda: history.holdem_folded_locale_predecessor(raw + b"\n", ROOT))
        check("captured recovery", history.holdem_folded_locale_predecessor(raw, ROOT) == previous)

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
    with patch.object(history, "_holdem_folded_locale_proof", side_effect=source_bound), \
         patch.object(pipeline, "_HOLDEM_TABLE_LABELS_OLD_REBIND", side_effect=capture_rebind), \
         patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one current collector with unchanged rebind", not current.errors and len(old_views) == 1 and bool(main_views))
    old_inventory = old_views[0]
    check("current calls equal actual 450 calls", tuple(c for c in current.calls if c.path == HOLD) == tuple(parsed[0][0])
          and len(current.calls) == len(old_inventory.calls) + 5
          and len(current.legacy_entries) == len(old_inventory.legacy_entries) + 4
          and current.stats["holdem_table_labels_added_calls"] == 5 and current.stats["holdem_table_labels_added_keys"] == 4
          and current.stats["parameter_money_formatter_migrations"] == 3)
    identity = lambda e: (e.key, e.source, e.source_hash, e.context_id, e.format_template)
    check("same retained identities and four 449 Entry IDs no new leaf", tuple(identity(e) for e in current.entries if e.source not in TABLE_KEYS)
          == tuple(identity(e) for e in old_inventory.entries)
          and {e.source for e in current.entries} - {e.source for e in old_inventory.entries} == set(TABLE_KEYS)
          and all(e.key == "ui::holdem-table::" + hashlib.sha1(e.source.encode()).hexdigest()
                  for e in current.entries if e.source in TABLE_KEYS))

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
    check("26 distinct actual source lineage tuples", len(views) == len(allowed) == 26)
    with patch.object(history, "_holdem_folded_locale_proof", side_effect=source_bound), \
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
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)])
    check("unique focused names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_RESIDUAL_LOCALE_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0



def pure_prefix_checks(raw, observed):
    """A source-bound pure branch table, explicitly not executed GDScript."""
    line = history.FOLDED_LOCALE_REPLACEMENT[1]
    locale_literal = line.split("LocaleManager.language in ", 1)[1].split(' else "FOLDED"', 1)[0]
    allowed = json.loads(locale_literal)
    tables = {locale: bridge._loads(observed[path]) for locale, path in zip(bridge.CURRENT_LOCALES, bridge.CURRENT_UI_PATHS)}
    expected = {"ko": "폴드", "en": "FOLDED", "ja": "フォールド", "zh-CN": "弃牌", "zh-TW": "棄牌",
                "mod-example": "FOLDED", "": "FOLDED"}
    check("exact four locale source allowlist and retained action consumer",
          allowed == ["ko", "ja", "zh-CN", "zh-TW"] and raw.count(line.encode()) == 1
          and raw.count('\t\t"fold": return _tr("폴드", "Fold")\n'.encode()) == 1)
    title = "source-bound seat"
    results = []
    for locale, wanted in expected.items():
        label = "폴드" if locale == "ko" else tables.get(locale, {}).get("폴드", "Fold")
        for folded in (False, True):
            actual = ((label if locale in allowed else "FOLDED") + "  " if folded else "") + title
            results.append(actual == ((wanted + "  ") if folded else "") + title)
    check("pure seven locale folded and unfolded prefix table not runtime", len(results) == 14 and all(results))


def receipt_checks(current, observed):
    keys = bridge.LEGACY_RESIDUAL_KEYS
    leaves = [bridge.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context") for key in keys]
    inventory = {"leaves": leaves}
    real_git, calls, responses = bridge._git, [], {}
    def record(root, *args, **kwargs):
        value = real_git(root, *args, **kwargs)
        item = (args, kwargs.get("input"))
        calls.append(item)
        responses[item] = value
        return value
    with patch.object(bridge, "_git", side_effect=record):
        before, after, change = bridge._legacy_ja_residual_proof(ROOT, inventory)
    ledger, ja = bridge.LEDGER_PATH, bridge.LEGACY_RESIDUAL_PATH
    old, new = ({path: bridge._loads(raw) for path, raw in snapshot.items()} for snapshot in (before, after))
    check("one actual data proof including legacy origin blob",
          len([data for args, data in calls if args == ("cat-file", "--batch")]) == 1
          and len(next(data for args, data in calls if args == ("cat-file", "--batch")).splitlines()) == 19
          and bridge.LEGACY_RESIDUAL_BEFORE_COMMIT == "33b9d28243e581b74ed12fc1a1d1eb23e004705c"
          and bridge.LEGACY_RESIDUAL_INTERMEDIATE_COMMIT == "7aa0cd22d0b03b4b76a16c3445d70af30acad812"
          and bridge.LEGACY_RESIDUAL_AFTER_COMMIT == "2fdf4353d4769dfb40f35da1added7de27aff354"
          and bridge.LEGACY_RESIDUAL_TREES == ("77bcc73b16e6c034ecf1e031b9fc973af63152cf", "af910858c761bde8009cec082a2b673222f95c46", "778a4223e9098fc71cd0ced78bb252fdb7904905"))
    check("current product equals observed immutable four paths", set(before) == set(after) == set(bridge.CURRENT_PATHS)
          and all(after[path] == observed[path] for path in after)
          and sha(after[ja]) == "c056e24b20ad6e9711bce82eaaface23edc49d62d4598d397baf08ed5a7b2816"
          and sha(after[ledger]) == "095d5e46dca4c4ddabcfde1f255565ff18f6cc913997238ca22ea812c102f53d")
    check("two corrected legacy values zero new source keys", keys == ("%s · POT %s 정산", "판돈 선택")
          and tuple(bridge.LEGACY_RESIDUAL_TEXTS.values()) == (("%s · POT %s 精算", "%s · ポット %s 精算"),
                                                             ("ポットオッズ選択", "ベット金額を選択"))
          and all(key in current.blueprint for key in keys)
          and len(old[ja]) == len(new[ja]) == 3053 and all(before[path] == after[path] for path in bridge.UI_PATHS))
    check("two first receipts not new coverage", change == {
        "ui_by_locale": {"ja": 0, "zh-CN": 0, "zh-TW": 0}, "receipts": 0, "batches": 0,
        "corrections": 2, "correction_batches": 1, "first_receipts": 2,
        "source_manifests": {"33b9d28243e581b74ed12fc1a1d1eb23e004705c": "b591702ee74ccae1063950c6e08748fd58997eeaba74d20c281c45a873fdfe6f"}})
    check("whole data inverse preserves all previous raw", bridge._legacy_ja_residual_comparison(after, before, after) == before
          and len(old[ledger]["batches"]) == 227 and len(new[ledger]["batches"]) == 228
          and all(leaf.id not in old[ledger]["accepted"]["ja"] for leaf in leaves))
    middle = bridge._snapshot(ROOT, bridge.LEGACY_RESIDUAL_INTERMEDIATE_COMMIT, bridge.CURRENT_PATHS)
    check("immutable intermediate is exactly observed not a final receipt", all(sha(middle[path]) == bridge.LEGACY_RESIDUAL_INTERMEDIATE_HASHES[path]
          for path in middle))
    rejects("raw receipt digest intermediate rejected", lambda: bridge._validate_legacy_ja_residual_correction(before, middle, inventory))
    def changed(path, edit):
        value = copy.deepcopy(new[path])
        edit(value)
        if path == ledger:
            value["accepted_sha256"] = bridge.exchange.digest(value["accepted"])
        return {**after, path: bridge._ordered(value)}
    for name, path, edit in (
        ("settlement rollback", ja, lambda value: value.__setitem__(keys[0], "%s · POT %s 精算")),
        ("stake rollback", ja, lambda value: value.__setitem__(keys[1], "ポットオッズ選択")),
        ("unowned JA target", ja, lambda value: value.__setitem__("폴드", "outside")),
        ("Chinese target", "locale/ui_zh-CN.json", lambda value: value.__setitem__("폴드", "outside")),
        ("receipt source", ledger, lambda value: value["accepted"]["ja"][leaves[0].id].__setitem__("source_sha256", "0" * 64)),
        ("receipt missing", ledger, lambda value: value["accepted"]["ja"].pop(leaves[1].id)),
        ("batch roots reordered", ledger, lambda value: value["batches"][227]["roots"].reverse()),
        ("old batch", ledger, lambda value: value["batches"][0].__setitem__("order", "outside")),
    ):
        rejects("synthetic residual " + name, lambda path=path, edit=edit:
                bridge._validate_legacy_ja_residual_correction(before, changed(path, edit), inventory))
    rejects("residual current Korean Leaf missing", lambda:
            bridge._validate_legacy_ja_residual_correction(before, after, {"leaves": leaves[:1]}))
    wrong = bridge.exchange.Leaf("ui", keys[0], "runtime:wrong", (keys[0],), keys[0], "ui_static_context")
    rejects("residual source address changed", lambda:
            bridge._validate_legacy_ja_residual_correction(before, after, {"leaves": [wrong, leaves[1]]}))
    rejects("residual raw outside exact inverse", lambda:
            bridge._validate_legacy_ja_residual_correction(before, {**after, ja: after[ja] + b"\n"}, inventory))
    rejects("comparison refuses rollback under later appends", lambda:
            bridge._legacy_ja_residual_comparison(changed(ja, lambda value: value.__setitem__(keys[1], "ポットオッズ選択")), before, after))
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected captured data Git request")
        return responses[(args, kwargs.get("input"))]
    # Replay corrupt immutable evidence without executing old historical suites.
    for name, prefix, mutate in (
        ("object packet", ("cat-file",), lambda value: value + b"x"),
        ("extra product path", ("diff",), lambda value: value + b"M\0outside.json\0"),
    ):
        def fault(root, *args, prefix=prefix, mutate=mutate, **kwargs):
            value = replay(root, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(bridge, "_git", side_effect=fault):
            rejects("captured residual " + name, lambda: bridge._legacy_ja_residual_proof(ROOT, inventory))
    with patch.object(bridge, "_git", side_effect=OSError("captured unavailable data proof")):
        rejects("data success never caches next fault", lambda: bridge._legacy_ja_residual_proof(ROOT, inventory))
    with patch.object(bridge, "_git", side_effect=replay):
        check("captured data recovery", bridge._legacy_ja_residual_proof(ROOT, inventory) == (before, after, change))
    pending_delivery_checks(before, middle, after, change, inventory)


def pending_delivery_checks(before, middle, after, change, inventory):
    """Exercise the actual dispatcher with memory inputs, never old proof suites."""
    base, extra = "0" * 40, "1" * 40
    fee = bridge.FEE_AFTER_COMMIT
    mid, final = bridge.LEGACY_RESIDUAL_INTERMEDIATE_COMMIT, bridge.LEGACY_RESIDUAL_AFTER_COMMIT
    zero = {"ui_by_locale": {locale: 0 for locale in bridge.CURRENT_LOCALES},
            "receipts": 0, "batches": 0, "source_manifests": {}}
    class NoSplit:
        def step(self, *_args):
            return None
        def finish(self):
            return None
    def run(mode):
        commits = {"complete": [fee, mid, final], "unfinished": [fee, mid],
                   "missing": [fee, final], "interrupted": [fee, mid, extra, final]}[mode]
        head = commits[-1]
        lineage = [*reversed(commits), base]
        snapshots = {base: before, fee: before, mid: middle, extra: middle, final: after}
        parents = {fee: base, mid: fee, extra: mid, final: mid}
        combined_calls = []
        def git(root, *args, **kwargs):
            if root != ROOT or kwargs:
                raise AssertionError("unexpected synthetic history Git input")
            if args == ("rev-parse", "--verify", "HEAD^{commit}"):
                return (head + "\n").encode()
            if args == ("rev-list", "--first-parent", head):
                return ("\n".join(lineage) + "\n").encode()
            if args[:1] == ("log",):
                return ("\n".join(commits) + "\n").encode()
            if args[:2] == ("merge-base", "--is-ancestor"):
                return b""
            raise AssertionError("unexpected synthetic history Git request " + str(args))
        def objects(root, requests):
            if root != ROOT or len(requests) != 1 or requests[0][2] != "commit":
                raise AssertionError("unexpected synthetic history object request")
            commit = requests[0][0]
            return [("tree " + "2" * 40 + "\nparent " + parents[commit] + "\n\nsynthetic\n").encode()]
        def snapshot(root, revision, paths):
            if root != ROOT or tuple(paths) != bridge.CURRENT_PATHS:
                raise AssertionError("unexpected synthetic history snapshot request")
            return dict(snapshots[revision])
        def append(old, new, _inventory):
            if old != before or new != before:
                raise ValueError("combined history did not restore the exact before bytes")
            combined_calls.append(True)
            return dict(zero)
        old_three = {path: before[path] for path in bridge.PATHS}
        with patch.object(bridge, "_git", side_effect=git), patch.object(bridge, "_objects", side_effect=objects), \
             patch.object(bridge, "_snapshot", side_effect=snapshot), \
             patch.object(bridge, "_fee_correction_proof", return_value=(old_three, old_three, zero)), \
             patch.object(bridge, "_fee_comparison", side_effect=lambda raw, _before, _after: dict(raw)), \
             patch.object(bridge, "_legacy_ja_residual_proof", return_value=(before, after, change)), \
             patch.object(bridge, "_SplitReceiptHistory", return_value=NoSplit()), \
             patch.object(bridge, "_source_manifest_matches", return_value=True), \
             patch.object(bridge, "_source_manifest", return_value=next(iter(change["source_manifests"].values()))), \
             patch.object(bridge, "validate_append", side_effect=append):
            result = bridge.validate_history(ROOT, base, before, snapshots[head], inventory)
        return result, combined_calls
    result, combined = run("complete")
    check("synthetic two-step dispatcher counts final correction once", combined == [True]
          and result["corrections"] == result["first_receipts"] == result["receipts"] == 2
          and result["correction_batches"] == result["batches"] == 1
          and result["transitions"][1]["commit"] == mid
          and result["transitions"][1]["receipts"] == result["transitions"][1]["batches"] == 0
          and result["transitions"][1]["source_manifests"] == {})
    for mode in ("unfinished", "missing", "interrupted"):
        rejects("synthetic residual pending " + mode, lambda mode=mode: run(mode))


if __name__ == "__main__":
    raise SystemExit(main())
