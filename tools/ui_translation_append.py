#!/usr/bin/env python3
"""Validate portable, append-only prepared-language UI receipts above a base.

The caller owns and verifies the historical base. This module admits actual
current bytes; its inverse is an internal preservation proof, never a UI view.
No private receipts, mutable success cache, or historical consumer are used.
"""
from __future__ import annotations

import hashlib
import re
import subprocess
from collections import Counter
from pathlib import Path
from typing import Any, Mapping

import full_game_localization as exchange
from order351_source_compat import _Document, _loads, _ordered

LOCALES = ("zh-CN", "zh-TW")
UI_PATHS = tuple(f"locale/ui_{locale}.json" for locale in LOCALES)
LEDGER_PATH = "content/meta/full_game_localization.json"
PATHS = (*UI_PATHS, LEDGER_PATH)
# Keep the original CN/TW fixture interface. Production admits all three locales.
CURRENT_LOCALES = ("ja", *LOCALES)
CURRENT_UI_PATHS = tuple(f"locale/ui_{locale}.json" for locale in CURRENT_LOCALES)
CURRENT_PATHS = (*CURRENT_UI_PATHS, LEDGER_PATH)
HEADERS_FIELD = "official_receipt_headers_by_locale"

# A separately reviewed font-only source transition. These are not replacement
# receipt/manifest pins: actual current source and old export headers stay intact.
ARUBA_FONT_PATH = "scenes/ArubaGame.gd"
ARUBA_FONT_BEFORE_COMMIT = "9998e51a439d802a4aeb0e0b782da9771cebbf93"
ARUBA_FONT_AFTER_COMMIT = "e97c49df8154112070110853682f442e14c9df17"
ARUBA_FONT_BEFORE_TREE = "4d1997a138cefbf52de9f35f7b4530e5020098ad"
ARUBA_FONT_AFTER_TREE = "2fcdee19ca18b7ca9d73c4301f2ba08338b51a9d"
ARUBA_FONT_BEFORE_BLOB = "de6cd3120dd2d9dedec0d06d84e641fe98499c8f"
ARUBA_FONT_AFTER_BLOB = "d993990160a7a77c6c0b3113ce62ffe484563a73"
ARUBA_FONT_BEFORE_SHA256 = "058aa08f6963f8a68d98a6eb643ead0e3d4881df834658bc5a44168ffd3bb05e"
ARUBA_FONT_AFTER_SHA256 = "e9744c1467a3043f91f77f7c9faa7ab2039e55777311e90b8ae43d889bfc4eeb"
ARUBA_FONT_ANCHOR = (b"func _ready() -> void:\n\t_rng.randomize()\n"
                     b"\tset_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)\n")
ARUBA_FONT_ADDITION = (b"\tvar local_theme := Theme.new()\n"
                       b"\tlocal_theme.default_font = FontKit.ui_regular()\n"
                       b"\ttheme = local_theme\n")

# One reviewed correction, not permission to edit arbitrary accepted UI rows.
# The product author supplies these immutable commit/blob pins before admission.
CORRECTION_KEY = "마포 첫 면접 완료 · 다음 지원 진행 중"
CORRECTION_BEFORE_COMMIT = "77272537e6938ba766f709c5f459c5b3109c8ad3"
CORRECTION_AFTER_COMMIT = "14547a1e3c552616236c40693c368dcdfd86ebe4"
CORRECTION_TREES = ("2b9c97a0b7d39da10fc2edac712b1ba8fb0e718f", "21a0dc6d5f8268c3be536b4d28800c13bf22ea0c")
CORRECTION_BLOBS = {
    "locale/ui_zh-CN.json": ("bfa0de38df1ba24c7deb34fecad77c2fdda616a7", "1dd77bc738b7d23fd4df6e43dc7755c7d5001a7b"),
    "locale/ui_zh-TW.json": ("d0fe32e709e23c2f2459254a4a0a0fc48a38f5cd", "8411f9ccbef3d7c44e384ae07b57d31654a1dcf7"),
    "content/meta/full_game_localization.json": ("2b073a19b698b00a8be4f3a877ae1af22959e4a3", "dd00caf06a13e26965e4214cf1ddccffe36f6be8"),
}
CORRECTION_HASHES = {
    "locale/ui_zh-CN.json": ("809a80896d79cde7aefbb5084040e08737118a870fdd114218cef6105653456c", "1739c179a6cc929c811f41e6af7d37a0c2945a26c44cdd59e209fb2eaeac35a6"),
    "locale/ui_zh-TW.json": ("1cb030b544d38eb793a1cd0fc7bbcb4fd84c8da992b4b42ec5c3bf9bd16f50d9", "d871fa4cfe8f177e22ad3a804cdadb99908913d11d1ca9121095486a634b204a"),
    "content/meta/full_game_localization.json": ("1fb163fb26890d27c22dddaba4ebd1a624236e5b1643ede9210a2b5d92d0d650", "063cc7ce4ad53d8a7e80a71ee0b838aeeea2686722a34b92daef034074e5437c"),
}
CORRECTION_TEXTS = {
    "zh-CN": ("麻浦首次面试已完成 · 正在申请下一份工作", "麻浦首次面试完成 · 后续应聘中"),
    "zh-TW": ("已完成麻浦首次面試 · 正在應徵下一份工作", "麻浦首場面試完成 · 後續應徵中"),
}
CORRECTION_REVIEW = (
    "Korean-direct concise status repair after actual 292px/288px clipping. Same first interview completed "
    "and follow-up application in progress; no gameplay change. Correction is not new coverage.")


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError("UI append: " + message)


def receipt_id(key: str) -> str:
    return "ui:" + key + ":/" + key.replace("~", "~0").replace("/", "~1")


def _tail(document: _Document, path: tuple, old: list, new: list) -> tuple:
    require(bool(old) and len(new) > len(old) and new[:len(old)] == old,
            "members are not an exact nonempty-prefix append")
    return document.spans[(*path, old[-1])][1], document.spans[(*path, new[-1])][1], ""


def _raw_inverse(before: bytes, after: bytes, relative: str) -> None:
    old, new = _Document(before), _Document(after)
    replacements = []
    if relative in CURRENT_UI_PATHS:
        if len(new.value) > len(old.value):
            replacements.append(_tail(new, (), list(old.value), list(new.value)))
    else:
        for locale in CURRENT_LOCALES:
            a, b = old.value["accepted"][locale], new.value["accepted"][locale]
            if len(b) > len(a):
                replacements.append(_tail(new, ("accepted", locale), list(a), list(b)))
        a, b = old.value["batches"], new.value["batches"]
        if len(b) > len(a):
            replacements.append(_tail(new, ("batches",), list(range(len(a))), list(range(len(b)))))
        start, end = new.spans[("accepted_sha256",)]
        a, b = old.spans[("accepted_sha256",)]
        replacements.append((start, end, old.text[a:b]))
    text = new.text
    for start, end, replacement in sorted(replacements, reverse=True):
        text = text[:start] + replacement + text[end:]
    require(text.encode() == before, "bytes outside exact additions changed: " + relative)


