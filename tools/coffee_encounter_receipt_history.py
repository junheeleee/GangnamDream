"""ORDER-448 exact coffee correction, separate from generic UI additions.

The five product files have one immutable inverse. Historical UI comparisons
use four UI/ledger files only; current event admission never accepts that
inverse as current input. Git proof is fresh per call, without verdict caches.
"""
from __future__ import annotations

import copy
import hashlib
import re
import subprocess
from pathlib import Path
from typing import Any, Mapping

import full_game_localization as exchange
import coffee_encounter_locale_contract as contract
import order351_source_compat as previous
from order351_source_compat import _Document, _loads, _ordered

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ja", "zh-CN", "zh-TW")
EVENT_PATHS = tuple(f"content/events_{locale}/arc_events.json" for locale in LOCALES)
JA_PATH = "locale/ui_ja.json"
LEDGER_PATH = "content/meta/full_game_localization.json"
CURRENT_PATHS = tuple(f"locale/ui_{locale}.json" for locale in LOCALES) + (LEDGER_PATH,)
PRODUCT_PATHS = (*EVENT_PATHS, JA_PATH, LEDGER_PATH)
PROOF_PATHS = (*EVENT_PATHS, *CURRENT_PATHS)
HEADERS_FIELD = "official_receipt_headers_by_locale"
BATCH_INDEX = 220
COFFEE_REVIEW = (
    "Korean-direct repair of the second coffee encounter, not a second cup: three event titles and the "
    "existing Japanese contact recollection. Four existing targets corrected; three prior event receipts "
    "retain their source hashes and one Japanese UI leaf gains its first official receipt. No new source "
    "keys, gameplay or public-demo changes. Agent review is not native or release approval.")

# Observed from the actual five-file product commit after official acceptance.
COFFEE_BEFORE_COMMIT = "f4e44326b56cb76188de6278625f14181ed190e6"
COFFEE_AFTER_COMMIT = "5ff1e8e72e7de5ef11212bd84d682a94c39e8487"
COFFEE_TREES = ("283a54d359f62e86584695197accbfa0309bae3a", "82b9b8c4e251e594b3f94f0a130522caef8190ee")
COFFEE_BLOBS = {
    "content/events_ja/arc_events.json": ("8624315b55ebc0f88f57283be4f9cba5b8b7f2f0", "627658059d5a71dbd813079df20a5ddb1a74a3ed"),
    "content/events_zh-CN/arc_events.json": ("6f0f7ba26c4fb8bd0a60372287083a6e0482b2b7", "85a5ebea37ab1a576a82b17809a2a53afc20318e"),
    "content/events_zh-TW/arc_events.json": ("19b2577426474282975d2456045858f73566190f", "1d0d0c38a69ed49c90e625f3b299c03d26850176"),
    "locale/ui_ja.json": ("7c77a2870f47c213de28a0f22eae7018bd8cf92b", "e5ab43b2129ffa11196fe0c7681da1740947ca99"),
    "locale/ui_zh-CN.json": ("eb289cf95bb7f288825cd889dfcaf2b4b1181bbf", "eb289cf95bb7f288825cd889dfcaf2b4b1181bbf"),
    "locale/ui_zh-TW.json": ("75cbd88ff7c3af529dba2f4c7d5780486bb60b78", "75cbd88ff7c3af529dba2f4c7d5780486bb60b78"),
    "content/meta/full_game_localization.json": ("5c83b5c6deada067c4c6ce36bce5ee86eb6c4cd3", "c1115b36de0373882cbcb5c640786ec6141d998d"),
}
COFFEE_HASHES = {
    "content/events_ja/arc_events.json": ("807db30f15b0bdcee0cc4cd4d3ea73de5db28f22cdb9958f5416dccabbcf9a99", "90170751c5f6e87ca38594e2d17f9560e30ed650cad1eb2daeb79bb281a30a82"),
    "content/events_zh-CN/arc_events.json": ("366a883fe87eb5b2a4d01c8a19ec6d23ceba2a8e69fb4f4e336cae388016bfdd", "cf430c7267a3bad35249505e3e958eada5822500b64fad74764c15c2f720df0e"),
    "content/events_zh-TW/arc_events.json": ("6f3d348350779de92d9ca226314ce19f4cdbe1dd0e3f4d83b40d9b086f3cb7f1", "8078010d7601695302a61d6864338d21041dc656610a6d94d1ccec02b7c8ecd5"),
    "locale/ui_ja.json": ("ef4cb956fe532886f0a3af4e0d5ac06c660b6d821ed4acdf6d005816ea6d5a0b", "dfe4a83473850ec1bb61a8b3300cbc3ee7630fefb136979777221e77971ac463"),
    "locale/ui_zh-CN.json": ("844edfd0638e0123b26530d3b46094819d5cbf1748bbd674bf36ca5147ea98bd", "844edfd0638e0123b26530d3b46094819d5cbf1748bbd674bf36ca5147ea98bd"),
    "locale/ui_zh-TW.json": ("30bd5b069601c00fcf0a68c49eb547f765d041153d36d2db58d4e8a7fc14721c", "30bd5b069601c00fcf0a68c49eb547f765d041153d36d2db58d4e8a7fc14721c"),
    "content/meta/full_game_localization.json": ("06c1f4c48ca1c81ee3d72a7dee62c07df4a1eeaba63321045ce0dd1a08035d80", "6186aaa75eb4c796ece79b066a12705d2cd28bfdbc70a237bef2b5db533f017b"),
}


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError("ORDER-448 coffee correction: " + message)


