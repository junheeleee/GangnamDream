#!/usr/bin/env python3
"""Bounded coin-call transition checks; no collector, engine or old suite.

Immutable Git pairs are read once. Captured admission faults and compact ledger
mutations are explicitly synthetic, not fresh historical admission evidence.
The separate full-body command owns whole-history current validation.
"""
from __future__ import annotations

import copy
import hashlib
import json
from pathlib import Path
import sys
import traceback
from dataclasses import replace
from unittest.mock import patch

sys.dont_write_bytecode = True
import coin_call_receipt_history as history
import full_game_localization as exchange
import ui_translation_append as append
import order365_ui_receipt_compat as current

ROOT = Path(__file__).resolve().parents[1]
KO = "content/events/amb_scenarios2.json"
EN = "content/events_en/amb_scenarios2.json"
RULES = "content/meta/story_rules.json"
VISUAL = "assets/event_visual_contracts.json"
DIRECTION = "assets/scene_direction_manifest.json"
LEDGER = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
SELECTORS = (("amb_coin_00", ("choices", 2, "result_text")),
             ("amb_coin_00", ("description",)), ("amb_coin_warn", ("description",)))
SOURCE_PRODUCT = (KO, EN, RULES, VISUAL, DIRECTION)
TARGETS = tuple("content/events_" + locale + "/amb_scenarios2.json" for locale in LOCALES)
UI = tuple("locale/ui_" + locale + ".json" for locale in LOCALES)
CASES = []


def check(label, condition):
    if not condition:
        raise AssertionError(label)
    CASES.append(label)