def validate_append(before: Mapping[str, bytes], after: Mapping[str, bytes],
                    inventory: dict[str, Any]) -> dict[str, Any]:
    """Pure transition checks, also used with explicit synthetic test fixtures."""
    require(set(before) == set(after) and set(before) in (set(PATHS), set(CURRENT_PATHS)),
            "exact three- or four-path snapshot required")
    locales = CURRENT_LOCALES if set(before) == set(CURRENT_PATHS) else LOCALES
    ui_paths = tuple(f"locale/ui_{locale}.json" for locale in locales)
    old = {path: _Document(before[path]).value for path in before}
    new = {path: _Document(after[path]).value for path in after}
    additions = {}
    for locale, path in zip(locales, ui_paths):
        a, b = old[path], new[path]
        require(isinstance(a, dict) and isinstance(b, dict), "UI dictionary shape: " + locale)
        require(list(b)[:len(a)] == list(a)
                and _ordered({key: b[key] for key in a}) == _ordered(a),
                "old UI member/order/value changed: " + locale)
        additions[locale] = {key: b[key] for key in list(b)[len(a):]}
        require(all(isinstance(text, str) and text.strip() for text in additions[locale].values()),
                "blank/nontext UI addition: " + locale)
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(isinstance(a, dict) and isinstance(b, dict) and list(a) == list(b), "ledger shape/order changed")
    mutable = {"accepted", "accepted_sha256", "batches"}
    require(_ordered({k: v for k, v in a.items() if k not in mutable})
            == _ordered({k: v for k, v in b.items() if k not in mutable}), "old ledger metadata changed")
    require(isinstance(a["accepted"], dict) and isinstance(b["accepted"], dict)
            and list(a["accepted"]) == list(b["accepted"])
            and set(b["accepted"]) == {"ja", *LOCALES}, "receipt locale/order changed")
    for value in (a, b):
        require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "accepted checksum mismatch")
    receipt_additions = {}
    for locale in b["accepted"]:
        previous, current = a["accepted"][locale], b["accepted"][locale]
        require(isinstance(previous, dict) and isinstance(current, dict)
                and list(current)[:len(previous)] == list(previous)
                and _ordered({k: current[k] for k in previous}) == _ordered(previous),
                "old receipt changed/deleted/reordered: " + locale)
        receipt_additions[locale] = {key: current[key] for key in list(current)[len(previous):]}
    require("ja" in locales or not receipt_additions["ja"],
            "Japanese receipt requires the Japanese UI snapshot")
    require(isinstance(a["batches"], list) and isinstance(b["batches"], list)
            and _ordered(b["batches"][:len(a["batches"])]) == _ordered(a["batches"]),
            "old batches changed/deleted/reordered")
    batches = b["batches"][len(a["batches"]):]
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    require(len(leaves) == len(inventory["leaves"]), "duplicate current source leaf ID")
    for locale in locales:
        expected = {}
        for key, text in additions[locale].items():
            leaf = leaves.get(receipt_id(key))
            require(leaf is not None and leaf.group == "ui" and leaf.owner == key and leaf.path == (key,)
                    and leaf.runtime_support == "builtin_overlay_static_only" and not leaf.protected,
                    "unknown/protected/unsupported current UI key: " + key)
            errors = exchange.translation_errors(leaf, locale, text)
            require(not errors, "translation rejected " + locale + ":" + key + ": " + "; ".join(errors))
            expected[leaf.id] = {"source_sha256": leaf.source_sha256, "target_sha256": exchange.digest(text)}
        require(receipt_additions[locale] == expected, "UI/receipt/source/target additions differ: " + locale)
    assigned = {locale: set() for locale in locales}
    manifests = {}
    for batch in batches:
        require(isinstance(batch, dict) and batch.get("group") == "ui"
                and isinstance(batch.get("order"), str) and bool(batch["order"])
                and batch.get("machine_validation") == "PASS" and batch.get("native_review") == "OPEN",
                "new batch must be a machine-accepted UI unit, not native approval")
        roots = batch.get("roots")
        require(isinstance(roots, list) and bool(roots) and all(isinstance(k, str) for k in roots)
                and len(set(roots)) == len(roots) and type(batch.get("source_leaves")) is int
                and batch["source_leaves"] == len(roots),
                "new batch roots/count mismatch")
        counts = batch.get("target_leaves_by_locale")
        require(isinstance(counts, dict) and set(counts) == {"ja", *LOCALES}
                and all(type(counts[loc]) is int and counts[loc] in (0, len(roots)) for loc in CURRENT_LOCALES)
                and ("ja" in locales or counts["ja"] == 0),
                "new batch locale/count mismatch")
        batch_locales = {loc for loc in locales if counts[loc]}
        headers, hashes = batch.get(HEADERS_FIELD), batch.get("receipt_sha256_by_locale")
        require(bool(batch_locales) and isinstance(headers, dict) and isinstance(hashes, dict)
                and set(headers) == set(hashes) == batch_locales, "portable official receipt headers/locales missing")
        ids = {receipt_id(key) for key in roots}
        for locale in batch_locales:
            require(not assigned[locale].intersection(ids) and ids <= set(receipt_additions[locale]),
                    "duplicate/orphan/out-of-batch receipt: " + locale)
            header = headers[locale]
            require(isinstance(header, dict) and re.fullmatch(r"[0-9a-f]{40}", str(header.get("source_revision", "")))
                    and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))),
                    "portable receipt revision/manifest malformed")
            # Rebuild the exact official source-row selection. These are new
            # targets, so the prior target is None. validate_history separately
            # binds this manifest to both actual historical Git and current KO.
            receipt_inventory = {**inventory, "source_manifest_sha256": header["source_manifest_sha256"]}
            selected = sorted((leaves[key] for key in ids), key=lambda leaf: leaf.id)
            rebuilt = exchange.make_batch(receipt_inventory, locale, selected, header["source_revision"], {}, {})[0]
            require(_ordered(header) == _ordered(rebuilt), "official receipt header/selection differs: " + locale)
            receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                       "translations": {key: receipt_additions[locale][key] for key in sorted(ids)}}
            require(hashes[locale] == exchange.digest(receipt), "official receipt digest differs: " + locale)
            assigned[locale].update(ids)
            revision = header["source_revision"]
            require(revision not in manifests or manifests[revision] == header["source_manifest_sha256"],
                    "one source revision claims different manifests")
            manifests[revision] = header["source_manifest_sha256"]
    require(all(assigned[loc] == set(receipt_additions[loc]) for loc in locales),
            "new receipts lack exactly one official unit batch")
    for path in before:
        _raw_inverse(before[path], after[path], path)
    return {"ui_by_locale": {loc: len(additions[loc]) for loc in locales}, "batches": len(batches),
            "receipts": sum(len(v) for v in receipt_additions.values()), "source_manifests": manifests}


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