def _git(root: Path, *args: str, input: bytes | None = None) -> bytes:
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    require(result.returncode == 0, "Git proof unavailable: " + " ".join(args))
    return result.stdout


def _objects(root: Path, requests: list[tuple[str, str, str]]) -> list[bytes]:
    output = _git(root, "cat-file", "--batch", input=b"".join((r + "\n").encode() for r, _, _ in requests))
    cursor, result = 0, []
    for expression, oid, kind in requests:
        end = output.find(b"\n", cursor)
        header = output[cursor:end].split() if end >= cursor else []
        require(len(header) == 3 and header[:2] == [oid.encode(), kind.encode()] and header[2].isdigit(),
                "missing/forged Git object: " + expression)
        size, cursor = int(header[2]), end + 1
        raw = output[cursor:cursor + size]
        require(len(raw) == size and output[cursor + size:cursor + size + 1] == b"\n"
                and hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest() == oid,
                "altered/truncated Git object: " + expression)
        result.append(raw)
        cursor += size + 1
    require(cursor == len(output), "trailing Git object proof bytes")
    return result


def _event_index(value: Any) -> int:
    exchange.row_index(value, "coffee event overlay")
    indices = [i for i, row in enumerate(value) if row["id"] == contract.EVENT_ID]
    require(len(indices) == 1, "event title owner missing/duplicate")
    return indices[0]


def _apply(document: _Document, edits: list[tuple[int, int, str]]) -> bytes:
    text = document.text
    ordered = sorted(edits)
    require(all(left[1] <= right[0] for left, right in zip(ordered, ordered[1:])), "overlapping inverse edits")
    for start, end, replacement in reversed(ordered):
        text = text[:start] + replacement + text[end:]
    return text.encode()


def _token_edit(doc: _Document, old: _Document, new: _Document, path: tuple) -> tuple[int, int, str]:
    start, end = doc.spans[path]
    first, last = new.spans[path]
    require(doc.text[start:end] == new.text[first:last], "corrected raw token changed: " + str(path))
    first, last = old.spans[path]
    return start, end, old.text[first:last]


def _recall_inverse(current: bytes, before: bytes, after: bytes) -> bytes:
    a, b, doc = map(_Document, (before, after, current))
    key = contract.RECALL_SOURCE
    require(a.value.get(key) == contract.RECALL_BEFORE_TARGET
            and b.value.get(key) == doc.value.get(key) == contract.RECALL_TARGET,
            "Japanese recollection changed/rolled back")
    return _apply(doc, [_token_edit(doc, a, b, (key,))])