def rejects(label, operation):
    try:
        operation()
    except (ValueError, OSError, KeyError, TypeError, IndexError):
        CASES.append(label)
        return
    raise AssertionError(label + ": unexpectedly admitted")


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def encode(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode()


def token(raw, path, value):
    doc = history._Document(raw)
    start, end = doc.spans[path]
    return (doc.text[:start] + json.dumps(value, ensure_ascii=False) + doc.text[end:]).encode()


def event_path(raw, owner, field):
    rows = exchange.loads(raw.decode())
    found = [i for i, row in enumerate(rows) if row.get("id") == owner]
    if len(found) != 1:
        raise AssertionError("fixture event identity " + owner)
    return (found[0], *field)


def leaves(raw):
    rows = exchange.row_index(exchange.loads(raw.decode()), "focused Korean source")
    return [exchange.Leaf("events", owner, KO, field, exchange.get_at(rows[owner], field),
                          "event_standard", lifecycle="shipping") for owner, field in SELECTORS]


def capture_git(records, function):
    def invoke(root, *args, input=None):
        output = function(root, *args, input=input)
        records.append((args, input, output))
        return output
    return invoke


def replay_git(records):
    pending = iter(records)
    def invoke(root, *args, input=None):
        expected_args, expected_input, output = next(pending)
        if root != ROOT or args != expected_args or input != expected_input:
            raise AssertionError("captured Git request mismatch")
        if isinstance(output, Exception):
            raise output
        return output
    return invoke


def changed_record(records, index, output):
    result = list(records)
    args, data, _ = result[index]
    result[index] = args, data, output
    return result


def source_checks(before, after):
    a = {path: before[path] for path in SOURCE_PRODUCT}
    b = {path: after[path] for path in SOURCE_PRODUCT}
    check("actual whole source-five inverse", history.coin_source_inverse(b, a) == a)
    for path in (KO, EN):
        for owner, field in SELECTORS:
            old = exchange.get_at(exchange.loads(a[path].decode()), event_path(a[path], owner, field))
            new = exchange.get_at(exchange.loads(b[path].decode()), event_path(b[path], owner, field))
            check("actual reviewed source leaf changed " + path + owner + str(field), old != new)
        # An adjacent live title is not part of this source repair.
        field = event_path(b[path], "amb_coin_00", ("title",))
        changed = token(b[path], field, "unowned title drift")
        rejects("unowned source title " + path,
                lambda p=path, raw=changed: history.coin_source_inverse({**b, p: raw}, a))
    for path in SOURCE_PRODUCT:
        rejects("nonowned raw whitespace " + path,
                lambda p=path: history.coin_source_inverse({**b, p: b[p] + b"\n"}, a))
        rejects("source rollback " + path,
                lambda p=path: history.coin_source_inverse({**b, p: a[p]}, a))
    for label, changed in (("missing source path", {p: v for p, v in b.items() if p != KO}),
                           ("extra source path", {**b, "unowned.json": b"{}"})):
        rejects(label, lambda value=changed: history.coin_source_inverse(value, a))
    check("source inverse leaves caller dictionaries untouched", a == {p: before[p] for p in a}
          and b == {p: after[p] for p in b})


def compact_ui(before, after):
    """Actual correction tokens in a small synthetic comparison-only ledger.

    Not a valid whole acceptance population: the actual proof owns 41755 entries.
    Keep the original batch index but replace old unrelated rows with tiny rows.
    """
    a, b = (exchange.loads(value[LEDGER].decode()) for value in (before, after))
    start = len(a["batches"])
    keys = [leaf.id for leaf in leaves((ROOT / KO).read_bytes())]
    result = []
    for snapshot, ledger in ((before, a), (after, b)):
        accepted = {locale: {key: copy.deepcopy(ledger["accepted"][locale][key]) for key in keys}
                    for locale in LOCALES}
        accepted["ja"]["events:unowned:/title"] = {"source_sha256": "a" * 64, "target_sha256": "b" * 64}
        compact = {"accepted": accepted, "accepted_sha256": exchange.digest(accepted),
                   "batches": [{"synthetic_prior": i} for i in range(start)]
                              + copy.deepcopy(ledger["batches"][start:])}
        result.append({**{p: snapshot[p] for p in UI}, LEDGER: encode(compact)})
    return result[0], result[1], start, keys


def ledger_edit(snapshot, path, value, checksum=False):
    changed = token(snapshot[LEDGER], path, value)
    if checksum:
        ledger = exchange.loads(changed.decode())
        changed = token(changed, ("accepted_sha256",), exchange.digest(ledger["accepted"]))
    return {**snapshot, LEDGER: changed}


def append_fixture(snapshot):
    result = {p: encode({**exchange.loads(snapshot[p].decode()), "synthetic later UI": "later target"}) for p in UI}
    value = exchange.loads(snapshot[LEDGER].decode())
    value["accepted"]["ja"]["ui:synthetic later UI:/synthetic later UI"] = {
        "source_sha256": "c" * 64, "target_sha256": "d" * 64}
    value["batches"].append({"synthetic_future_append": True})
    value["accepted_sha256"] = exchange.digest(value["accepted"])
    result[LEDGER] = encode(value)
    return result


def comparison_checks(before, after):
    a, b, start, keys = compact_ui(before, after)
    saved = (dict(a), dict(b))
    compare = lambda value: history.coin_call_comparison(value, a, b)
    check("compact exact correction comparison", compare(b) == a)
    for locale in LOCALES:
        for key in keys:
            for field in ("source_sha256", "target_sha256"):
                old = exchange.loads(a[LEDGER].decode())["accepted"][locale][key][field]
                mutant = ledger_edit(b, ("accepted", locale, key, field), old, checksum=True)
                rejects("stale owned receipt " + locale + key + field, lambda value=mutant: compare(value))
    ledger = exchange.loads(b[LEDGER].decode())
    for field, replacement in (("locale", "en"), ("count", 2), ("selection_sha256", "0" * 64),
                               ("source_manifest_sha256", "0" * 64), ("batch_id", "0" * 64)):
        batch = ledger["batches"][start]
        header_field = "official_receipt_headers_by_locale"
        mutant = ledger_edit(b, ("batches", start, header_field, "ja", field), replacement)
        check("header mutation field exists " + field, field in batch[header_field]["ja"])
        rejects("official header drift " + field, lambda value=mutant: compare(value))
    for locale in LOCALES:
        changed = copy.deepcopy(ledger)
        receipt = changed["accepted"][locale].pop(keys[0])
        changed["accepted"][locale][keys[0] + "-wrong-selector"] = receipt
        changed["accepted_sha256"] = exchange.digest(changed["accepted"])
        rejects("same-count wrong receipt selector " + locale,
                lambda value={**b, LEDGER: encode(changed)}: compare(value))
    swapped = copy.deepcopy(ledger)
    swapped["accepted"]["ja"][keys[0]], swapped["accepted"]["zh-CN"][keys[0]] = (
        swapped["accepted"]["zh-CN"][keys[0]], swapped["accepted"]["ja"][keys[0]])
    swapped["accepted_sha256"] = exchange.digest(swapped["accepted"])
    rejects("same-count wrong receipt locale", lambda: compare({**b, LEDGER: encode(swapped)}))
    rejects("stale accepted checksum", lambda: compare(ledger_edit(b, ("accepted_sha256",), "0" * 64)))
    raw_changed = b[LEDGER].replace(b'"official_receipt_headers_by_locale":',
                                  b'"official_receipt_headers_by_locale" :', 1)
    check("raw header mutation differs", raw_changed != b[LEDGER])
    rejects("equal-value correction raw changed", lambda: compare({**b, LEDGER: raw_changed}))
    rejects("comparison rollback", lambda: compare(a))
    future = append_fixture(b)
    expected = append_fixture(a)
    check("future UI/receipt/batch append bytes preserved", compare(future) == expected)
    foreign = ledger_edit(future, ("accepted", "ja", "events:unowned:/title", "target_sha256"), "e" * 64)
    rejects("nonowned receipt stale checksum rejected", lambda: compare(foreign))
    foreign = ledger_edit(future, ("accepted", "ja", "events:unowned:/title", "target_sha256"), "e" * 64, True)
    expected_foreign = ledger_edit(expected, ("accepted", "ja", "events:unowned:/title", "target_sha256"), "e" * 64, True)
    check("comparison preserves recomputed nonowned receipt, not admission", compare(foreign) == expected_foreign)
    output = compare(b)
    output[UI[0]] = b"caller output mutation"
    check("fresh return and failed-call recovery", compare(b) == a and (a, b) == saved)


def actual_proof():
    check("observed transition commit identities", history.SOURCE_BEFORE_COMMIT == "f9b4337caeb6e634538c49ab00323c2b9111eea2"
          and history.SOURCE_AFTER_COMMIT == history.COIN_BEFORE_COMMIT == "632f88babba781e639157e33ac1a06744b987c1b"
          and history.COIN_AFTER_COMMIT == "49124fd03067fc5f57d6f617610f82776f5e89e2")
    check("independent exact path/selector populations", history.SELECTORS == SELECTORS
          and history.SOURCE_PRODUCT_PATHS == SOURCE_PRODUCT and history.EVENT_PATHS == TARGETS
          and history.CURRENT_PATHS == (*UI, LEDGER))
    inventory = {"leaves": leaves((ROOT / KO).read_bytes())}
    source_pairs, target_pairs, objects, direct_git, packets = [], [], [], [], []
    real_source, real_target = history._read_source_pair, history._read_pair
    real_objects, real_git = history._objects, history._git
    real_packet_git = history.prior._git

    def pair_reader(function, destination):
        def invoke(root):
            result = function(root)
            destination.append(result)
            return result
        return invoke

    def object_reader(root, requests):
        result = real_objects(root, requests)
        objects.append((list(requests), list(result)))
        return result

    # Only this call reads the two actual immutable transitions.
    with patch.object(history, "_read_source_pair", side_effect=pair_reader(real_source, source_pairs)), \
         patch.object(history, "_read_pair", side_effect=pair_reader(real_target, target_pairs)), \
         patch.object(history, "_objects", side_effect=object_reader), \
         patch.object(history, "_git", side_effect=capture_git(direct_git, real_git)), \
         patch.object(history.prior, "_git", side_effect=capture_git(packets, real_packet_git)):
        before_ui, after_ui, change = history.coin_call_proof(ROOT, inventory)
    check("one actual source-pair and receipt-pair proof", len(source_pairs) == len(target_pairs) == 1
          and len(objects) == len(packets) == len(direct_git) == 2)
    source_pair, target_pair = source_pairs[0], target_pairs[0]
    before, after = target_pair
    a, b = (exchange.loads(value[LEDGER].decode()) for value in target_pair)
    check("actual prior228 plus3 batches and41755 unchanged coverage",
          len(a["batches"]) == 228 and len(b["batches"]) == 231
          and b["batches"][:228] == a["batches"]
          and [sum(map(len, value["accepted"].values())) for value in (a, b)] == [41755, 41755])
    check("correction counters are not append coverage", change["corrections"] == 9
          and change["correction_batches"] == 3 and change["receipts"] == change["batches"] == change["first_receipts"] == 0
          and not any(change["ui_by_locale"].values()))
    check("actual current UI3 bytes unchanged", all(before_ui[p] == after_ui[p] == (ROOT / p).read_bytes() for p in UI))
    for locale, path in zip(LOCALES, TARGETS):
        for leaf in inventory["leaves"]:
            field = event_path(after[path], leaf.owner, leaf.path)
            old_text = exchange.get_at(exchange.loads(before[path].decode()), field)
            new_text = exchange.get_at(exchange.loads(after[path].decode()), field)
            check("actual target leaf and receipt " + locale + leaf.id, old_text != new_text
                  and b["accepted"][locale][leaf.id] == {"source_sha256": leaf.source_sha256,
                                                        "target_sha256": exchange.digest(new_text)})
    return source_pair, target_pair, before_ui, after_ui, inventory, objects, direct_git, packets


def captured_proof_faults(objects, direct_git, packets):
    # Object packet corruption exercises the real decoder against recorded
    # bytes. Decoded-object faults below are not fake cryptographic Git proofs.
    for label, output in (("truncated packet", packets[0][2][:-1]),
                          ("trailing packet", packets[0][2] + b"x")):
        with patch.object(history.prior, "_git", side_effect=replay_git(changed_record(packets[:1], 0, output))):
            rejects(label, lambda: history._read_source_pair(ROOT))
    for index, (reader, label) in enumerate(((history._read_source_pair, "source"), (history._read_pair, "receipt"))):
        requests, values = objects[index]
        for fault, marker in (("tree", b"tree "), ("parent", b"parent ")):
            mutated = list(values)
            lines = mutated[1].split(b"\n")
            line = next(i for i, value in enumerate(lines) if value.startswith(marker))
            lines[line] = marker + b"0" * 40
            mutated[1] = b"\n".join(lines)
            with patch.object(history, "_objects", return_value=mutated):
                rejects(label + " decoded " + fault, lambda: reader(ROOT))
        with patch.object(history, "_objects", return_value=values), \
             patch.object(history, "_git", side_effect=replay_git(changed_record(
                 direct_git[index:index + 1], 0, direct_git[index][2] + b"M\0unowned.json\0"))):
            rejects(label + " unexpected changed path", lambda: reader(ROOT))
        # Forge the SHA declaration for a nearby nonowned byte. The exact
        # semantic/raw inverse must still reject it after hash comparison.
        path = KO if index == 0 else TARGETS[0]
        blob_index = next(i for i, row in enumerate(requests) if row[0].endswith(":" + path)) + 1
        mutated = list(values)
        mutated[blob_index] = token(mutated[blob_index], event_path(mutated[blob_index], "amb_coin_00", ("title",)), "nearby drift")
        attr = "SOURCE_HASHES" if index == 0 else "COIN_HASHES"
        hashes = dict(getattr(history, attr))
        hashes[path] = hashes[path][0], sha(mutated[blob_index])
        with patch.object(history, "_objects", return_value=mutated), patch.object(history, attr, hashes), \
             patch.object(history, "_git", side_effect=replay_git(direct_git[index:index + 1])):
            rejects(label + " forged hash cannot authorize unowned leaf", lambda: reader(ROOT))


def current_checks(source_pair, target_pair):
    direct_git, packets, object_rows = [], [], []
    real_git, real_objects, real_packet = history._git, history._objects, history.prior._git
    def object_reader(root, requests):
        value = real_objects(root, requests)
        object_rows.append((list(requests), list(value)))
        return value
    # One actual current HEAD/disk check, reusing only immutable pair evidence.
    with patch.object(history, "_read_source_pair", return_value=source_pair), \
         patch.object(history, "_read_pair", return_value=target_pair), \
         patch.object(history, "_objects", side_effect=object_reader), \
         patch.object(history, "_git", side_effect=capture_git(direct_git, real_git)), \
         patch.object(history.prior, "_git", side_effect=capture_git(packets, real_packet)):
        actual = history.coin_call_current_events(ROOT)
    check("actual current eight product bytes, not comparison output", set(actual) == set((*SOURCE_PRODUCT, *TARGETS))
          and len(object_rows) == len(packets) == 1 and len(direct_git) == 4
          and all(raw == (ROOT / path).read_bytes() for path, raw in actual.items()))
    disk_read = Path.read_bytes
    def replay(*, records=None, disk=None, object_values=None):
        def read(path):
            relative = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else ""
            return (disk or actual)[relative] if relative in actual else disk_read(path)
        with patch.object(history, "_read_source_pair", return_value=source_pair), \
             patch.object(history, "_read_pair", return_value=target_pair), \
             patch.object(history, "_objects", return_value=object_rows[0][1] if object_values is None else object_values), \
             patch.object(history, "_git", side_effect=replay_git(direct_git if records is None else records)), \
             patch.object(Path, "read_bytes", read):
            return history.coin_call_current_events(ROOT)
    for path in actual:
        rejects("captured current disk drift " + path, lambda p=path: replay(disk={**actual, p: actual[p] + b"\n"}))
    for label, index, output in (("HEAD moved", 3, b"0" * 40 + b"\n"),
                                 ("blob substituted", 2, b"0" * 40 + b"\n"),
                                 ("ancestor failed", 1, ValueError("synthetic ancestor rejection"))):
        rejects("captured current " + label, lambda i=index, value=output: replay(records=changed_record(direct_git, i, value)))
    bad = list(object_rows[0][1]); bad[0] += b"\n"
    rejects("captured current decoded object mismatch", lambda: replay(object_values=bad))
    check("current failure recovery with same captured current evidence", replay() == actual)
    return actual, direct_git[0][2].decode().strip()


def validator_checks(source_pair, target_pair, inventory):
    for locale, path in (("ko", KO), ("en", EN), *zip(LOCALES, TARGETS)):
        pair = source_pair if locale in ("ko", "en") else target_pair
        a, b = pair[0][path], pair[1][path]
        for owner, field in SELECTORS:
            path_tokens = event_path(b, owner, field)
            text = exchange.get_at(exchange.loads(b.decode()), path_tokens)
            changed = token(b, path_tokens, text + " changed")
            rejects("all15 exact repaired leaves reject drift " + locale + owner + str(field),
                    lambda raw=changed, old=a, language=locale: history._event_inverse(raw, old, language))
    source_before = {p: source_pair[0][p] for p in SOURCE_PRODUCT}
    source_after = {p: source_pair[1][p] for p in SOURCE_PRODUCT}
    for label, path, field, value in (
        ("remote actor", RULES, ("events", "amb_coin_warn", "presentation", "remote_actor"), "player"),
        ("local portrait", RULES, ("events", "amb_coin_warn", "presentation", "portrait_role"), "remote"),
        ("remote transition", DIRECTION, ("transition_edges", "amb_coin_00->amb_coin_warn", "mode"), "same_location"),
    ):
        changed = {**source_after, path: token(source_after[path], field, value)}
        rejects("phone contract " + label, lambda value=changed: history.coin_source_inverse(value, source_before))
    a = {p: target_pair[0][p] for p in (*TARGETS, LEDGER)}
    b = {p: target_pair[1][p] for p in (*TARGETS, LEDGER)}
    for label, selected in (("duplicate selected Leaf", [*inventory["leaves"], inventory["leaves"][0]]),
                            ("wrong source Leaf", [replace(inventory["leaves"][0], source="wrong"), *inventory["leaves"][1:]])):
        rejects(label, lambda rows=selected: history.validate_coin_correction(a, b, {"leaves": rows}))
    # Rebuild all easy digests after forging selection. The official header
    # must still be reconstructed from the three real Leaf identities.
    value = exchange.loads(b[LEDGER].decode())
    batch = value["batches"][228]
    header = batch["official_receipt_headers_by_locale"]["ja"]
    header["selection_sha256"] = "0" * 64
    header["batch_id"] = exchange.digest({k: v for k, v in header.items() if k != "batch_id"})
    receipts = {leaf.id: value["accepted"]["ja"][leaf.id] for leaf in inventory["leaves"]}
    batch["receipt_sha256_by_locale"]["ja"] = exchange.digest({"batch": header,
        "state": "accepted_machine_validated", "native_review": "OPEN", "translations": receipts})
    rejects("forged self-consistent official selector", lambda: history.validate_coin_correction(a, {**b, LEDGER: encode(value)}, inventory))
    # Exact product admission rejects nonowned bytes even though comparison
    # inversion legitimately preserves future nonowned appends.
    changed = token(b[LEDGER], ("batches", 0, "order"), "unowned-order")
    rejects("old batch changed outside owned correction", lambda: history.coin_product_inverse({**b, LEDGER: changed}, a))


def wrapper_checks(source_pair, actual, head):
    # Bounded synthetic census: no invocation of exchange.collect.
    hashes = {p: sha(actual[p]) for p in (KO, RULES)}
    hashes["scenes/HoldemClub.gd"] = sha((ROOT / "scenes/HoldemClub.gd").read_bytes())
    inventory = {"source_hashes": hashes, "source_manifest_sha256": exchange.digest(hashes), "leaves": []}
    original_inventory = copy.deepcopy(inventory)
    predecessor = {p: source_pair[0][p] for p in (KO, RULES)}
    projected = {**hashes, **{p: sha(raw) for p, raw in predecessor.items()}}
    previous_manifest = exchange.digest(projected)
    calls = []
    def old_match(root, supplied, expected):
        calls.append((root, copy.deepcopy(supplied), expected))
        return expected == previous_manifest
    with patch.object(history, "_read_source_pair", return_value=source_pair), \
         patch.object(history, "_current", return_value={p: actual[p] for p in SOURCE_PRODUCT}), \
         patch.object(append, "_COIN_CALL_OLD_MANIFEST_MATCHES", side_effect=old_match):
        for expected in (inventory["source_manifest_sha256"], previous_manifest):
            check("current or exact predecessor manifest delegates", append._source_manifest_matches(ROOT, inventory, expected))
        check("unregistered mixed manifest rejected", not append._source_manifest_matches(ROOT, inventory, "0" * 64))
        for label, changed in (
            ("manifest digest forged", {**inventory, "source_manifest_sha256": "0" * 64}),
            ("old/new source mixture", {**inventory, "source_hashes": {**hashes, KO: sha(predecessor[KO])}}),
        ):
            if label == "old/new source mixture":
                changed["source_manifest_sha256"] = exchange.digest(changed["source_hashes"])
            rejects(label, lambda inv=changed: append._source_manifest_matches(ROOT, inv, inv["source_manifest_sha256"]))
    check("projection replaces source2 only and caller census remains actual",
          inventory == original_inventory and len(calls) == 3 and all(
              root == ROOT and inv["source_hashes"] == projected
              and inv["source_manifest_sha256"] == previous_manifest for root, inv, _ in calls))
    current_raw = {p: (ROOT / p).read_bytes() for p in (*UI, LEDGER)}
    result = {"raw": current_raw, "source_hashes": hashes,
              "source_manifest_sha256": exchange.digest(hashes), "evidence": {"head": head}}
    def invoke(payload=None, head_after=None, disk=None):
        chosen = result if payload is None else payload
        real_read = Path.read_bytes
        def read(path):
            relative = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else ""
            return disk[relative] if disk is not None and relative in disk else real_read(path)
        with patch.object(history, "coin_call_current_events", return_value=actual), \
             patch.object(append, "_COIN_CALL_OLD_CURRENT_PROOF", return_value=chosen), \
             patch.object(append, "_git", side_effect=[(head + "\n").encode(), ((head_after or head) + "\n").encode()]), \
             patch.object(Path, "read_bytes", read):
            return append.current_proof(ROOT, "captured-baseline", current_raw)
    check("current wrapper carries original result/UI4 unchanged", invoke() is result and result["raw"] == current_raw)
    rejects("outer current HEAD moved", lambda: invoke(head_after="0" * 40))
    rejects("inner evidence HEAD differs", lambda: invoke(payload={**result, "evidence": {"head": "0" * 40}}))
    rejects("outer current raw changed after proof", lambda: invoke(disk={KO: actual[KO] + b"\n"}))
    bad_hashes = {**hashes, KO: sha(predecessor[KO])}
    rejects("outer stale census with recomputed manifest", lambda: invoke(payload={**result,
            "source_hashes": bad_hashes, "source_manifest_sha256": exchange.digest(bad_hashes)}))
    check("outer failure recovery", invoke() is result)


def consumer_checks(actual, head):
    """Original47 plus exact coin3 dispatch; no historical proof is run."""
    original_paths = tuple(dict.fromkeys((*current.previous.LIVE_PATHS, *UI)))
    snapshot = {path: (ROOT / path).read_bytes() for path in current.LIVE_PATHS}
    check("actual current50 is unchanged original47 plus exact coin3",
          len(original_paths) == 47 and not set(TARGETS).intersection(original_paths)
          and current.LIVE_PATHS == (*original_paths, *TARGETS) and len(snapshot) == 50)
    raw_ui = {p: snapshot[p] for p in (*UI, LEDGER)}
    coffee = {p: snapshot[p] for p in current.coffee_history.EVENT_PATHS}
    payload = {"raw": raw_ui, "coin_event_raw": actual, "coffee_event_raw": coffee, "evidence": {"head": head}}
    calls = []
    def previous(raw, path):
        calls.append(path)
        return [] if path in snapshot and raw == snapshot[path] else ["synthetic previous-path mismatch"]
    proof_token = current._ACTIVE_PROOF.set({"synthetic_dispatch_only": True})
    current_token = current._ACTIVE_CURRENT.set(payload)
    try:
        with patch.object(current.previous, "source_errors", side_effect=previous):
            check("current50 dispatch keeps all original47 and coin3 exact bytes", current.snapshot_errors(snapshot) == [])
            delegated = set(snapshot) - set(raw_ui) - set(coffee) - set(TARGETS)
            check("all nonowned current paths retain old delegation", set(calls) == delegated and len(calls) == len(delegated))
            for path in (*TARGETS, *UI, LEDGER):
                check("current caller rejects stale/raw drift " + path,
                      bool(current.source_errors(snapshot[path] + b"\n", path)))
            check("current exact50 missing coin path rejection", bool(current.snapshot_errors({p: raw for p, raw in snapshot.items() if p != TARGETS[0]})))
            check("current exact50 missing original path rejection", bool(current.snapshot_errors({p: raw for p, raw in snapshot.items() if p != original_paths[0]})))
            check("unknown current path rejection", bool(current.source_errors(b"{}", "unowned.json")))
            changed = copy.deepcopy(payload)
            changed["coin_event_raw"].pop(TARGETS[0])
            current._ACTIVE_CURRENT.set(changed)
            check("coin proof lacks target entry", bool(current.source_errors(snapshot[TARGETS[0]], TARGETS[0])))
    finally:
        current._ACTIVE_CURRENT.reset(current_token)
        current._ACTIVE_PROOF.reset(proof_token)
    check("consumer context restored", current._ACTIVE_PROOF.get() is None and current._ACTIVE_CURRENT.get() is None)


def main():
    try:
        source_pair, target_pair, before_ui, after_ui, inventory, objects, direct_git, packets = actual_proof()
        source_checks(*source_pair)
        comparison_checks(before_ui, after_ui)
        validator_checks(source_pair, target_pair, inventory)
        captured_proof_faults(objects, direct_git, packets)
        actual, head = current_checks(source_pair, target_pair)
        wrapper_checks(source_pair, actual, head)
        consumer_checks(actual, head)
    except Exception as exc:
        print("COIN_CALL_RECEIPT_HISTORY_SELF_TEST_FAIL cases=%d error=%s: %s" % (len(CASES), type(exc).__name__, exc))
        print("".join(traceback.format_exception(type(exc), exc, exc.__traceback__)))
        return 1
    print("COIN_CALL_RECEIPT_HISTORY_SELF_TEST_OK cases=%d historical_cases=0" % len(CASES))
    print("immutable_transitions=2 actual_current_admissions=1 leaf_checks=15 corrected_receipts=9 original_current_paths=47 added_coin_paths=3 current_paths=50 collector_calls=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