def _snapshot(root: Path, revision: str, paths=PATHS) -> dict[str, bytes]:
    expressions = [revision + ":" + path for path in paths]
    ids = _git(root, "rev-parse", *expressions).decode().splitlines()
    require(len(ids) == len(paths) and all(re.fullmatch(r"[0-9a-f]{40}", oid) for oid in ids),
            "current Git file identities malformed")
    return dict(zip(paths, _objects(root, [(expr, oid, "blob") for expr, oid in zip(expressions, ids)])))


def aruba_font_predecessor(root: Path, raw: bytes) -> bytes:
    """Exact comparison-only inverse; old runtime bytes are never current input."""
    require(isinstance(raw, bytes) and hashlib.sha256(raw).hexdigest() == ARUBA_FONT_AFTER_SHA256,
            "Aruba current runtime differs from exact font successor")
    values = _objects(root, [
        (ARUBA_FONT_BEFORE_COMMIT, ARUBA_FONT_BEFORE_COMMIT, "commit"),
        (ARUBA_FONT_AFTER_COMMIT, ARUBA_FONT_AFTER_COMMIT, "commit"),
        (ARUBA_FONT_BEFORE_TREE, ARUBA_FONT_BEFORE_TREE, "tree"),
        (ARUBA_FONT_AFTER_TREE, ARUBA_FONT_AFTER_TREE, "tree"),
        (ARUBA_FONT_BEFORE_COMMIT + ":" + ARUBA_FONT_PATH, ARUBA_FONT_BEFORE_BLOB, "blob"),
        (ARUBA_FONT_AFTER_COMMIT + ":" + ARUBA_FONT_PATH, ARUBA_FONT_AFTER_BLOB, "blob"),
    ])
    old_headers, new_headers = (value.split(b"\n\n", 1)[0].splitlines() for value in values[:2])
    require([line for line in old_headers if line.startswith(b"tree ")] == [b"tree " + ARUBA_FONT_BEFORE_TREE.encode()]
            and [line for line in new_headers if line.startswith(b"tree ")] == [b"tree " + ARUBA_FONT_AFTER_TREE.encode()]
            and [line for line in new_headers if line.startswith(b"parent ")] == [b"parent " + ARUBA_FONT_BEFORE_COMMIT.encode()],
            "Aruba exact font parent/tree mismatch")
    require(_git(root, "diff", "--name-status", "-z", ARUBA_FONT_BEFORE_COMMIT, ARUBA_FONT_AFTER_COMMIT).split(b"\0")
            == [b"M", ARUBA_FONT_PATH.encode(), b""], "Aruba font transition is not exactly one modified file")
    _git(root, "merge-base", "--is-ancestor", ARUBA_FONT_AFTER_COMMIT, "HEAD")
    require(_git(root, "rev-parse", "HEAD:" + ARUBA_FONT_PATH).decode().strip() == ARUBA_FONT_AFTER_BLOB,
            "actual Git candidate does not retain the exact Aruba font successor")
    before, after = values[4:]
    require(hashlib.sha256(before).hexdigest() == ARUBA_FONT_BEFORE_SHA256 and after == raw,
            "Aruba font Git blobs/current raw mismatch")
    require(before.count(ARUBA_FONT_ANCHOR) == after.count(ARUBA_FONT_ANCHOR + ARUBA_FONT_ADDITION) == 1
            and ARUBA_FONT_ADDITION not in before and after.count(ARUBA_FONT_ADDITION) == 1
            and after.replace(ARUBA_FONT_ANCHOR + ARUBA_FONT_ADDITION, ARUBA_FONT_ANCHOR, 1) == before,
            "Aruba source changed outside exact local font three lines")
    return before


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    """Keep actual inventory; normalize one proved font file only for comparison."""
    if expected == inventory["source_manifest_sha256"]:
        return True
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"], "current source census digest mismatch")
    raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(raw).hexdigest(), "Aruba source census not bound to current raw")
    predecessor = aruba_font_predecessor(root, raw)
    comparison = {**hashes, ARUBA_FONT_PATH: hashlib.sha256(predecessor).hexdigest()}
    return exchange.digest(comparison) == expected


def _source_manifest(root: Path, revision: str) -> str:
    """Reproduce collect's source-file census from actual historical Git blobs.

    No caller-supplied file list or manifest is trusted. The current collector's
    discovery rules are deliberately reused; incompatible future rule changes
    fail closed instead of silently changing the meaning of an old receipt.
    """
    import demo_localization_scope as demo
    import ja_translation_pipeline as ja
    from third_party_notice_ui import SOURCE_PATHS
    _objects(root, [(revision, revision, "commit")])
    files = {}
    for entry in _git(root, "ls-tree", "-r", "-z", revision).split(b"\0"):
        if not entry:
            continue
        meta, name = entry.split(b"\t", 1)
        mode, kind, oid = meta.decode().split()
        path = name.decode()
        if kind == "blob":
            files[path] = (mode, oid)
    required = {"content/endings.json", "content/meta/event_lifecycle.json",
                "content/meta/demo_localization_scope.json", "playtests/order124/StoryChoiceM1M6Playtest.gd",
                *SOURCE_PATHS, *(value[0] for value in ja.CATALOG_SOURCES.values())}
    required.update(path for path in files if re.fullmatch(r"content/events/[^/]+\.json", path))
    required.update(path for path in files if path.endswith(".gd")
                    and path.split("/", 1)[0] in ja.RUNTIME_DIRS)
    candidates = {path for path in files if path.startswith("content/") and path.endswith(".json")
                  and not any(part.startswith("events_") for part in Path(path).parts)
                  and not re.search(r"endings_[^.]+\.json$", Path(path).name)
                  and Path(path).name != "full_game_localization.json"}
    requested = sorted(required | candidates)
    require(set(requested) <= files.keys() and all(files[p][0] in {"100644", "100755"} for p in requested),
            "historical source population missing/nonregular")
    blobs = dict(zip(requested, _objects(root, [(revision + ":" + p, files[p][1], "blob") for p in requested])))
    for path in candidates:
        value = exchange.loads(blobs[path].decode())
        pairs, _ = demo.collect_json_suffix_pairs(value, path)
        inline, _ = demo.collect_json_inline_pairs(value, path)
        if pairs or inline:
            required.add(path)
    return exchange.digest({path: hashlib.sha256(blobs[path]).hexdigest() for path in sorted(required)})


