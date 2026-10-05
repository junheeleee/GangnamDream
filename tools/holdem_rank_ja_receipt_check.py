#!/usr/bin/env python3
"""Bounded one-rank first-receipt correction; no old suites or collector runs.

The normal receipt audit owns fresh full collection/history/current HEAD.
Here one explicit Korean leaf drives one real Git product/provenance proof;
faults replay captured Git responses or mutate those four raw snapshots.
"""
from __future__ import annotations

import copy
import hashlib
import sys
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
CASES: list[str] = []
DISPATCH = '''        elif commit == LEGACY_RANK_AFTER_COMMIT:
            before, after, change = _legacy_ja_rank_proof(root, inventory)
            require(set(paths) == set(CURRENT_PATHS) and previous == before and successor == after,
                    "legacy JA rank lineage or protected locale differs")
            corrections.append((_legacy_ja_rank_comparison, before, after))
'''.encode()


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


def edit(snapshot, documents, path, field, value):
    """Synthetic token edit, with a fresh checksum for accepted-map faults."""
    doc = documents[path]
    start, end = doc.spans[field]
    changes = [(start, end, bridge._ordered(value).decode())]
    if path == bridge.LEDGER_PATH and field[0] == "accepted":
        accepted = copy.deepcopy(doc.value["accepted"])
        target = accepted
        for part in field[1:-1]:
            target = target[part]
        target[field[-1]] = value
        start, end = doc.spans[("accepted_sha256",)]
        changes.append((start, end, bridge._ordered(bridge.exchange.digest(accepted)).decode()))
    text = doc.text
    for start, end, replacement in sorted(changes, reverse=True):
        text = text[:start] + replacement + text[end:]
    return {**snapshot, path: text.encode()}