def _ledger_inverse(current: bytes, before: bytes, after: bytes) -> bytes:
    a, b, doc = map(_Document, (before, after, current))
    value = doc.value
    require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "current accepted checksum")
    require(len(value["batches"]) >= BATCH_INDEX + 4
            and _ordered(value["batches"][BATCH_INDEX:BATCH_INDEX + 4])
            == _ordered(b.value["batches"][BATCH_INDEX:BATCH_INDEX + 4]),
            "correction batches missing/changed/reordered")
    start = doc.spans[("batches", BATCH_INDEX - 1)][1]
    end = doc.spans[("batches", BATCH_INDEX + 3)][1]
    bs, be = b.spans[("batches", BATCH_INDEX - 1)][1], b.spans[("batches", BATCH_INDEX + 3)][1]
    require(doc.text[start:end] == b.text[bs:be], "correction batch raw changed")
    edits = [(start, end, "")]
    accepted = copy.deepcopy(value["accepted"])
    for locale in LOCALES:
        identifier = contract.EVENT_KEY
        require(_ordered(value["accepted"][locale].get(identifier))
                == _ordered(b.value["accepted"][locale][identifier]), "corrected event receipt changed")
        path = ("accepted", locale, identifier, "target_sha256")
        edits.append(_token_edit(doc, a, b, path))
        accepted[locale][identifier] = copy.deepcopy(a.value["accepted"][locale][identifier])
    old_keys = list(a.value["accepted"]["ja"])
    added = list(b.value["accepted"]["ja"])[len(old_keys):]
    require(bool(old_keys) and added == [contract.RECALL_KEY]
            and list(value["accepted"]["ja"])[len(old_keys):len(old_keys) + 1] == added
            and _ordered(value["accepted"]["ja"].get(added[0]))
            == _ordered(b.value["accepted"]["ja"][added[0]]), "first Japanese receipt changed/order differs")
    start, end = doc.spans[("accepted", "ja", old_keys[-1])][1], doc.spans[("accepted", "ja", added[0])][1]
    bs, be = b.spans[("accepted", "ja", old_keys[-1])][1], b.spans[("accepted", "ja", added[0])][1]
    require(doc.text[start:end] == b.text[bs:be], "first Japanese receipt raw changed")
    edits.append((start, end, ""))
    del accepted["ja"][added[0]]
    start, end = doc.spans[("accepted_sha256",)]
    edits.append((start, end, _ordered(exchange.digest(accepted)).decode()))
    return _apply(doc, edits)


def coffee_product_inverse(current: Mapping[str, bytes], before: Mapping[str, bytes]) -> dict[str, bytes]:
    """Pure exact five-file inverse, not a current admission API."""
    require(set(current) == set(before) == set(PRODUCT_PATHS), "exact five product paths required")
    result = dict(current)
    for locale, relative in zip(LOCALES, EVENT_PATHS):
        a, b = _Document(before[relative]), _Document(current[relative])
        index = _event_index(a.value)
        require(_event_index(b.value) == index
                and a.value[index].get("title") == contract.EVENT_BEFORE_TARGETS[locale]
                and b.value[index].get("title") == contract.EVENT_TARGETS[locale], "event title old/new identity differs")
        result[relative] = _apply(b, [_token_edit(b, a, b, (index, "title"))])
    result[JA_PATH] = _recall_inverse(current[JA_PATH], before[JA_PATH], current[JA_PATH])
    result[LEDGER_PATH] = _ledger_inverse(current[LEDGER_PATH], before[LEDGER_PATH], current[LEDGER_PATH])
    require(result == dict(before), "bytes outside exact coffee correction changed")
    return result


def coffee_encounter_comparison(snapshot: Mapping[str, bytes], before: Mapping[str, bytes],
                                after: Mapping[str, bytes]) -> dict[str, bytes]:
    """Undo proved four-target receipts/UI text while retaining later appends."""
    require(set(snapshot) == set(before) == set(after) == set(CURRENT_PATHS), "exact current UI4 comparison required")
    require(all(before[p] == after[p] for p in CURRENT_PATHS if p not in (JA_PATH, LEDGER_PATH)),
            "protected Chinese UI changed")
    result = dict(snapshot)
    result[JA_PATH] = _recall_inverse(snapshot[JA_PATH], before[JA_PATH], after[JA_PATH])
    result[LEDGER_PATH] = _ledger_inverse(snapshot[LEDGER_PATH], before[LEDGER_PATH], after[LEDGER_PATH])
    return result