def _correction_comparison(snapshot: Mapping[str, bytes], before: Mapping[str, bytes],
                           after: Mapping[str, bytes]) -> dict[str, bytes]:
    """Undo only the proved correction; never expose this as current UI data.

    Later pure appends may follow it. Their bytes are retained, while the fixed
    correction row, its two targets and checksum are restored for comparison.
    """
    require(set(snapshot) in (set(PATHS), set(CURRENT_PATHS))
            and set(before) == set(after) == set(PATHS), "correction snapshot population")
    result = dict(snapshot)
    receipt = receipt_id(CORRECTION_KEY)
    for locale, path in zip(LOCALES, UI_PATHS):
        a, b = _Document(before[path]), _Document(after[path])
        doc = b if snapshot[path] == after[path] else _Document(snapshot[path])
        require(doc.value.get(CORRECTION_KEY) == CORRECTION_TEXTS[locale][1],
                "corrected UI rolled back/changed: " + locale)
        start, end = doc.spans[(CORRECTION_KEY,)]
        bs, be = b.spans[(CORRECTION_KEY,)]
        require(doc.text[start:end] == b.text[bs:be], "corrected UI token formatting changed: " + locale)
        first, last = a.spans[(CORRECTION_KEY,)]
        result[path] = (doc.text[:start] + a.text[first:last] + doc.text[end:]).encode()
    a, b = _Document(before[LEDGER_PATH]), _Document(after[LEDGER_PATH])
    doc = b if snapshot[LEDGER_PATH] == after[LEDGER_PATH] else _Document(snapshot[LEDGER_PATH])
    value = doc.value
    require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "corrected accepted checksum")
    require(len(value["batches"]) >= 149
            and _ordered(value["batches"][148]) == _ordered(b.value["batches"][148]),
            "correction batch missing/changed/reordered")
    start, end = doc.spans[("batches", 147)][1], doc.spans[("batches", 148)][1]
    bs, be = b.spans[("batches", 147)][1], b.spans[("batches", 148)][1]
    require(doc.text[start:end] == b.text[bs:be], "correction batch raw formatting changed")
    replacements = [(start, end, "")]
    restored_accepted = dict(value["accepted"])
    for locale in LOCALES:
        require(_ordered(value["accepted"][locale][receipt]) == _ordered(b.value["accepted"][locale][receipt]),
                "corrected source/target receipt changed: " + locale)
        path = ("accepted", locale, receipt, "target_sha256")
        start, end = doc.spans[path]
        bs, be = b.spans[path]
        require(doc.text[start:end] == b.text[bs:be], "corrected receipt token formatting changed: " + locale)
        first, last = a.spans[path]
        replacements.append((start, end, a.text[first:last]))
        restored_accepted[locale] = {**value["accepted"][locale], receipt: {
            **value["accepted"][locale][receipt],
            "target_sha256": a.value["accepted"][locale][receipt]["target_sha256"]}}
    start, end = doc.spans[("accepted_sha256",)]
    replacements.append((start, end, _ordered(exchange.digest(restored_accepted)).decode()))
    text = doc.text
    for start, end, replacement in sorted(replacements, reverse=True):
        text = text[:start] + replacement + text[end:]
    result[LEDGER_PATH] = text.encode()
    return result


def _validate_correction(before: Mapping[str, bytes], after: Mapping[str, bytes],
                         inventory: dict[str, Any]) -> dict[str, Any]:
    """Exact two-target semantics, official receipts, census and full raw inverse."""
    require(set(before) == set(after) == set(PATHS), "correction requires the exact three product paths")
    # Reject semantic failures with the same strict decoder before building
    # literal spans for the full raw inverse. No result survives this call.
    old = {p: _loads(v) for p, v in before.items()}
    new = {p: _loads(v) for p, v in after.items()}
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(len(a["batches"]) == 148 and len(b["batches"]) == 149
            and sum(map(len, a["accepted"].values())) == sum(map(len, b["accepted"].values())) == 40832,
            "correction is two existing receipts, not new coverage")
    require(a["accepted_sha256"] == exchange.digest(a["accepted"])
            and b["accepted_sha256"] == exchange.digest(b["accepted"]), "correction accepted checksum mismatch")
    expected_leaf = exchange.Leaf("ui", CORRECTION_KEY, "runtime:static_ui", (CORRECTION_KEY,),
                                  CORRECTION_KEY, "ui_static_context")
    selected = [leaf for leaf in inventory["leaves"] if leaf.id == expected_leaf.id]
    require(len(selected) == 1 and _ordered(vars(selected[0])) == _ordered(vars(expected_leaf)),
            "correction current Korean leaf/protection/support mismatch")
    batch = b["batches"][148]
    fields = {"order", "group", "roots", "source_leaves", "target_leaves_by_locale", "original_order",
              "before_target_sha256_by_locale", "source_review", "machine_validation", "rendered_review",
              "native_review", "receipt_sha256_by_locale", HEADERS_FIELD}
    require(isinstance(batch, dict) and set(batch) == fields, "correction batch field population")
    expected = {"order": "ORDER-380", "group": "ui_correction", "roots": [CORRECTION_KEY], "source_leaves": 1,
                "target_leaves_by_locale": {"ja": 0, "zh-CN": 1, "zh-TW": 1}, "original_order": "ORDER-379",
                "source_review": CORRECTION_REVIEW, "machine_validation": "PASS", "rendered_review": "OPEN",
                "native_review": "OPEN"}
    require(all(_ordered(batch[key]) == _ordered(value) for key, value in expected.items()),
            "correction batch identity/count/review differs")
    require(all(set(batch[key]) == set(LOCALES) for key in
                (HEADERS_FIELD, "receipt_sha256_by_locale", "before_target_sha256_by_locale")),
            "correction official receipt locales differ")
    originals = [row for row in a["batches"] if row.get("order") == "ORDER-379"
                 and row.get("group") == "ui" and CORRECTION_KEY in row.get("roots", [])]
    require(len(originals) == 1, "correction does not identify exactly one original accepted unit")
    manifests = {}
    for locale, path in zip(LOCALES, UI_PATHS):
        old_text, new_text = CORRECTION_TEXTS[locale]
        require(old[path][CORRECTION_KEY] == old_text and new[path][CORRECTION_KEY] == new_text,
                "correction exact old/new text differs: " + locale)
        require(not exchange.translation_errors(expected_leaf, locale, new_text), "correction translation contract: " + locale)
        previous = {"source_sha256": expected_leaf.source_sha256, "target_sha256": exchange.digest(old_text)}
        corrected = {"source_sha256": expected_leaf.source_sha256, "target_sha256": exchange.digest(new_text)}
        require(_ordered(a["accepted"][locale][expected_leaf.id]) == _ordered(previous)
                and _ordered(b["accepted"][locale][expected_leaf.id]) == _ordered(corrected)
                and batch["before_target_sha256_by_locale"][locale] == previous["target_sha256"],
                "correction source/old/new target receipt mismatch: " + locale)
        header = batch[HEADERS_FIELD][locale]
        require(header.get("source_revision") == CORRECTION_BEFORE_COMMIT
                and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))),
                "correction export revision/manifest malformed")
        # Actual historical Git and current source are independently checked by
        # validate_history, using the same source-change boundary as appends.
        receipt_inventory = {**inventory, "source_manifest_sha256": header["source_manifest_sha256"]}
        rebuilt = exchange.make_batch(receipt_inventory, locale, selected, CORRECTION_BEFORE_COMMIT, {path: old[path]}, {})[0]
        require(_ordered(header) == _ordered(rebuilt), "correction official previous-target selection mismatch: " + locale)
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {expected_leaf.id: corrected}}
        require(batch["receipt_sha256_by_locale"][locale] == exchange.digest(receipt),
                "correction official receipt digest mismatch: " + locale)
        manifests[header["source_revision"]] = header["source_manifest_sha256"]
    require(_correction_comparison(after, before, after) == before,
            "correction changed bytes outside two targets/receipts/checksum/one batch")
    return {"ui_by_locale": {loc: 0 for loc in CURRENT_LOCALES}, "receipts": 0, "batches": 0,
            "corrections": 2, "correction_batches": 1, "source_manifests": manifests}