def main():
    ja, ledger, key = "locale/ui_ja.json", bridge.LEDGER_PATH, "포카드"
    protected = (*bridge.CURRENT_PATHS, "systems/TexasHoldem.gd", "scenes/HoldemClub.gd",
                 "tools/ui_translation_append.py", "tools/holdem_rank_ja_receipt_check.py")
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    marker = b"\n\n# BEGIN_LEGACY_JA_RANK_CORRECTION_446\n"
    source = observed["tools/ui_translation_append.py"]
    prefix = source.split(marker, 1)[0]
    original = bridge._git(ROOT, "show", "248813a14021a37407195d59cf3e6334551df2de:tools/ui_translation_append.py")
    check("only the new exact dispatcher changes the complete old prefix", source.count(marker) == 1
          and prefix.count(DISPATCH) == 1 and prefix.replace(DISPATCH, b"", 1) == original)
    check("independent product identity and one-rank scope", bridge.LEGACY_RANK_BEFORE_COMMIT
          == "248813a14021a37407195d59cf3e6334551df2de" and bridge.LEGACY_RANK_AFTER_COMMIT
          == "063d7db3fdb463295b050688f46c701d77b31acb" and bridge.LEGACY_RANK_KEY == key
          and bridge.LEGACY_RANK_TEXTS == ("フォールド", "フォーカード")
          and bridge.LEGACY_RANK_PRODUCT_PATHS == (ja, ledger) and bridge.LEGACY_RANK_BATCH_INDEX == 216)
    for path in ("systems/TexasHoldem.gd", "scenes/HoldemClub.gd"):
        check("unchanged actual consumer source " + path, observed[path] == bridge._git(
            ROOT, "show", bridge.LEGACY_RANK_BEFORE_COMMIT + ":" + path))
    check("rank seven still reads the exact Korean English pair",
          b'\t\t7: return LocaleManager.ui("' + key.encode() + b'", "Four of a Kind")\n'
          in observed["systems/TexasHoldem.gd"])
    leaf = bridge.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
    check("independent Korean leaf hash", leaf.id == "ui:포카드:/포카드"
          and leaf.source_sha256 == "716497231f8017ee52030a1f12267c8f9c3202aae0e27c98c64e188d4f662338")
    inventory = {"leaves": [leaf], "source_manifest_sha256":
                 "b9ce4501f2322d1fd16f1a12ff796e37b67f0817b25728b8fc4bc4bc3a880870"}
    real_git, real_objects, responses, payloads = bridge._git, bridge._objects, {}, []
    def capture(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        responses[(args, kwargs.get("input"))] = value
        return value
    def capture_objects(where, requests):
        value = real_objects(where, requests)
        payloads.append(value)
        return value
    with patch.object(bridge, "_git", side_effect=capture), \
            patch.object(bridge, "_objects", side_effect=capture_objects) as objects:
        before, after, change = bridge._legacy_ja_rank_proof(ROOT, inventory)
    requests = [row for call in objects.call_args_list for row in call.args[1]]
    check("one real proof with thirteen request entries and eleven distinct OIDs", len(objects.call_args_list) == 1
          and len(requests) == 13 and len({r[1] for r in requests}) == 11
          and [r[2] for r in requests].count("commit") == 2
          and [r[2] for r in requests].count("tree") == 2 and [r[2] for r in requests].count("blob") == 9)
    check("actual current four files equal the proved product", after == {p: observed[p] for p in bridge.CURRENT_PATHS})
    check("correction not new UI coverage", change == {
        "ui_by_locale": {loc: 0 for loc in bridge.CURRENT_LOCALES}, "receipts": 0, "batches": 0,
        "corrections": 1, "correction_batches": 1, "first_receipts": 1,
        "source_manifests": {bridge.LEGACY_RANK_BEFORE_COMMIT: inventory["source_manifest_sha256"]}})
    old = {p: bridge._Document(raw) for p, raw in before.items()}
    new = {p: bridge._Document(raw) for p, raw in after.items()}
    batch = new[ledger].value["batches"][216]
    official = bridge.exchange.make_batch(inventory, "ja", [leaf], bridge.LEGACY_RANK_BEFORE_COMMIT,
                                          {ja: old[ja].value}, {})
    check("official export binds the old target", batch[bridge.HEADERS_FIELD]["ja"] == official[0]
          and official[1]["previous_target_sha256"] == bridge.exchange.digest("フォールド"))
    check("ordinary Fold and dictionary key order are preserved", old[ja].value["폴드"]
          == new[ja].value["폴드"] == "フォールド" and list(old[ja].value) == list(new[ja].value))
    validate, inverse = bridge._validate_legacy_ja_rank_correction, bridge._legacy_ja_rank_comparison
    rejects("generic append still rejects an existing JA edit", lambda: bridge.validate_append(before, after, inventory))
    for path in bridge.CURRENT_PATHS:
        rejects("unowned raw whitespace " + path,
                lambda p=path: validate(before, {**after, p: after[p] + b"\n"}, inventory))
    rejects("missing protected snapshot", lambda: validate({p: raw for p, raw in before.items() if p != ja}, after, inventory))
    for label, path, field, value in (
        ("wrong rank target", ja, (key,), "フォールド"),
        ("normal Fold changed", ja, ("폴드",), "フォーカード"),
        ("old batch changed", ledger, ("batches", 0, "order"), "forged"),
        ("source receipt forged", ledger, ("accepted", "ja", leaf.id, "source_sha256"), "0" * 64),
        ("target receipt forged", ledger, ("accepted", "ja", leaf.id, "target_sha256"), "0" * 64),
        ("boolean count", ledger, ("batches", 216, "source_leaves"), True),
        ("prior acceptance claim", ledger, ("batches", 216, "prior_acceptance"), "accepted"),
        ("previous target hash", ledger, ("batches", 216, "before_target_sha256_by_locale", "ja", leaf.id), "0" * 64),
        ("wrong header selection", ledger, ("batches", 216, bridge.HEADERS_FIELD, "ja", "selection_sha256"), "0" * 64),
        ("wrong header revision", ledger, ("batches", 216, bridge.HEADERS_FIELD, "ja", "source_revision"), "0" * 40),
        ("wrong receipt digest", ledger, ("batches", 216, "receipt_sha256_by_locale", "ja"), "0" * 64),
        ("wrong locale population", ledger, ("batches", 216, "target_leaves_by_locale", "zh-CN"), 1),
    ):
        rejects("synthetic " + label, lambda p=path, f=field, v=value: validate(before, edit(after, new, p, f, v), inventory))
    accepted = dict(old[ledger].value["accepted"]["ja"])
    accepted.pop(next(iter(accepted)))
    accepted[leaf.id] = {"source_sha256": leaf.source_sha256, "target_sha256": bridge.exchange.digest("フォールド")}
    rejects("count-preserving invented prior receipt", lambda: validate(
        edit(before, old, ledger, ("accepted", "ja"), accepted), after, inventory))
    prior_batch = {**old[ledger].value["batches"][-1], "roots": [key],
                   "target_leaves_by_locale": {"ja": 1, "zh-CN": 0, "zh-TW": 0}}
    rejects("invented prior JA batch", lambda: validate(edit(before, old, ledger, ("batches", 215), prior_batch), after, inventory))
    accepts = dict(new[ledger].value["accepted"]["ja"])
    accepts.pop(leaf.id)
    rejects("missing first receipt", lambda: validate(before, edit(after, new, ledger, ("accepted", "ja"), accepts), inventory))
    rejects("missing correction batch", lambda: validate(before, edit(after, new, ledger, ("batches",),
            new[ledger].value["batches"][:-1]), inventory))
    forged = copy.deepcopy(batch)
    header = bridge.exchange.make_batch(inventory, "ja", [leaf], bridge.LEGACY_RANK_BEFORE_COMMIT, {}, {})[0]
    forged[bridge.HEADERS_FIELD]["ja"] = header
    forged["receipt_sha256_by_locale"]["ja"] = bridge.exchange.digest({"batch": header,
        "state": "accepted_machine_validated", "native_review": "OPEN",
        "translations": {leaf.id: new[ledger].value["accepted"]["ja"][leaf.id]}})
    rejects("re-signed header concealing an existing target", lambda: validate(
        before, edit(after, new, ledger, ("batches", 216), forged), inventory))
    for field, value in (("source", "다른 패"), ("protected", True), ("runtime_support", "unverified_consumer")):
        rejects("current leaf " + field, lambda f=field, v=value: validate(before, after,
                {**inventory, "leaves": [replace(leaf, **{f: v})]}))
    rejects("duplicate current leaf", lambda: validate(before, after, {**inventory, "leaves": [leaf, leaf]}))
    start, end = new[ja].spans[(key,)]
    escaped = new[ja].text[start:end].replace("フ", "\\u30d5", 1)
    escaped_raw = (new[ja].text[:start] + escaped + new[ja].text[end:]).encode()
    rejects("same-value target raw-token substitution", lambda: inverse({**after, ja: escaped_raw}, before, after))
    tail = new[ja].spans[(list(new[ja].value)[-1],)][1]
    extra = ',\n  "synthetic_tail": "synthetic target"'
    future = {**after, ja: (new[ja].text[:tail] + extra + new[ja].text[tail:]).encode()}
    projected = inverse(future, before, after)
    check("synthetic later UI tail is retained not admitted as a receipt", bridge._loads(projected[ja])
          == {**old[ja].value, "synthetic_tail": "synthetic target"}
          and all(projected[p] == before[p] for p in bridge.CURRENT_PATHS if p != ja))

    def replay(where, *args, **kwargs):
        return responses[(args, kwargs.get("input"))]
    for label, prefix, transform in (
        ("trailing object stream", ("cat-file",), lambda raw: raw + b"forged"),
        ("extra product path", ("diff",), lambda raw: raw + b"M\0outside.json\0"),
    ):
        def fault(where, *args, start=prefix, mutate=transform, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(start)] == start else value
        with patch.object(bridge, "_git", side_effect=fault):
            rejects("captured-Git replay " + label, lambda: bridge._legacy_ja_rank_proof(ROOT, inventory))
    with patch.object(bridge, "_git", side_effect=replay), patch.object(bridge, "LEGACY_RANK_ORIGIN_BLOB", "0" * 40):
        rejects("captured-Git replay wrong origin identity", lambda: bridge._legacy_ja_rank_proof(ROOT, inventory))
    forged_objects = list(payloads[0])
    forged_objects[1] = forged_objects[1].replace(("parent " + bridge.LEGACY_RANK_BEFORE_COMMIT).encode(),
                                                b"parent " + b"0" * 40, 1)
    with patch.object(bridge, "_git", side_effect=replay), patch.object(bridge, "_objects", return_value=forged_objects):
        rejects("synthetic post-object direct-parent fault", lambda: bridge._legacy_ja_rank_proof(ROOT, inventory))
    def no_ancestry(where, *args, **kwargs):
        if args[0] == "merge-base":
            raise ValueError("synthetic missing origin ancestry")
        return replay(where, *args, **kwargs)
    with patch.object(bridge, "_git", side_effect=no_ancestry):
        rejects("captured-Git replay origin ancestry", lambda: bridge._legacy_ja_rank_proof(ROOT, inventory))
    with patch.object(bridge, "_git", side_effect=OSError("synthetic next-call Git loss")):
        rejects("previous success never caches a future failure", lambda: bridge._legacy_ja_rank_proof(ROOT, inventory))
    check("source product and tools unchanged by the focused run", all((ROOT / p).read_bytes() == raw for p, raw in observed.items()))
    check("unique case names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_RANK_JA_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