def validate_coffee_correction(before: Mapping[str, bytes], after: Mapping[str, bytes],
                              inventory: dict[str, Any]) -> dict[str, Any]:
    require(set(before) == set(after) == set(PRODUCT_PATHS), "exact five product paths required")
    old, new = ({p: _loads(raw) for p, raw in snapshot.items()} for snapshot in (before, after))
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(len(a["batches"]) == BATCH_INDEX and len(b["batches"]) == BATCH_INDEX + 4
            and sum(map(len, a["accepted"].values())) == 41740
            and sum(map(len, b["accepted"].values())) == 41741,
            "three receipt replacements/one first receipt/four batches census differs")
    require(all(v["accepted_sha256"] == exchange.digest(v["accepted"]) for v in (a, b)), "accepted checksum mismatch")
    leaves = (
        exchange.Leaf("events", contract.EVENT_ID, contract.EVENT_SOURCE_PATH, ("title",),
                      contract.EVENT_SOURCE, "event_standard", lifecycle="shipping"),
        exchange.Leaf("ui", contract.RECALL_SOURCE, contract.RECALL_SOURCE_PATH, (contract.RECALL_SOURCE,),
                      contract.RECALL_SOURCE, "ui_static_context"))
    require(tuple(leaf.source_sha256 for leaf in leaves)
            == (contract.EVENT_SOURCE_SHA256, contract.RECALL_SOURCE_SHA256), "fixed Korean leaf digest differs")
    selected = [leaf for leaf in inventory["leaves"] if leaf.id in {item.id for item in leaves}]
    require(len(selected) == 2 and _ordered({leaf.id: vars(leaf) for leaf in sorted(selected, key=lambda leaf: leaf.id)})
            == _ordered({leaf.id: vars(leaf) for leaf in sorted(leaves, key=lambda leaf: leaf.id)}),
            "current Korean leaf/protection/support differs")
    require(contract.RECALL_KEY not in a["accepted"]["ja"]
            and not any(contract.RECALL_SOURCE in row.get("roots", [])
                        and row.get("target_leaves_by_locale", {}).get("ja", 0) for row in a["batches"]),
            "Japanese recollection falsely claims absent prior acceptance")
    accepted, manifests = copy.deepcopy(a["accepted"]), {}
    units = [(locale, leaves[0], path, contract.EVENT_BEFORE_TARGETS[locale], contract.EVENT_TARGETS[locale], "existing")
             for locale, path in zip(LOCALES, EVENT_PATHS)]
    units.append(("ja", leaves[1], JA_PATH, contract.RECALL_BEFORE_TARGET, contract.RECALL_TARGET, "absent"))
    for offset, (locale, leaf, relative, old_target, target, prior) in enumerate(units):
        receipt = {"source_sha256": leaf.source_sha256, "target_sha256": exchange.digest(target)}
        if prior == "existing":
            require(accepted[locale].get(leaf.id) == {"source_sha256": leaf.source_sha256,
                                                    "target_sha256": exchange.digest(old_target)}, "old event receipt differs")
        require(not exchange.translation_errors(leaf, locale, target), "corrected translation contract failed")
        batch = b["batches"][BATCH_INDEX + offset]
        expected = {"order": "ORDER-448", "group": leaf.group + "_correction", "roots": [leaf.owner],
                    "source_leaves": 1, "prior_acceptance": prior,
                    "before_target_sha256_by_locale": {locale: {leaf.id: exchange.digest(old_target)}},
                    "target_leaves_by_locale": {loc: int(loc == locale) for loc in LOCALES},
                    "source_review": COFFEE_REVIEW, "machine_validation": "PASS", "rendered_review": "OPEN", "native_review": "OPEN"}
        require(isinstance(batch, dict) and set(batch) == set(expected) | {HEADERS_FIELD, "receipt_sha256_by_locale"}
                and all(_ordered(batch[k]) == _ordered(v) for k, v in expected.items())
                and all(isinstance(batch[k], dict) and set(batch[k]) == {locale}
                        for k in (HEADERS_FIELD, "receipt_sha256_by_locale")), "correction batch identity/order/population differs")
        header = batch[HEADERS_FIELD][locale]
        require(header.get("source_revision") == COFFEE_BEFORE_COMMIT
                and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))),
                "official export revision/manifest differs")
        documents = {relative: old[relative]}
        files = {contract.EVENT_ID: relative} if leaf.group == "events" else {}
        require(exchange.target_value(leaf, documents, locale, files) == old_target, "old target differs from export")
        rebuilt = exchange.make_batch({**inventory, "source_manifest_sha256": header["source_manifest_sha256"]},
                                      locale, [leaf], COFFEE_BEFORE_COMMIT, documents, files)[0]
        require(_ordered(header) == _ordered(rebuilt), "official previous-target/header selection differs")
        official = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                    "translations": {leaf.id: receipt}}
        require(batch["receipt_sha256_by_locale"][locale] == exchange.digest(official), "official receipt digest differs")
        accepted[locale][leaf.id] = receipt
        revision, manifest = header["source_revision"], header["source_manifest_sha256"]
        require(revision not in manifests or manifests[revision] == manifest, "one export revision claims multiple manifests")
        manifests[revision] = manifest
    require(_ordered(b) == _ordered({**a, "accepted": accepted, "accepted_sha256": exchange.digest(accepted),
                                    "batches": [*a["batches"], *b["batches"][BATCH_INDEX:]]}),
            "other accepted receipt/ledger member/order changed")
    coffee_product_inverse(after, before)
    return {"ui_by_locale": {locale: 0 for locale in LOCALES}, "receipts": 0, "batches": 0,
            "corrections": 4, "correction_batches": 4, "first_receipts": 1, "source_manifests": manifests}