def _correction_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict]:
    """Fresh Git proof of the single approved correction; no cached admission."""
    require(set(CORRECTION_BLOBS) == set(CORRECTION_HASHES) == set(PATHS), "correction pin population")
    revisions = (CORRECTION_BEFORE_COMMIT, CORRECTION_AFTER_COMMIT)
    requests = [(revision, revision, "commit") for revision in revisions]
    requests += [(tree, tree, "tree") for tree in CORRECTION_TREES]
    requests += [(revision + ":" + path, CORRECTION_BLOBS[path][i], "blob")
                 for path in PATHS for i, revision in enumerate(revisions)]
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([line for line in headers if line.startswith(b"tree ")] == [b"tree " + CORRECTION_TREES[index].encode()],
                "correction exact tree mismatch")
        if index:
            require([line for line in headers if line.startswith(b"parent ")] == [b"parent " + revisions[0].encode()],
                    "correction is not the exact direct-parent transition")
    require(_git(root, "diff", "--name-status", "-z", *revisions).split(b"\0")
            == [part for path in sorted(PATHS) for part in (b"M", path.encode())] + [b""],
            "correction product transition is not exactly three modified paths")
    before, after = {}, {}
    for index, path in enumerate(PATHS):
        old, new = values[4 + index * 2:6 + index * 2]
        require((hashlib.sha256(old).hexdigest(), hashlib.sha256(new).hexdigest()) == CORRECTION_HASHES[path],
                "correction immutable whole-file hashes differ: " + path)
        before[path], after[path] = old, new
    return before, after, _validate_correction(before, after, inventory)


def validate_history(root: Path, baseline_commit: str, baseline: Mapping[str, bytes],
                     current: Mapping[str, bytes], inventory: dict[str, Any]) -> dict[str, Any]:
    """Fresh first-parent history: a committed rollback stays rejected even after restoration."""
    require(set(baseline) == set(current) and set(baseline) in (set(PATHS), set(CURRENT_PATHS)),
            "Git history snapshot population differs")
    paths = CURRENT_PATHS if set(baseline) == set(CURRENT_PATHS) else PATHS
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", head) is not None, "invalid current Git candidate")
    lineage = _git(root, "rev-list", "--first-parent", head).decode().splitlines()
    require(baseline_commit in lineage, "baseline is not on the current first-parent lineage")
    require(_snapshot(root, baseline_commit, paths) == baseline, "Git baseline differs from immutable caller proof")
    candidate = _snapshot(root, head, paths)
    require(candidate == current, "submitted/current raw differs from actual Git candidate")
    commits = _git(root, "log", "--first-parent", "--full-history", "--reverse", "--format=%H",
                   baseline_commit + ".." + head, "--", *paths).decode().splitlines()
    expected_order = list(reversed(lineage[:lineage.index(baseline_commit)]))
    require(len(set(commits)) == len(commits) and commits == [c for c in expected_order if c in commits],
            "Git transition history order/population malformed")
    previous = dict(baseline)
    totals = Counter()
    transitions = []
    source_manifests = {}
    correction = None
    corrected = False
    for commit in commits:
        raw = _objects(root, [(commit, commit, "commit")])[0]
        parents = [line[7:].decode() for line in raw.split(b"\n\n", 1)[0].splitlines() if line.startswith(b"parent ")]
        require(bool(parents) and parents[0] in lineage, "Git transition parent missing from current lineage")
        require(_snapshot(root, parents[0], paths) == previous, "omitted/noncontiguous UI receipt transition")
        successor = _snapshot(root, commit, paths)
        if commit == CORRECTION_AFTER_COMMIT:
            require(correction is None, "duplicate exact correction transition")
            correction = _correction_proof(root, inventory)
            old, new, change = correction
            require({p: previous[p] for p in PATHS} == old and {p: successor[p] for p in PATHS} == new,
                    "correction lineage snapshots differ from pinned blobs")
            require(all(previous[p] == successor[p] for p in paths if p not in PATHS),
                    "correction changed the protected Japanese snapshot")
            corrected = True
        elif corrected:
            old, new, _ = correction
            change = validate_append(_correction_comparison(previous, old, new),
                                     _correction_comparison(successor, old, new), inventory)
        else:
            change = validate_append(previous, successor, inventory)
        for revision, expected in change["source_manifests"].items():
            _git(root, "merge-base", "--is-ancestor", revision, parents[0])
            require(_source_manifest_matches(root, inventory, expected),
                    "KO/runtime source changed; use a separate source-change review, not UI append")
            if revision not in source_manifests:
                source_manifests[revision] = _source_manifest(root, revision)
            require(source_manifests[revision] == expected, "receipt source manifest differs from actual Git census")
        transitions.append({"commit": commit, **change})
        totals.update({key: change.get(key, 0) for key in ("receipts", "batches", "corrections", "correction_batches")})
        previous = successor
    require(previous == candidate, "Git history does not reconstruct current UI receipts")
    # Independently prove the full byte inverse, not just each incremental hop.
    comparison = _correction_comparison(candidate, *correction[:2]) if correction else candidate
    combined = validate_append(baseline, comparison, inventory)
    require(combined["receipts"] == totals["receipts"] and combined["batches"] == totals["batches"],
            "history/current append census mismatch")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
            "Git candidate changed during validation")
    return {"head": head, "transitions": transitions, **combined, "append_batches": combined["batches"],
            "batches": combined["batches"] + totals["correction_batches"],
            "corrections": totals["corrections"], "correction_batches": totals["correction_batches"]}


def current_proof(root: Path, baseline_commit: str, baseline: Mapping[str, bytes]) -> dict[str, Any]:
    """Production entry: collect once per caller context; never accept a supplied inventory."""
    if set(baseline) == set(PATHS):
        # Preserve the old caller signature, but never leave JA unobserved.
        baseline = {**baseline, **_snapshot(root, baseline_commit, ("locale/ui_ja.json",))}
    require(set(baseline) == set(CURRENT_PATHS), "production requires all three UI dictionaries and ledger")
    current = {path: (root / path).read_bytes() for path in CURRENT_PATHS}
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    aruba_font_predecessor(root, font_raw)
    inventory = exchange.collect(root)
    require(inventory["source_hashes"].get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "collected Aruba source not bound to admitted actual font bytes")
    errors = [row for row in inventory["unsupported"]
              if row["kind"] in {"static_ui_contract", "demo_dynamic_contract"}]
    require(not errors, "current source collector contract failed: " + str(errors))
    evidence = validate_history(root, baseline_commit, baseline, current, inventory)
    require(all((root / path).read_bytes() == raw for path, raw in current.items()),
            "current UI/receipt bytes changed during validation")
    require((root / ARUBA_FONT_PATH).read_bytes() == font_raw, "Aruba runtime changed during validation")
    return {"raw": current, "evidence": evidence,
            "source_hashes": inventory["source_hashes"], "source_manifest_sha256": inventory["source_manifest_sha256"]}


# MainGame rendering-only successor. Earlier manifest/header proofs stay exact.
_MODAL_OLD_MANIFEST_MATCHES = _source_manifest_matches
_MODAL_OLD_CURRENT_PROOF = current_proof


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    # The unchanged isolated append/correction fixtures supply only a manifest,
    # not a current-source census. Keep their original exact-equality meaning;
    # production current_proof always supplies and verifies source_hashes.
    if "source_hashes" not in inventory:
        return _MODAL_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    previous = history.modal_font_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "MainGame current source census/raw mismatch")
    if expected == inventory["source_manifest_sha256"]:
        return True
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(previous).hexdigest()}
    return _MODAL_OLD_MANIFEST_MATCHES(root, {**inventory, "source_hashes": comparison,
                                           "source_manifest_sha256": exchange.digest(comparison)}, expected)


def current_proof(root: Path, baseline_commit: str, baseline: Mapping[str, bytes]) -> dict[str, Any]:
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    history.modal_font_predecessor(raw, root)
    result = _MODAL_OLD_CURRENT_PROOF(root, baseline_commit, baseline)
    require(result["source_hashes"].get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest()
            and (root / history.MAIN_GAME_PATH).read_bytes() == raw,
            "MainGame source changed during current admission")
    return result


# Exact ORDER-384 fee correction. All earlier functions/pins remain unchanged.
FEE_KEY = "매수 기본 수수료는 0.3%입니다. 컨디션이 나쁠수록 매수 비용이 높아질 수 있고, 매도 수수료는 0.5%입니다."
FEE_BEFORE_COMMIT = "d91395c77ffefedf9ebc97429093c8693e91cf6f"
FEE_AFTER_COMMIT = "5a553f0b33e293d8eac64d34827b051edf5ef8a7"
FEE_TREES = ("798f33706a4775b10bc0bbf1d9cb57fbe54bbe0c", "601cfd2215bf8b1e76b5f085c973954da2d7e230")
FEE_BLOBS = {
    "locale/ui_zh-CN.json": ("7844844d919f670585d049fa9d456162da99950e", "576efe1ff9bc85c2943f88387fd6a35a9c28c1e3"),
    "locale/ui_zh-TW.json": ("74c14f8e1a5f1aecb29ef33aab7d230e98424fe4", "2279e0f7e2aa36453f0262404fca07fcc6fb4163"),
    "content/meta/full_game_localization.json": ("0f5c7e277b1d6247f89ba9b34f6e9c839f1dfffa", "8e7ff209bf61bf8d9789767f33841f045d8b4549"),
}
FEE_HASHES = {
    "locale/ui_zh-CN.json": ("114f471c380087b035de8657b071f59cb455a4a56aa222c1e955ba8ea4f7405f", "b421c013dbe82a9bd23d3e71844ae7ef0e2e2fa6044b5e1895acfa24a03b24ec"),
    "locale/ui_zh-TW.json": ("503e43c24e711fd0873d7b58532e50dfece8734b2efce9ef5dbb384636be4f88", "1ec60adc643a4046daf89f09b2f1a91f87b8e73cd7525d35fede827fc5c0b34e"),
    "content/meta/full_game_localization.json": ("0594a077f52065d39e8b1d6203d3c0c56947957ee7c785c62510037ce8f74836", "f9cd86d8aab5fd591940d9065123e61f0af999f6318150625966078b81f96b91"),
}
FEE_TEXTS = {
    "zh-CN": ("买入的基础手续费为0.3%。状态越差，买入成本可能越高，卖出手续费为0.5%。",
              "买入基础费率0.3%；状态越差，成本可能越高。卖出费率0.5%。"),
    "zh-TW": ("買入的基本手續費為 0.3%。狀態越差，買入成本可能越高；賣出手續費為 0.5%。",
              "買入基本費率0.3%；狀態越差，成本可能越高。賣出費率0.5%。"),
}
FEE_REVIEW = ("Korean-direct concise fee guidance after actual CN499/TW505px over468px clipping. "
              "Preserve buy base0.3%, condition-dependent higher buy cost and sell0.5%; no gameplay change. "
              "Correction is not new coverage.")