def _read_pair(root: Path) -> tuple[dict[str, bytes], dict[str, bytes]]:
    require(COFFEE_BEFORE_COMMIT is not None and COFFEE_AFTER_COMMIT is not None,
            "product pins not bound; no observed product commit yet")
    revisions = (COFFEE_BEFORE_COMMIT, COFFEE_AFTER_COMMIT)
    require(all(re.fullmatch(r"[0-9a-f]{40}", value) for value in revisions)
            and len(COFFEE_TREES) == 2 and set(COFFEE_BLOBS) == set(COFFEE_HASHES) == set(PROOF_PATHS),
            "immutable pin population malformed")
    requests = [(c, c, "commit") for c in revisions] + [(t, t, "tree") for t in COFFEE_TREES]
    requests += [(c + ":" + p, COFFEE_BLOBS[p][i], "blob") for p in PROOF_PATHS for i, c in enumerate(revisions)]
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([h for h in headers if h.startswith(b"tree ")] == [b"tree " + COFFEE_TREES[index].encode()],
                "exact tree mismatch")
        if index:
            require([h for h in headers if h.startswith(b"parent ")] == [b"parent " + revisions[0].encode()], "direct parent mismatch")
    require(_git(root, "diff", "--name-status", "-z", *revisions).split(b"\0")
            == [v for p in sorted(PRODUCT_PATHS) for v in (b"M", p.encode())] + [b""], "product path population differs")
    before, after = {}, {}
    for index, path in enumerate(PROOF_PATHS):
        old, new = values[4 + index * 2:6 + index * 2]
        require(tuple(hashlib.sha256(v).hexdigest() for v in (old, new)) == COFFEE_HASHES[path], "immutable whole raw differs: " + path)
        before[path], after[path] = old, new
    require(all(before[p] == after[p] for p in CURRENT_PATHS if p not in PRODUCT_PATHS), "protected Chinese UI changed")
    coffee_product_inverse({p: after[p] for p in PRODUCT_PATHS}, {p: before[p] for p in PRODUCT_PATHS})
    return before, after


def coffee_encounter_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict]:
    before, after = _read_pair(root)
    change = validate_coffee_correction({p: before[p] for p in PRODUCT_PATHS},
                                       {p: after[p] for p in PRODUCT_PATHS}, inventory)
    return ({p: before[p] for p in CURRENT_PATHS}, {p: after[p] for p in CURRENT_PATHS}, change)


def coffee_encounter_current_events(root: Path = ROOT) -> dict[str, bytes]:
    """Fresh exact event3 HEAD/disk bytes; no old/new mixtures or inverse view."""
    import order470_source_compat as successor

    root = Path(root).resolve()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", head) is not None, "invalid current Git candidate")
    before, after = _read_pair(root)
    with previous.fresh_validation_proof():
        for path in EVENT_PATHS:
            require(not previous.source_errors(before[path], path),
                    "event predecessor is not the unchanged historical current source: " + path)
    _git(root, "merge-base", "--is-ancestor", COFFEE_AFTER_COMMIT, head)
    with successor.fresh_validation_proof(root) as proof:
        require(proof is successor._ACTIVE.get() and proof["root"] == root and proof["head"] == head,
                "successor proof is not the active current candidate")
        require(EVENT_PATHS == successor.ARC_PATHS[2:]
                and all(proof["before"][p] == after[p] for p in EVENT_PATHS),
                "successor comparison differs from immutable coffee events")
        # The old448 blobs remain historical pins. Only a separately proved
        # exact470 current image may replace them at this current-only boundary.
        current = {p: proof["current"][p] for p in EVENT_PATHS}
        ids = _git(root, "rev-parse", *(head + ":" + p for p in EVENT_PATHS)).decode().splitlines()
        expected = [hashlib.sha1(b"blob " + str(len(current[p])).encode() + b"\0" + current[p]).hexdigest()
                    for p in EVENT_PATHS]
        require(ids == expected, "current event HEAD blobs differ")
        actual = _objects(root, [(head + ":" + p, oid, "blob") for p, oid in zip(EVENT_PATHS, ids)])
        result = {p: raw for p, raw in zip(EVENT_PATHS, actual)}
        require(all(result[p] == current[p] == (root / p).read_bytes() for p in EVENT_PATHS),
                "current event raw differs from Git")
        require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
                "Git candidate changed during current event admission")
    return result