def _fee_comparison(snapshot: Mapping[str, bytes], before: Mapping[str, bytes],
                    after: Mapping[str, bytes]) -> dict[str, bytes]:
    """Comparison only: undo the fixed two fee targets and batch152, not appends."""
    require(set(snapshot) in (set(PATHS), set(CURRENT_PATHS))
            and set(before) == set(after) == set(PATHS), "fee correction snapshot population")
    result = dict(snapshot)
    receipt = receipt_id(FEE_KEY)
    for locale, path in zip(LOCALES, UI_PATHS):
        a, b = _Document(before[path]), _Document(after[path])
        doc = b if snapshot[path] == after[path] else _Document(snapshot[path])
        require(doc.value.get(FEE_KEY) == FEE_TEXTS[locale][1], "corrected fee rolled back/changed: " + locale)
        start, end = doc.spans[(FEE_KEY,)]
        bs, be = b.spans[(FEE_KEY,)]
        require(doc.text[start:end] == b.text[bs:be], "corrected fee raw token changed")
        first, last = a.spans[(FEE_KEY,)]
        result[path] = (doc.text[:start] + a.text[first:last] + doc.text[end:]).encode()
    a, b = _Document(before[LEDGER_PATH]), _Document(after[LEDGER_PATH])
    doc = b if snapshot[LEDGER_PATH] == after[LEDGER_PATH] else _Document(snapshot[LEDGER_PATH])
    value = doc.value
    require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "corrected fee accepted checksum")
    require(len(value["batches"]) >= 152 and _ordered(value["batches"][151]) == _ordered(b.value["batches"][151]),
            "fee correction batch missing/changed/reordered")
    start, end = doc.spans[("batches", 150)][1], doc.spans[("batches", 151)][1]
    bs, be = b.spans[("batches", 150)][1], b.spans[("batches", 151)][1]
    require(doc.text[start:end] == b.text[bs:be], "fee correction batch raw changed")
    edits = [(start, end, "")]
    accepted = dict(value["accepted"])
    for locale in LOCALES:
        require(_ordered(value["accepted"][locale][receipt]) == _ordered(b.value["accepted"][locale][receipt]),
                "corrected fee receipt changed: " + locale)
        field = ("accepted", locale, receipt, "target_sha256")
        start, end = doc.spans[field]
        bs, be = b.spans[field]
        require(doc.text[start:end] == b.text[bs:be], "corrected fee receipt raw token changed")
        first, last = a.spans[field]
        edits.append((start, end, a.text[first:last]))
        accepted[locale] = {**value["accepted"][locale], receipt: a.value["accepted"][locale][receipt]}
    start, end = doc.spans[("accepted_sha256",)]
    edits.append((start, end, _ordered(exchange.digest(accepted)).decode()))
    text = doc.text
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start] + replacement + text[end:]
    result[LEDGER_PATH] = text.encode()
    return result


def _validate_fee_correction(before: Mapping[str, bytes], after: Mapping[str, bytes],
                             inventory: dict[str, Any]) -> dict[str, Any]:
    require(set(before) == set(after) == set(PATHS), "fee correction requires exact three paths")
    old = {p: _loads(v) for p, v in before.items()}
    new = {p: _loads(v) for p, v in after.items()}
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(len(a["batches"]) == 151 and len(b["batches"]) == 152
            and sum(map(len, a["accepted"].values())) == sum(map(len, b["accepted"].values())) == 40886,
            "fee correction must not increase coverage")
    require(a["accepted_sha256"] == exchange.digest(a["accepted"])
            and b["accepted_sha256"] == exchange.digest(b["accepted"]), "fee accepted checksum mismatch")
    leaf = exchange.Leaf("ui", FEE_KEY, "runtime:static_ui", (FEE_KEY,), FEE_KEY, "ui_static_context")
    selected = [row for row in inventory["leaves"] if row.id == leaf.id]
    require(len(selected) == 1 and _ordered(vars(selected[0])) == _ordered(vars(leaf)),
            "fee current Korean leaf/protection/support mismatch")
    batch = b["batches"][151]
    expected = {"order": "ORDER-384", "group": "ui_correction", "roots": [FEE_KEY], "source_leaves": 1,
                "target_leaves_by_locale": {"ja": 0, "zh-CN": 1, "zh-TW": 1}, "original_order": "ORDER-383",
                "source_review": FEE_REVIEW, "machine_validation": "PASS", "rendered_review": "OPEN", "native_review": "OPEN"}
    maps = (HEADERS_FIELD, "receipt_sha256_by_locale", "before_target_sha256_by_locale")
    require(isinstance(batch, dict) and set(batch) == set(expected) | set(maps)
            and all(_ordered(batch[k]) == _ordered(v) for k, v in expected.items())
            and all(isinstance(batch[k], dict) and set(batch[k]) == set(LOCALES) for k in maps),
            "fee correction batch identity/population/count differs")
    accepted = dict(a["accepted"])
    manifests = {}
    for locale, path in zip(LOCALES, UI_PATHS):
        old_text, new_text = FEE_TEXTS[locale]
        require(old[path].get(FEE_KEY) == old_text
                and _ordered(new[path]) == _ordered({**old[path], FEE_KEY: new_text}), "fee UI differs beyond exact target")
        require(not exchange.translation_errors(leaf, locale, new_text), "fee translation contract: " + locale)
        previous = {"source_sha256": leaf.source_sha256, "target_sha256": exchange.digest(old_text)}
        corrected = {"source_sha256": leaf.source_sha256, "target_sha256": exchange.digest(new_text)}
        require(_ordered(a["accepted"][locale][leaf.id]) == _ordered(previous)
                and batch["before_target_sha256_by_locale"][locale] == previous["target_sha256"],
                "fee previous source/target receipt mismatch")
        originals = [row for row in a["batches"] if row.get("order") == "ORDER-383" and row.get("group") == "ui"
                     and FEE_KEY in row.get("roots", []) and row.get("target_leaves_by_locale", {}).get(locale) == 27]
        require(len(originals) == 1 and set(originals[0].get(HEADERS_FIELD, {})) == {locale}
                and set(originals[0].get("receipt_sha256_by_locale", {})) == {locale}
                and _ordered(originals[0]["target_leaves_by_locale"]) == _ordered(
                    {loc: 27 if loc == locale else 0 for loc in CURRENT_LOCALES})
                and type(originals[0].get("source_leaves")) is int and originals[0]["source_leaves"] == 27
                and len(originals[0]["roots"]) == len(set(originals[0]["roots"])) == 27
                and originals[0][HEADERS_FIELD][locale].get("locale") == locale,
                "fee correction lacks exactly one original locale batch")
        header = batch[HEADERS_FIELD][locale]
        require(header.get("source_revision") == FEE_BEFORE_COMMIT
                and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))),
                "fee export revision/manifest malformed")
        rebuilt = exchange.make_batch({**inventory, "source_manifest_sha256": header["source_manifest_sha256"]},
                                      locale, selected, FEE_BEFORE_COMMIT, {path: old[path]}, {})[0]
        require(_ordered(header) == _ordered(rebuilt), "fee official previous-target selection mismatch")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {leaf.id: corrected}}
        require(batch["receipt_sha256_by_locale"][locale] == exchange.digest(receipt), "fee official receipt digest mismatch")
        require(header["source_revision"] not in manifests or manifests[header["source_revision"]] == header["source_manifest_sha256"],
                "fee locale source manifests disagree")
        manifests[header["source_revision"]] = header["source_manifest_sha256"]
        accepted[locale] = {**a["accepted"][locale], leaf.id: corrected}
    expected_ledger = {**a, "accepted": accepted, "accepted_sha256": exchange.digest(accepted),
                       "batches": [*a["batches"], batch]}
    require(_ordered(b) == _ordered(expected_ledger), "fee changed an old batch, neighbor or ledger field")
    require(_fee_comparison(after, before, after) == before, "fee full raw inverse differs outside exact correction")
    return {"ui_by_locale": {loc: 0 for loc in CURRENT_LOCALES}, "receipts": 0, "batches": 0,
            "corrections": 2, "correction_batches": 1, "source_manifests": manifests}


def _fee_correction_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict]:
    require(set(FEE_BLOBS) == set(FEE_HASHES) == set(PATHS), "fee correction pin population")
    revisions = (FEE_BEFORE_COMMIT, FEE_AFTER_COMMIT)
    requests = [(c, c, "commit") for c in revisions] + [(t, t, "tree") for t in FEE_TREES]
    requests += [(c + ":" + p, FEE_BLOBS[p][i], "blob") for p in PATHS for i, c in enumerate(revisions)]
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([h for h in headers if h.startswith(b"tree ")] == [b"tree " + FEE_TREES[index].encode()], "fee exact tree mismatch")
        if index:
            require([h for h in headers if h.startswith(b"parent ")] == [b"parent " + revisions[0].encode()], "fee direct parent mismatch")
    require(_git(root, "diff", "--name-status", "-z", *revisions).split(b"\0")
            == [v for p in sorted(PATHS) for v in (b"M", p.encode())] + [b""], "fee product path population differs")
    before, after = {}, {}
    for index, path in enumerate(PATHS):
        old, new = values[4 + index * 2:6 + index * 2]
        require(tuple(hashlib.sha256(v).hexdigest() for v in (old, new)) == FEE_HASHES[path], "fee immutable whole raw differs")
        before[path], after[path] = old, new
    return before, after, _validate_fee_correction(before, after, inventory)


_FEE_OLD_VALIDATE_HISTORY = validate_history


def validate_history(root: Path, baseline_commit: str, baseline: Mapping[str, bytes],
                     current: Mapping[str, bytes], inventory: dict[str, Any]) -> dict[str, Any]:
    """Current append history with only the two separately pinned corrections."""
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", head) is not None, "invalid current Git candidate")
    lineage = _git(root, "rev-list", "--first-parent", head).decode().splitlines()
    if FEE_AFTER_COMMIT not in lineage:
        return _FEE_OLD_VALIDATE_HISTORY(root, baseline_commit, baseline, current, inventory)
    require(set(baseline) == set(current) and set(baseline) in (set(PATHS), set(CURRENT_PATHS)), "fee history snapshot population")
    require(baseline_commit in lineage and lineage.index(baseline_commit) > lineage.index(FEE_AFTER_COMMIT),
            "fee correction must be after the immutable caller baseline")
    paths = CURRENT_PATHS if set(baseline) == set(CURRENT_PATHS) else PATHS
    require(_snapshot(root, baseline_commit, paths) == baseline, "Git baseline differs from caller proof")
    candidate = _snapshot(root, head, paths)
    require(candidate == current, "submitted/current raw differs from actual Git candidate")
    commits = _git(root, "log", "--first-parent", "--full-history", "--reverse", "--format=%H",
                   baseline_commit + ".." + head, "--", *paths).decode().splitlines()
    order = list(reversed(lineage[:lineage.index(baseline_commit)]))
    require(len(set(commits)) == len(commits) and commits == [c for c in order if c in commits], "fee history order/population")
    exact = {CORRECTION_AFTER_COMMIT: (_correction_proof, _correction_comparison),
             FEE_AFTER_COMMIT: (_fee_correction_proof, _fee_comparison)}
    corrections, transitions, manifests, totals = [], [], {}, Counter()
    def comparison(snapshot):
        for function, before, after in reversed(corrections):
            snapshot = function(snapshot, before, after)
        return snapshot
    previous = dict(baseline)
    for commit in commits:
        raw = _objects(root, [(commit, commit, "commit")])[0]
        parents = [h[7:].decode() for h in raw.split(b"\n\n", 1)[0].splitlines() if h.startswith(b"parent ")]
        require(bool(parents) and parents[0] in lineage and _snapshot(root, parents[0], paths) == previous,
                "omitted/noncontiguous fee receipt transition")
        successor = _snapshot(root, commit, paths)
        if commit in exact:
            proof, inverse = exact[commit]
            before, after, change = proof(root, inventory)
            require({p: previous[p] for p in PATHS} == before and {p: successor[p] for p in PATHS} == after
                    and all(previous[p] == successor[p] for p in paths if p not in PATHS), "fee lineage or protected JA differs")
            corrections.append((inverse, before, after))
        else:
            change = validate_append(comparison(previous), comparison(successor), inventory)
        for revision, expected in change["source_manifests"].items():
            _git(root, "merge-base", "--is-ancestor", revision, parents[0])
            require(_source_manifest_matches(root, inventory, expected), "KO/runtime source changed outside reviewed boundary")
            if revision not in manifests:
                manifests[revision] = _source_manifest(root, revision)
            require(manifests[revision] == expected, "receipt source manifest differs from actual Git census")
        transitions.append({"commit": commit, **change})
        totals.update({k: change.get(k, 0) for k in ("receipts", "batches", "corrections", "correction_batches")})
        previous = successor
    require(previous == candidate and FEE_AFTER_COMMIT in commits, "fee history does not reconstruct current candidate")
    combined = validate_append(baseline, comparison(candidate), inventory)
    require(combined["receipts"] == totals["receipts"] and combined["batches"] == totals["batches"], "fee history/current census mismatch")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head, "Git candidate changed during validation")
    return {"head": head, "transitions": transitions, **combined, "append_batches": combined["batches"],
            "batches": combined["batches"] + totals["correction_batches"],
            "corrections": totals["corrections"], "correction_batches": totals["correction_batches"]}


# Exact386 adds a comparison for official headers exported after382/before386.
# Keep actual source census and all earlier Git/header/correction checks intact.
_INVESTMENT_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _INVESTMENT_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    previous = history.investment_footer_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "investment current source census/raw mismatch")
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return True
    # Delegate the untouched actual census, never pretend comparison bytes were
    # observed. The older bridge separately proves pre381/preAruba manifests.
    return _INVESTMENT_OLD_MANIFEST_MATCHES(root, inventory, expected)
