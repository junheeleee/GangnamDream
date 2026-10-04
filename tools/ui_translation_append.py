#!/usr/bin/env python3
"""Validate portable, append-only prepared-language UI receipts above a base.

The caller owns and verifies the historical base. This module admits actual
current bytes; its inverse is an internal preservation proof, never a UI view.
No private receipts, cached validation verdicts, or historical consumer are used.
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
    old = {path: _loads(before[path]) for path in before}
    new = {path: _loads(after[path]) for path in after}
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
    """Current append history with two pinned corrections and one split delivery."""
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
    split_receipts = _SplitReceiptHistory(root, inventory)
    comparison = _comparison_memo(paths, corrections)
    previous = dict(baseline)
    for commit in commits:
        raw = _objects(root, [(commit, commit, "commit")])[0]
        parents = [h[7:].decode() for h in raw.split(b"\n\n", 1)[0].splitlines() if h.startswith(b"parent ")]
        require(bool(parents) and parents[0] in lineage and _snapshot(root, parents[0], paths) == previous,
                "omitted/noncontiguous fee receipt transition")
        successor = _snapshot(root, commit, paths)
        change = split_receipts.step(commit, previous, successor)
        if change is not None:
            pass
        elif commit == LEGACY_GIFT_AFTER_COMMIT:
            before, after, change = _legacy_ja_gift_proof(root, inventory)
            require(set(paths) == set(CURRENT_PATHS) and previous == before and successor == after,
                    "legacy JA gift lineage or protected locale differs")
            corrections.append((_legacy_ja_gift_comparison, before, after))
        elif commit in exact:
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
        totals.update({k: change.get(k, 0) for k in ("receipts", "batches", "corrections", "correction_batches", "first_receipts")})
        previous = successor
    split_receipts.finish()
    require(previous == candidate and FEE_AFTER_COMMIT in commits, "fee history does not reconstruct current candidate")
    combined = validate_append(baseline, comparison(candidate), inventory)
    require(combined["receipts"] == totals["receipts"] and combined["batches"] == totals["batches"], "fee history/current census mismatch")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head, "Git candidate changed during validation")
    return {"head": head, "transitions": transitions, **combined, "append_batches": combined["batches"],
            "batches": combined["batches"] + totals["correction_batches"],
            "corrections": totals["corrections"], "correction_batches": totals["correction_batches"],
            "append_receipts": combined["receipts"], "first_receipts": totals["first_receipts"],
            "receipts": combined["receipts"] + totals["first_receipts"]}


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


# Exact390 changes one source pair. Actual leaves/census remain current; this
# bridge admits the pre390 official header census only after fresh raw proof.
_TUTORIAL_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _TUTORIAL_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    previous = history.tutorial_copy_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "tutorial current source census/raw mismatch")
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return True
    return _TUTORIAL_OLD_MANIFEST_MATCHES(root, inventory, expected)


# A single reviewed split delivery: PR30 supplied the UI, but its official
# receipts arrived later. This is not permission for ordinary unreceipted UI.
# Historical snapshots remain actual Git bytes, including the incomplete hop.
SPLIT_SOURCE_COMMIT = "18dd16d6020b2dcae8484f4b70af3261a6ccd91e"
SPLIT_PR_COMMIT = "0f5852d0dfdf775628304f490e166cb10df6087e"
SPLIT_BEFORE_COMMIT = "ad0468703ea2dcc8c9c8b02877a32e5001771d1c"
SPLIT_INGRESS_COMMIT = "e89f3ede95ff7ee7d0501d8d98bb2b7774f81b01"
SPLIT_REMOTE_COMMIT = "9db4a6e55e84b38453c901a928ca03d88cd46b1b"
SPLIT_REBASED_COMMIT = "2efa189f16c75727e32631f62c2436e57370899d"
# Filled only from the separately committed, ledger-only recovery product.
SPLIT_REPAIR_BEFORE_COMMIT = "ee9e1b4bdcc47611b7eff2febd8d1cafb832b47f"
SPLIT_REPAIR_COMMIT = "f5c966ac1a6cf107f6ff9d70c570baaa1671b75d"
SPLIT_REPAIR_TREE = "a8cb8527202bb7fc5db9e19dc372b08626d880f0"
SPLIT_SOURCE_MANIFEST = "b017b1460f3e6a6f7656336a3230036b5ca4f2ca7c80cbea332e39ec8d8b6ed7"
SPLIT_KEYS = (
    "[b]패드[/b]  LB/RB 페이지 · %s 뒤로  —  %s",
    "[b]패드[/b]  LB/RB 페이지 · ↑↓ 자산 · ←→ 행동 · %s %s · %s 뒤로  —  %s",
    "[b]패드[/b]  LB/RB 페이지 · 거래 가능한 자산 없음",
    "거래 불가",
)
SPLIT_TEXTS = {
    "zh-CN": ("[b]手柄[/b]  LB/RB 翻页 · %s 返回  —  %s",
              "[b]手柄[/b]  LB/RB 翻页 · ↑↓ 资产 · ←→ 操作 · %s %s · %s 返回  —  %s",
              "[b]手柄[/b]  LB/RB 翻页 · 无可交易资产", "无法交易"),
    "zh-TW": ("[b]手把[/b]  LB/RB 換頁 · %s 返回  —  %s",
              "[b]手把[/b]  LB/RB 換頁 · ↑↓ 資產 · ←→ 操作 · %s %s · %s 返回  —  %s",
              "[b]手把[/b]  LB/RB 換頁 · 無可交易資產", "無法交易"),
}
# Each tuple is (before ingress, pending UI, completed receipt) blob identity.
SPLIT_BLOBS = {
    "locale/ui_ja.json": ("dc942362324588cfa7e87743f6326fb0f733e2f9",) * 3,
    "locale/ui_zh-CN.json": ("94b3b95065bc472cd363151ec2284878665cef9e",
                            "d23531948e68dc577b9ec41ac5393f7e9143b363",
                            "d23531948e68dc577b9ec41ac5393f7e9143b363"),
    "locale/ui_zh-TW.json": ("6b29ec2886557498c1668e358367c1840be0c1b4",
                            "ef8ffd284f6db52e26008da1aba04c173ae0706b",
                            "ef8ffd284f6db52e26008da1aba04c173ae0706b"),
    LEDGER_PATH: ("215ec9b09c904b4a31007a27e71224f0dea35183",
                  "215ec9b09c904b4a31007a27e71224f0dea35183",
                  "d51070e1153fe13e4ad33ef728a00e37bb7b5523"),
}
SPLIT_HASHES = {
    "locale/ui_ja.json": ("a79f7121f4182e734f8607280a4579ff72462d66d11d1740d9f055ba66cbc201",) * 3,
    "locale/ui_zh-CN.json": ("b53aac7673f7f99e4ad7f47f39a97c414af66e1e7083ac485ee577d8e39d7df9",
                            "7c59c959fd51f81229266e66908693f4d9a9b701a653ef16e2f715dd91e7d634",
                            "7c59c959fd51f81229266e66908693f4d9a9b701a653ef16e2f715dd91e7d634"),
    "locale/ui_zh-TW.json": ("8477a0be540c097afd3d2bb83f4dc4cd5ef8f3ad21adfe29c98cc3e84d45cddd",
                            "2f87e6af17c99f064da29990410136acb93da73cd16a306d4b1a8716898d286f",
                            "2f87e6af17c99f064da29990410136acb93da73cd16a306d4b1a8716898d286f"),
    LEDGER_PATH: ("4ea329b45a0a85a9ad9af81a13e1497d628d34608a5099114dcc97f5538ed730",
                  "4ea329b45a0a85a9ad9af81a13e1497d628d34608a5099114dcc97f5538ed730",
                  "2bbf79be726b098ea325cf47b864f3e772aadda71770887d2abd9e8519dbd110"),
}


def _validate_split_receipt(before: Mapping[str, bytes], pending: Mapping[str, bytes],
                            complete: Mapping[str, bytes], inventory: dict[str, Any]) -> dict[str, Any]:
    """Pure exact eight-value repair; ordinary append owns all receipt checks."""
    require(set(before) == set(pending) == set(complete) == set(CURRENT_PATHS),
            "split receipt requires all four observed paths")
    require(pending[LEDGER_PATH] == before[LEDGER_PATH]
            and all(pending[p] == complete[p] for p in CURRENT_UI_PATHS)
            and before[CURRENT_UI_PATHS[0]] == pending[CURRENT_UI_PATHS[0]],
            "split delivery changed an existing receipt, UI or Japanese bytes")
    for locale, path in zip(LOCALES, UI_PATHS):
        old, new = _loads(before[path]), _loads(pending[path])
        require(list(new)[len(old):] == list(SPLIT_KEYS)
                and tuple(new.get(key) for key in SPLIT_KEYS) == SPLIT_TEXTS[locale],
                "split delivery is not the exact four preserved targets: " + locale)
    old, new = _loads(before[LEDGER_PATH]), _loads(complete[LEDGER_PATH])
    require(len(old["batches"]) == 161 and len(new["batches"]) == 163
            and sum(map(len, old["accepted"].values())) == 40981
            and sum(map(len, new["accepted"].values())) == 40989,
            "split receipt coverage/batch population differs")
    for locale, batch in zip(LOCALES, new["batches"][161:]):
        require(batch.get("order") == "ORDER-391" and batch.get("roots") == list(SPLIT_KEYS)
                and batch.get("rendered_review") == "OPEN"
                and batch.get("target_leaves_by_locale") == {loc: 4 if loc == locale else 0 for loc in CURRENT_LOCALES},
                "split receipt original batch identity/order/review differs")
        header = batch.get(HEADERS_FIELD, {}).get(locale, {})
        require(header.get("source_revision") == SPLIT_SOURCE_COMMIT
                and header.get("source_manifest_sha256") == SPLIT_SOURCE_MANIFEST,
                "split receipt original export revision/manifest differs")
    change = validate_append(before, complete, inventory)
    require(change["ui_by_locale"] == {"ja": 0, "zh-CN": 4, "zh-TW": 4}
            and change["receipts"] == 8 and change["batches"] == 2,
            "split receipt combined append census differs")
    return change


def _split_receipt_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict, dict]:
    """Fresh fixed provenance plus raw inverse; never manufacture old receipts."""
    require(set(SPLIT_BLOBS) == set(SPLIT_HASHES) == set(CURRENT_PATHS), "split receipt pin population")
    commits = {
        SPLIT_SOURCE_COMMIT: ("3d6b582384591fc6504d95ea54c51e6d9fefe97a", ("86d7c12c103f21c494bd34ce025f09dc47264a82",)),
        "bdbd10f43c690d882b41596f531878ebe0bb4901": ("ab7becfd7bae5ea4f5b96b927eee49e510c0e980", (SPLIT_SOURCE_COMMIT,)),
        SPLIT_PR_COMMIT: ("ab7becfd7bae5ea4f5b96b927eee49e510c0e980", (SPLIT_SOURCE_COMMIT, "bdbd10f43c690d882b41596f531878ebe0bb4901")),
        SPLIT_BEFORE_COMMIT: ("54d46263d44f281847c86b0a73a92dbe6bac2ce4", ("d74a65233a7a8dae490e25cadefefe565fa440eb",)),
        SPLIT_INGRESS_COMMIT: ("f3c0250ba567382b833b8e1f5be5f55fc458789e", (SPLIT_BEFORE_COMMIT, SPLIT_PR_COMMIT)),
        "b0efea56e8d45a5d43bab0717ab15c469b7b53ec": ("e555ed7e39cdb6e3bc0b4df28beec65f40aef075", (SPLIT_PR_COMMIT,)),
        SPLIT_REMOTE_COMMIT: ("414f31432e107874c2305c23a195b002837237f7", ("b0efea56e8d45a5d43bab0717ab15c469b7b53ec",)),
        SPLIT_REBASED_COMMIT: ("fe3866c24ee20050557e44bf3364f0e5bc33e4c2", (SPLIT_PR_COMMIT,)),
        SPLIT_REPAIR_COMMIT: (SPLIT_REPAIR_TREE, (SPLIT_REPAIR_BEFORE_COMMIT,)),
    }
    require(all(re.fullmatch(r"[0-9a-f]{40}", value)
                for commit, (tree, parents) in commits.items() for value in (commit, tree, *parents)),
            "split receipt immutable commit/tree/parent pins malformed")
    requests = [(commit, commit, "commit") for commit in commits]
    requests += [(tree, tree, "tree") for tree, _ in commits.values()]
    values = _objects(root, requests)
    for (commit, (tree, parents)), raw in zip(commits.items(), values):
        headers = raw.split(b"\n\n", 1)[0].splitlines()
        require([h for h in headers if h.startswith(b"tree ")] == [b"tree " + tree.encode()]
                and [h for h in headers if h.startswith(b"parent ")] == [b"parent " + p.encode() for p in parents],
                "split receipt exact commit parent/tree mismatch: " + commit)
    phases = {SPLIT_SOURCE_COMMIT: 0, SPLIT_BEFORE_COMMIT: 0,
              SPLIT_PR_COMMIT: 1, SPLIT_INGRESS_COMMIT: 1,
              "b0efea56e8d45a5d43bab0717ab15c469b7b53ec": 1, SPLIT_REPAIR_BEFORE_COMMIT: 1,
              SPLIT_REMOTE_COMMIT: 2, SPLIT_REBASED_COMMIT: 2, SPLIT_REPAIR_COMMIT: 2}
    expressions = [(commit + ":" + path, SPLIT_BLOBS[path][phase])
                   for commit, phase in phases.items() for path in CURRENT_PATHS]
    require(_git(root, "rev-parse", *(expression for expression, _ in expressions)).decode().splitlines()
            == [oid for _, oid in expressions], "split receipt actual Git path/blob identity differs")
    requests = [(SPLIT_SOURCE_COMMIT + ":" + p, SPLIT_BLOBS[p][0], "blob") for p in CURRENT_PATHS]
    requests += [(SPLIT_INGRESS_COMMIT + ":" + p, SPLIT_BLOBS[p][1], "blob") for p in CURRENT_PATHS]
    requests += [(SPLIT_REPAIR_COMMIT + ":" + p, SPLIT_BLOBS[p][2], "blob") for p in CURRENT_PATHS]
    raws = _objects(root, requests)
    snapshots = [dict(zip(CURRENT_PATHS, raws[index * 4:(index + 1) * 4])) for index in range(3)]
    for phase, snapshot in enumerate(snapshots):
        require(all(hashlib.sha256(raw).hexdigest() == SPLIT_HASHES[path][phase] for path, raw in snapshot.items()),
                "split receipt immutable whole-file raw mismatch")
    for commit in (SPLIT_REMOTE_COMMIT, SPLIT_REBASED_COMMIT, SPLIT_REPAIR_COMMIT):
        parent = commits[commit][1][0]
        require(_git(root, "diff", "--name-status", "-z", parent, commit).split(b"\0")
                == [b"M", LEDGER_PATH.encode(), b""], "split recovery is not exactly one modified ledger")
    _git(root, "merge-base", "--is-ancestor", SPLIT_SOURCE_COMMIT, SPLIT_BEFORE_COMMIT)
    lineage = _git(root, "rev-list", "--first-parent", SPLIT_REPAIR_COMMIT).decode().splitlines()
    require(SPLIT_INGRESS_COMMIT in lineage, "split recovery does not follow the actual main ingress")
    change = _validate_split_receipt(*snapshots, inventory)
    require(_source_manifest_matches(root, inventory, SPLIT_SOURCE_MANIFEST),
            "split receipt source no longer matches the actual current census")
    require(_source_manifest(root, SPLIT_SOURCE_COMMIT) == SPLIT_SOURCE_MANIFEST,
            "split receipt export manifest differs from actual historical Git source")
    return *snapshots, change


class _SplitReceiptHistory:
    """One validation-call state only; incomplete history cannot yield success."""

    def __init__(self, root: Path, inventory: dict[str, Any]) -> None:
        self.root, self.inventory = root, inventory
        self.proof = None
        self.completed = False

    def step(self, commit: str, previous: Mapping[str, bytes], successor: Mapping[str, bytes]) -> dict | None:
        def same(snapshot, expected):
            return set(snapshot) in (set(PATHS), set(CURRENT_PATHS)) and snapshot == {p: expected[p] for p in snapshot}

        if commit == SPLIT_INGRESS_COMMIT:
            require(self.proof is None, "duplicate split UI ingress")
            proof = _split_receipt_proof(self.root, self.inventory)
            before, pending, _, _ = proof
            require(same(previous, before) and same(successor, pending), "split ingress snapshots differ from proof")
            self.proof = proof
            return {"ui_by_locale": {loc: 0 for loc in CURRENT_LOCALES}, "receipts": 0, "batches": 0,
                    "pending_ui_by_locale": {"zh-CN": 4, "zh-TW": 4}, "source_manifests": {}}
        if commit == SPLIT_REPAIR_COMMIT:
            require(self.proof is not None and not self.completed, "orphan/duplicate split receipt recovery")
            _, pending, complete, change = self.proof
            require(same(previous, pending) and same(successor, complete), "split recovery snapshots differ from proof")
            self.completed = True
            return change
        if self.proof is not None and not self.completed:
            require(same(previous, self.proof[1]) and same(successor, self.proof[1]),
                    "scoped UI/receipt changed while the exact split delivery was pending")
            return {"ui_by_locale": {loc: 0 for loc in CURRENT_LOCALES}, "receipts": 0, "batches": 0,
                    "source_manifests": {}}
        return None

    def finish(self) -> None:
        require(self.proof is None or self.completed, "split UI delivery still lacks its exact official receipts")


# BEGIN_PAD_HINT_FONT_MANIFEST_393
# Keep the actual census and every older manifest/split-receipt proof intact.
_PAD_HINT_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _PAD_HINT_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    previous = history.pad_hint_font_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "pad hint current source census/raw mismatch")
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return True
    return _PAD_HINT_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_PAD_HINT_FONT_MANIFEST_393


# BEGIN_PEOPLE_CARD_HEIGHT_MANIFEST_402
# Actual census remains current; old official receipts are not rewritten.
_PEOPLE_CARD_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _PEOPLE_CARD_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    previous = history.people_card_height_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "people card current source census/raw mismatch")
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return True
    return _PEOPLE_CARD_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_PEOPLE_CARD_HEIGHT_MANIFEST_402


# BEGIN_AXIS_BADGE_FIT_MANIFEST_403
# One fresh proof per comparison call; no cross-call or mutable success cache.
_AXIS_BADGE_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _AXIS_BADGE_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._axis_badge_fit_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 6,
            "axis badge exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "axis badge current source census/raw mismatch")
    # Exact seven current-Aruba combinations: actual + pre403 + old five.
    # The failed402 intermediate raw is deliberately absent.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    # Preserve the old chain's only eighth combination and its short circuit:
    # pre381 MainGame with preAruba, proved freshly only after the above misses.
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_AXIS_BADGE_FIT_MANIFEST_403


# BEGIN_PROMOTION_REVIEW_MANIFEST_406
_PROMOTION_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _PROMOTION_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._promotion_review_copy_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 7,
            "promotion review exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "promotion review current source census/raw mismatch")
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # Exactly eight current-Aruba views; failed402 remains excluded.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_PROMOTION_REVIEW_MANIFEST_406


# BEGIN_CAREER_TENURE_MANIFEST_409
_TENURE_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _TENURE_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._career_tenure_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 8,
            "career tenure exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "career tenure current source census/raw mismatch")
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # The original nine manifests plus this current raw; failed402 stays excluded.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_CAREER_TENURE_MANIFEST_409


# BEGIN_GIFT_PRICE_BADGE_MANIFEST_412
_GIFT_PRICE_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _GIFT_PRICE_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._gift_price_badge_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 9,
            "gift price badge exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "gift price badge current source census/raw mismatch")
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # The original ten manifests plus this current raw; failed402 stays excluded.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_GIFT_PRICE_BADGE_MANIFEST_412


# BEGIN_LEGACY_JA_GIFT_CORRECTION_414
# These two legacy values had no official receipts. This is not an append waiver.
LEGACY_GIFT_PATH = "locale/ui_ja.json"
LEGACY_GIFT_PRODUCT_PATHS = (LEGACY_GIFT_PATH, LEDGER_PATH)
LEGACY_GIFT_KEYS = ("밑줄 그을 자리가 많은 책", "값이 먼저 보이는 선물")
LEGACY_GIFT_TEXTS = {
    LEGACY_GIFT_KEYS[0]: ("下線が引かれすぎた本", "線を引きたい箇所がたくさんある本"),
    LEGACY_GIFT_KEYS[1]: ("価値が先に見える贈り物", "値段が先に目に入る贈り物"),
}
LEGACY_GIFT_ORIGIN_COMMIT = "aaeba142d08278c310505000bcc126a699493479"
LEGACY_GIFT_ORIGIN_BLOB = "53e3610ead0fdcaae7c7c4b787b27f9fdcb4fc67"
LEGACY_GIFT_ORIGIN_SHA256 = "550378458bee465a4d89a0be9ba6e2d18029fd8fbbeb8982b3c99a961708b0fc"
LEGACY_GIFT_BEFORE_COMMIT = "04da1afdf956cad72ffb6641871d4bafa420e82d"
LEGACY_GIFT_AFTER_COMMIT = "88cf816dfa5f2430ae0f4bde574ba90f23e1956f"
LEGACY_GIFT_TREES = ("500f75061182268e0b4725060b920f6b2c7a0f6f", "d9da30a8b96db6f64566acba6f37b1e82496b7ef")
LEGACY_GIFT_BLOBS = {
    LEGACY_GIFT_PATH: ("b8ffd3fdcdd3fb0d8d45fccb3d461372886d9732", "750f9692b662082d93214318c743d3eccd102249"),
    "locale/ui_zh-CN.json": ("f22e96aab6131f05f1f4707fd5703671dcc67ede",) * 2,
    "locale/ui_zh-TW.json": ("5f80fc39b38e2f599d8b1fad4253773b808a001a",) * 2,
    LEDGER_PATH: ("70efc0392c6ca52de156b1774b77de0f6df5733f", "d2cf934e9b905a25729b25bff151aa3afd313e3f"),
}
LEGACY_GIFT_HASHES = {
    LEGACY_GIFT_PATH: ("3c258973361f5438c1c06aeedcfd686b2aedbc910eca8909032908cc1ad50f14", "3c1c9c6c4a566e2b2d5cebb9fabe2f6525f95eb431c212b66c90296b09401f51"),
    "locale/ui_zh-CN.json": ("7b695b4cee8607d2800d0cc5782e33e2b6cb0f03353b4b65b703f8f63005fddb",) * 2,
    "locale/ui_zh-TW.json": ("bbe8eeecb6474b3af757b54915d79a80c7dde5f8729b6beb955737c6722ba318",) * 2,
    LEDGER_PATH: ("2eb983a3973f4e264f008381acd60af5ab030bedab4971ec96a241dff67af715", "4eb354b671126237ff07a1e9724c7cbebde91d1f5be6bfa854e2aaad6e51f484"),
}
LEGACY_GIFT_BATCH_INDEX = 184
LEGACY_GIFT_REVIEW = (
    "Korean-direct repair of two legacy Japanese gift descriptions: prospective underline-worthy passages, "
    "not an already overmarked book; price comes into view first, not abstract value. Two existing values "
    "corrected, zero new UI keys, two first official receipts. Gameplay, other locales and public demo "
    "unchanged; agent review is not native or release approval.")


def _legacy_ja_gift_comparison(snapshot: Mapping[str, bytes], before: Mapping[str, bytes],
                               after: Mapping[str, bytes]) -> dict[str, bytes]:
    """Undo only the proved targets/first receipts/batch; retain later appends."""
    require(set(snapshot) == set(before) == set(after) == set(CURRENT_PATHS),
            "legacy JA gift comparison requires four paths")
    result = dict(snapshot)
    a, b, doc = (_Document(raw) for raw in (before[LEGACY_GIFT_PATH], after[LEGACY_GIFT_PATH], snapshot[LEGACY_GIFT_PATH]))
    edits = []
    for key in LEGACY_GIFT_KEYS:
        require(doc.value.get(key) == LEGACY_GIFT_TEXTS[key][1], "legacy JA gift corrected target rolled back/changed")
        start, end = doc.spans[(key,)]
        bs, be = b.spans[(key,)]
        require(doc.text[start:end] == b.text[bs:be], "legacy JA gift corrected target raw token changed")
        first, last = a.spans[(key,)]
        edits.append((start, end, a.text[first:last]))
    text = doc.text
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start] + replacement + text[end:]
    result[LEGACY_GIFT_PATH] = text.encode()
    a, b, doc = (_Document(raw) for raw in (before[LEDGER_PATH], after[LEDGER_PATH], snapshot[LEDGER_PATH]))
    value = doc.value
    require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "legacy JA gift accepted checksum")
    index = LEGACY_GIFT_BATCH_INDEX
    require(len(value["batches"]) > index and _ordered(value["batches"][index]) == _ordered(b.value["batches"][index]),
            "legacy JA gift batch missing/changed/reordered")
    start, end = doc.spans[("batches", index - 1)][1], doc.spans[("batches", index)][1]
    bs, be = b.spans[("batches", index - 1)][1], b.spans[("batches", index)][1]
    require(doc.text[start:end] == b.text[bs:be], "legacy JA gift batch raw changed")
    edits = [(start, end, "")]
    old_keys = list(a.value["accepted"]["ja"])
    added = list(b.value["accepted"]["ja"])[len(old_keys):]
    require(bool(old_keys) and added == sorted(receipt_id(key) for key in LEGACY_GIFT_KEYS)
            and list(value["accepted"]["ja"])[len(old_keys):len(old_keys) + 2] == added,
            "legacy JA gift first receipt order/population differs")
    for identifier in added:
        require(_ordered(value["accepted"]["ja"].get(identifier)) == _ordered(b.value["accepted"]["ja"][identifier]),
                "legacy JA gift first receipt changed")
    start, end = doc.spans[("accepted", "ja", old_keys[-1])][1], doc.spans[("accepted", "ja", added[-1])][1]
    bs, be = b.spans[("accepted", "ja", old_keys[-1])][1], b.spans[("accepted", "ja", added[-1])][1]
    require(doc.text[start:end] == b.text[bs:be], "legacy JA gift first receipt raw changed")
    edits.append((start, end, ""))
    accepted = {**value["accepted"], "ja": {k: v for k, v in value["accepted"]["ja"].items() if k not in added}}
    start, end = doc.spans[("accepted_sha256",)]
    edits.append((start, end, _ordered(exchange.digest(accepted)).decode()))
    text = doc.text
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start] + replacement + text[end:]
    result[LEDGER_PATH] = text.encode()
    return result


def _validate_legacy_ja_gift_correction(before: Mapping[str, bytes], after: Mapping[str, bytes],
                                        inventory: dict[str, Any]) -> dict[str, Any]:
    require(set(before) == set(after) == set(CURRENT_PATHS), "legacy JA gift requires four paths")
    old, new = ({p: _loads(raw) for p, raw in snapshot.items()} for snapshot in (before, after))
    require(all(before[p] == after[p] for p in UI_PATHS), "legacy JA gift changed another locale")
    require(_ordered(new[LEGACY_GIFT_PATH]) == _ordered({**old[LEGACY_GIFT_PATH],
                **{key: texts[1] for key, texts in LEGACY_GIFT_TEXTS.items()}})
            and all(old[LEGACY_GIFT_PATH].get(key) == texts[0] for key, texts in LEGACY_GIFT_TEXTS.items()),
            "legacy JA gift exact old/new targets differ")
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(len(a["batches"]) == LEGACY_GIFT_BATCH_INDEX and len(b["batches"]) == LEGACY_GIFT_BATCH_INDEX + 1
            and sum(map(len, a["accepted"].values())) == 41250
            and sum(map(len, b["accepted"].values())) == 41252, "legacy JA gift first receipt/batch census differs")
    require(all(v["accepted_sha256"] == exchange.digest(v["accepted"]) for v in (a, b)),
            "legacy JA gift accepted checksum mismatch")
    leaves = sorted((exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
                     for key in LEGACY_GIFT_KEYS), key=lambda leaf: leaf.id)
    ids = {leaf.id for leaf in leaves}
    selected = sorted((leaf for leaf in inventory["leaves"] if leaf.id in ids), key=lambda leaf: leaf.id)
    require(len(selected) == 2 and _ordered({leaf.id: vars(leaf) for leaf in selected})
            == _ordered({leaf.id: vars(leaf) for leaf in leaves}), "legacy JA gift current Korean leaf/protection/support differs")
    require(not ids.intersection(a["accepted"]["ja"])
            and not any(ids.intersection(receipt_id(key) for key in row.get("roots", []))
                        and row.get("target_leaves_by_locale", {}).get("ja", 0) for row in a["batches"]),
            "legacy JA gift falsely claims absent prior acceptance")
    corrected = {leaf.id: {"source_sha256": leaf.source_sha256,
                           "target_sha256": exchange.digest(LEGACY_GIFT_TEXTS[leaf.owner][1])}
                 for leaf in sorted(leaves, key=lambda row: row.id)}
    previous = {leaf.id: exchange.digest(LEGACY_GIFT_TEXTS[leaf.owner][0]) for leaf in leaves}
    for leaf in leaves:
        require(not exchange.translation_errors(leaf, "ja", LEGACY_GIFT_TEXTS[leaf.owner][1]),
                "legacy JA gift translation contract failed")
    batch = b["batches"][LEGACY_GIFT_BATCH_INDEX]
    expected = {"order": "ORDER-414", "group": "ui_correction", "roots": list(LEGACY_GIFT_KEYS), "source_leaves": 2,
                "legacy_origin_commit": LEGACY_GIFT_ORIGIN_COMMIT, "prior_acceptance": "absent",
                "before_target_sha256_by_locale": {"ja": previous},
                "target_leaves_by_locale": {"ja": 2, "zh-CN": 0, "zh-TW": 0},
                "source_review": LEGACY_GIFT_REVIEW, "machine_validation": "PASS", "rendered_review": "OPEN", "native_review": "OPEN"}
    maps = (HEADERS_FIELD, "receipt_sha256_by_locale")
    require(isinstance(batch, dict) and set(batch) == set(expected) | set(maps)
            and all(_ordered(batch[k]) == _ordered(v) for k, v in expected.items())
            and all(isinstance(batch[k], dict) and set(batch[k]) == {"ja"} for k in maps),
            "legacy JA gift batch identity/population differs")
    header = batch[HEADERS_FIELD]["ja"]
    require(header.get("source_revision") == LEGACY_GIFT_BEFORE_COMMIT
            and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))),
            "legacy JA gift export revision/manifest malformed")
    rebuilt = exchange.make_batch({**inventory, "source_manifest_sha256": header["source_manifest_sha256"]},
                                  "ja", sorted(selected, key=lambda leaf: leaf.id), LEGACY_GIFT_BEFORE_COMMIT,
                                  {LEGACY_GIFT_PATH: old[LEGACY_GIFT_PATH]}, {})[0]
    require(_ordered(header) == _ordered(rebuilt), "legacy JA gift official previous-target selection differs")
    receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN", "translations": corrected}
    require(batch["receipt_sha256_by_locale"]["ja"] == exchange.digest(receipt), "legacy JA gift official receipt digest differs")
    accepted = {**a["accepted"], "ja": {**a["accepted"]["ja"], **corrected}}
    require(_ordered(b) == _ordered({**a, "accepted": accepted, "accepted_sha256": exchange.digest(accepted),
                                    "batches": [*a["batches"], batch]}), "legacy JA gift changed an old receipt/batch or ledger field")
    require(_legacy_ja_gift_comparison(after, before, after) == before, "legacy JA gift whole raw inverse differs")
    return {"ui_by_locale": {loc: 0 for loc in CURRENT_LOCALES}, "receipts": 0, "batches": 0,
            "corrections": 2, "correction_batches": 1, "first_receipts": 2,
            "source_manifests": {header["source_revision"]: header["source_manifest_sha256"]}}


def _legacy_ja_gift_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict]:
    """Fresh exact product and legacy provenance; never a cached current admission."""
    require(set(LEGACY_GIFT_BLOBS) == set(LEGACY_GIFT_HASHES) == set(CURRENT_PATHS), "legacy JA gift pin population differs")
    revisions = (LEGACY_GIFT_BEFORE_COMMIT, LEGACY_GIFT_AFTER_COMMIT)
    requests = [(c, c, "commit") for c in revisions] + [(t, t, "tree") for t in LEGACY_GIFT_TREES]
    requests += [(c + ":" + p, LEGACY_GIFT_BLOBS[p][i], "blob") for p in CURRENT_PATHS for i, c in enumerate(revisions)]
    requests.append((LEGACY_GIFT_ORIGIN_COMMIT + ":" + LEGACY_GIFT_PATH, LEGACY_GIFT_ORIGIN_BLOB, "blob"))
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([h for h in headers if h.startswith(b"tree ")] == [b"tree " + LEGACY_GIFT_TREES[index].encode()],
                "legacy JA gift exact tree mismatch")
        if index:
            require([h for h in headers if h.startswith(b"parent ")] == [b"parent " + revisions[0].encode()],
                    "legacy JA gift direct parent mismatch")
    require(_git(root, "diff", "--name-status", "-z", *revisions).split(b"\0")
            == [v for p in sorted(LEGACY_GIFT_PRODUCT_PATHS) for v in (b"M", p.encode())] + [b""],
            "legacy JA gift product path population differs")
    before, after = {}, {}
    for index, path in enumerate(CURRENT_PATHS):
        old, new = values[4 + index * 2:6 + index * 2]
        require(tuple(hashlib.sha256(v).hexdigest() for v in (old, new)) == LEGACY_GIFT_HASHES[path],
                "legacy JA gift immutable whole raw differs")
        before[path], after[path] = old, new
    origin = values[-1]
    require(hashlib.sha256(origin).hexdigest() == LEGACY_GIFT_ORIGIN_SHA256
            and all(_loads(origin).get(key) == texts[0] for key, texts in LEGACY_GIFT_TEXTS.items()),
            "legacy JA gift original target provenance differs")
    _git(root, "merge-base", "--is-ancestor", LEGACY_GIFT_ORIGIN_COMMIT, LEGACY_GIFT_BEFORE_COMMIT)
    return before, after, _validate_legacy_ja_gift_correction(before, after, inventory)
# END_LEGACY_JA_GIFT_CORRECTION_414


# BEGIN_REACTION_BODY_FONT_MANIFEST_417
_REACTION_FONT_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _REACTION_FONT_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._reaction_body_font_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 10,
            "reaction body font exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "reaction body font current source census/raw mismatch")
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # The original eleven manifests plus this current raw; failed402 stays excluded.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_REACTION_BODY_FONT_MANIFEST_417


# BEGIN_DECISION_RISK_WIDTH_MANIFEST_423
_DECISION_RISK_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _DECISION_RISK_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._decision_risk_width_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 11,
            "decision risk width exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "decision risk width current source census/raw mismatch")
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # The original twelve manifests plus this current raw; failed402 stays excluded.
    for main_raw in (raw, *predecessors):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_DECISION_RISK_WIDTH_MANIFEST_423

# BEGIN_LOCAL_COMPARISON_MEMO
def _comparison_memo(paths, corrections):
    """Reuse one successful inverse inside a single validate_history invocation.

    The private corrections list is append-only; its length is the epoch.
    Exact path population and immutable raw bytes, not parsed values or verdicts,
    identify a snapshot. New invocations still perform every Git/proof/HEAD check.
    Copies isolate caller dictionaries, including the zero-correction case.
    """
    ordered_paths = tuple(sorted(paths))
    require(len(ordered_paths) == len(set(ordered_paths)), "comparison path population")
    population = set(ordered_paths)
    cached_key = None
    cached_result = None

    def comparison(snapshot):
        nonlocal cached_key, cached_result
        raw = dict(snapshot)
        require(set(raw) == population, "comparison snapshot population")
        require(all(isinstance(raw[path], bytes) for path in ordered_paths),
                "comparison snapshot must contain immutable bytes")
        key = (len(corrections), tuple((path, raw[path]) for path in ordered_paths))
        if key != cached_key:
            result = raw
            for function, before, after in reversed(corrections):
                result = function(result, before, after)
            # Do not cache a failed inverse or expose its mutable dictionary.
            result = dict(result)
            cached_key, cached_result = key, result
        return dict(cached_result)

    return comparison
# END_LOCAL_COMPARISON_MEMO


# BEGIN_SCALPING_PHASE_FOCUS_430
# One exact product-only successor. Historical headers, MainGame/Aruba proofs,
# corrections and append verification remain unchanged; this is comparison-only.
SCALPING_PHASE_PATH = "scenes/ScalpingGame.gd"
SCALPING_PHASE_BEFORE_COMMIT = "ce44987987376323bb0bfc7b9053435f55d92294"
SCALPING_PHASE_AFTER_COMMIT = "3db5dc8862c10d41c652c1363f3e2dbf8c31e0d7"
SCALPING_PHASE_TREES = ("53e05abc0b5a2b3707e8b92a97d3de748904111d", "2d05cd0dd599b06a8d7b479c06b9deb38fdf9494")
SCALPING_PHASE_BLOBS = ("1205b9d63838cb126b6556a7ded05e6b2f96ef55", "5231d6057835579d9c4e9c982dc905023d421ab1")
SCALPING_PHASE_HASHES = ("90fdad208a04acaec27c3d9904382ed891e3ea5647a6a1db4273be034617c65f",
                         "cee55102af731f4357d77bfc57f95438f4cfbc9036f9877fab7777218a7398e0")
SCALPING_PHASE_REPLACEMENTS = (
    ("var _font_bold: Font\n", "var _font_bold: Font\nvar _phase_overlay: Control\n"),
    ('\tvisible = true\n\tTutorialOverlay.maybe_show("scalping", self)\n',
     '\tvisible = true\n\t_sync_phase_focus()\n\tTutorialOverlay.maybe_show("scalping", self)\n'),
    ("\t\t_sell_btn.disabled = not _in_position\n", "\t\t_sell_btn.disabled = not _in_position\n\t_sync_phase_focus()\n"),
    ('''func _clear_phase_overlay() -> void:
\tvar overlay := get_node_or_null("setup_overlay")
\tif is_instance_valid(overlay) and not overlay.is_queued_for_deletion():
\t\toverlay.queue_free()

func _show_setup() -> void:
\t# 새 오버레이 패널로 설정 화면 표시
\tif has_node("setup_overlay"):
\t\tget_node("setup_overlay").queue_free()
\tvar overlay := ColorRect.new()
\toverlay.name = "setup_overlay"
\toverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
\toverlay.color = Color("#070a10ee")
\toverlay.mouse_filter = Control.MOUSE_FILTER_STOP
\tadd_child(overlay)
''', '''func _clear_phase_overlay() -> void:
\tvar overlay: Control = _phase_overlay
\t_phase_overlay = null
\tif is_instance_valid(overlay):
\t\toverlay.hide()
\t\t# Release the name and focus tree before a same-frame replacement is added.
\t\tif overlay.get_parent() == self:
\t\t\tremove_child(overlay)
\t\toverlay.queue_free()

func _show_setup() -> void:
\t# 새 오버레이 패널로 설정 화면 표시
\t_clear_phase_overlay()
\tvar overlay := ColorRect.new()
\toverlay.name = "setup_overlay"
\toverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
\toverlay.color = Color("#070a10ee")
\toverlay.mouse_filter = Control.MOUSE_FILTER_STOP
\tadd_child(overlay)
\t_phase_overlay = overlay
'''),
    ('''\tvb.add_child(leave_btn)

func _show_result() -> void:
\tif has_node("setup_overlay"):
\t\tget_node("setup_overlay").queue_free()
\tvar overlay := ColorRect.new()
\toverlay.name = "setup_overlay"
\toverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
\toverlay.color = Color("#070a10ee")
\toverlay.mouse_filter = Control.MOUSE_FILTER_STOP
\tadd_child(overlay)
''', '''\tvb.add_child(leave_btn)
\t_sync_phase_focus()

func _show_result() -> void:
\t_clear_phase_overlay()
\tvar overlay := ColorRect.new()
\toverlay.name = "setup_overlay"
\toverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
\toverlay.color = Color("#070a10ee")
\toverlay.mouse_filter = Control.MOUSE_FILTER_STOP
\tadd_child(overlay)
\t_phase_overlay = overlay
'''),
    ('\tvar again_btn := _btn(_tr("다시하기", "Retry"), func():\n\t\toverlay.queue_free()\n',
     '\tvar again_btn := _btn(_tr("다시하기", "Retry"), func():\n'),
    ('''\t_f(leave_btn)
\tbtn_row.add_child(leave_btn)
''', '''\t_f(leave_btn)
\tbtn_row.add_child(leave_btn)
\t_sync_phase_focus()

# Only the current phase owns navigation. TutorialOverlay keeps its own focus trap.
func _phase_buttons(node: Node) -> Array[Button]:
\tvar buttons: Array[Button] = []
\tfor child in node.get_children():
\t\tif child is TutorialOverlay or child.is_queued_for_deletion():
\t\t\tcontinue
\t\tif child is Button:
\t\t\tbuttons.append(child)
\t\tbuttons.append_array(_phase_buttons(child))
\treturn buttons

func _tutorial_owns_focus() -> bool:
\tfor child in get_children():
\t\tif child is TutorialOverlay and not child.is_queued_for_deletion() and child.is_visible_in_tree():
\t\t\treturn true
\treturn false

func _sync_phase_focus() -> void:
\tvar surface: Control = _phase_overlay if is_instance_valid(_phase_overlay) else self
\tvar active: Array[Button] = []
\tfor button in _phase_buttons(self):
\t\tvar eligible: bool = surface.is_ancestor_of(button) and not button.disabled
\t\tbutton.focus_mode = Control.FOCUS_ALL if eligible else Control.FOCUS_NONE
\t\tif eligible and button.is_visible_in_tree():
\t\t\tactive.append(button)
\tif active.is_empty():
\t\treturn
\t# Directional navigation follows the actual grid geometry; Tab stays in this phase.
\tfor index in range(active.size()):
\t\tvar button: Button = active[index]
\t\tbutton.focus_next = button.get_path_to(active[(index + 1) % active.size()])
\t\tbutton.focus_previous = button.get_path_to(active[(index + active.size() - 1) % active.size()])
\tif _tutorial_owns_focus():
\t\treturn
\tvar owner: Control = get_viewport().gui_get_focus_owner()
\tif active.has(owner):
\t\treturn
\tvar preferred: Button = _sell_btn if _in_position else _buy_btn
\tif _phase == Phase.PLAYING and active.has(preferred):
\t\tpreferred.grab_focus()
\telse:
\t\tactive[0].grab_focus()
'''),
    ("\tb.pressed.connect(cb)\n\treturn b\n",
     "\tb.pressed.connect(cb)\n\tb.mouse_entered.connect(func():\n"
     "\t\tif b.is_visible_in_tree() and not b.disabled and b.focus_mode == Control.FOCUS_ALL and not _tutorial_owns_focus():\n"
     "\t\t\tb.grab_focus())\n\treturn b\n"),
)


def _scalping_phase_inverse(raw: bytes) -> bytes:
    """Recover only the exact predecessor; never expose it as current source."""
    require(isinstance(raw, bytes), "Scalping phase inverse requires immutable raw bytes")
    require(len(SCALPING_PHASE_REPLACEMENTS) == 8, "Scalping phase inverse population differs")
    recovered = raw
    for old, new in reversed(SCALPING_PHASE_REPLACEMENTS):
        old, new = old.encode(), new.encode()
        require(bool(old) and bool(new) and old != new and recovered.count(new) == 1,
                "Scalping phase inverse is not exact1")
        recovered = recovered.replace(new, old, 1)
    require(hashlib.sha256(recovered).hexdigest() == SCALPING_PHASE_HASHES[0],
            "Scalping source changed outside exact phase/focus repair")
    return recovered


def scalping_phase_predecessor(root: Path, raw: bytes) -> bytes:
    """Bind the one-file phase/focus repair to immutable Git and actual HEAD."""
    require(isinstance(raw, bytes) and hashlib.sha256(raw).hexdigest() == SCALPING_PHASE_HASHES[1],
            "Scalping current runtime differs from exact phase/focus successor")
    commits = (SCALPING_PHASE_BEFORE_COMMIT, SCALPING_PHASE_AFTER_COMMIT)
    requests = [(commit, commit, "commit") for commit in commits]
    requests += [(tree, tree, "tree") for tree in SCALPING_PHASE_TREES]
    requests += [(commit + ":" + SCALPING_PHASE_PATH, blob, "blob")
                 for commit, blob in zip(commits, SCALPING_PHASE_BLOBS)]
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([line for line in headers if line.startswith(b"tree ")]
                == [b"tree " + SCALPING_PHASE_TREES[index].encode()],
                "Scalping exact phase/focus tree mismatch")
        if index:
            require([line for line in headers if line.startswith(b"parent ")]
                    == [b"parent " + SCALPING_PHASE_BEFORE_COMMIT.encode()],
                    "Scalping exact phase/focus direct parent mismatch")
    require(_git(root, "diff", "--name-status", "-z", *commits).split(b"\0")
            == [b"M", SCALPING_PHASE_PATH.encode(), b""],
            "Scalping phase/focus transition is not exactly one modified file")
    _git(root, "merge-base", "--is-ancestor", SCALPING_PHASE_AFTER_COMMIT, "HEAD")
    require(_git(root, "rev-parse", "HEAD:" + SCALPING_PHASE_PATH).decode().strip() == SCALPING_PHASE_BLOBS[1],
            "actual Git candidate does not retain exact Scalping phase/focus successor")
    before, after = values[4:]
    require(tuple(hashlib.sha256(value).hexdigest() for value in (before, after)) == SCALPING_PHASE_HASHES
            and after == raw, "Scalping phase/focus Git blobs/current raw mismatch")
    require(_scalping_phase_inverse(after) == before, "Scalping exact phase/focus inverse differs from Git predecessor")
    return before


_SCALPING_PHASE_OLD_MANIFEST_MATCHES = _source_manifest_matches
_SCALPING_PHASE_OLD_CURRENT_PROOF = current_proof


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        # Preserve isolated legacy fixtures, never production supplied inventory.
        return _SCALPING_PHASE_OLD_MANIFEST_MATCHES(root, inventory, expected)
    raw = (root / SCALPING_PHASE_PATH).read_bytes()
    previous = scalping_phase_predecessor(root, raw)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(SCALPING_PHASE_PATH) == hashlib.sha256(raw).hexdigest(),
            "Scalping phase/focus current source census/raw mismatch")
    if expected == inventory["source_manifest_sha256"]:
        return _SCALPING_PHASE_OLD_MANIFEST_MATCHES(root, inventory, expected)
    # Only the old Scalping hash may accompany an earlier MainGame/Aruba state.
    # Passing the actual successor to the whole old matcher would admit phantom
    # new-Scalping x old-MainGame combinations that never existed in Git history.
    comparison = {**hashes, SCALPING_PHASE_PATH: hashlib.sha256(previous).hexdigest()}
    return _SCALPING_PHASE_OLD_MANIFEST_MATCHES(
        root, {**inventory, "source_hashes": comparison,
               "source_manifest_sha256": exchange.digest(comparison)}, expected)


def current_proof(root: Path, baseline_commit: str, baseline: Mapping[str, bytes]) -> dict[str, Any]:
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    raw = (root / SCALPING_PHASE_PATH).read_bytes()
    scalping_phase_predecessor(root, raw)
    result = _SCALPING_PHASE_OLD_CURRENT_PROOF(root, baseline_commit, baseline)
    require(result["source_hashes"].get(SCALPING_PHASE_PATH) == hashlib.sha256(raw).hexdigest()
            and exchange.digest(result["source_hashes"]) == result["source_manifest_sha256"]
            and (root / SCALPING_PHASE_PATH).read_bytes() == raw,
            "Scalping phase/focus source changed during current admission")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head
            and result["evidence"]["head"] == head,
            "Git candidate changed during Scalping phase/focus admission")
    return result
# END_SCALPING_PHASE_FOCUS_430


# BEGIN_LOG_BODY_FONT_MANIFEST_432
# Current MainGame now follows the Scalping repair. Keep the two actual later
# states separate from the thirteen states before Scalping changed.
_LOG_BODY_FONT_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _LOG_BODY_FONT_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import main_game_locale_history as history
    raw = (root / history.MAIN_GAME_PATH).read_bytes()
    predecessors = history._log_body_font_proof(raw, root)
    require(isinstance(predecessors, tuple) and len(predecessors) == 12,
            "log body font exact predecessor population differs")
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.MAIN_GAME_PATH) == hashlib.sha256(raw).hexdigest(),
            "log body font current source census/raw mismatch")
    scalp_raw = (root / SCALPING_PHASE_PATH).read_bytes()
    require(hashes.get(SCALPING_PHASE_PATH) == hashlib.sha256(scalp_raw).hexdigest(),
            "Scalping source census not bound to current raw")
    previous_scalp = scalping_phase_predecessor(root, scalp_raw)
    font_raw = (root / ARUBA_FONT_PATH).read_bytes()
    require(hashes.get(ARUBA_FONT_PATH) == hashlib.sha256(font_raw).hexdigest(),
            "Aruba source census not bound to current raw")
    # The actual latest state and the state after Scalping/before the log font.
    # No other earlier MainGame bytes may accompany the new Scalping bytes.
    for main_raw in (raw, predecessors[0]):
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    # Exactly the pre-Scalping MainGame/Aruba history; never new Main x old Scalp.
    for main_raw in predecessors:
        comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(main_raw).hexdigest(),
                      SCALPING_PHASE_PATH: hashlib.sha256(previous_scalp).hexdigest()}
        if expected == exchange.digest(comparison):
            return True
    previous_font = aruba_font_predecessor(root, font_raw)
    comparison = {**hashes, history.MAIN_GAME_PATH: hashlib.sha256(predecessors[-1]).hexdigest(),
                  SCALPING_PHASE_PATH: hashlib.sha256(previous_scalp).hexdigest(),
                  ARUBA_FONT_PATH: hashlib.sha256(previous_font).hexdigest()}
    return expected == exchange.digest(comparison)
# END_LOG_BODY_FONT_MANIFEST_432


# BEGIN_HOLDEM_WHOLE_WON_MANIFEST_434
# Holdem follows the fifteen real MainGame/Scalping/Aruba states. It is not
# interchangeable with an earlier state of any of those source files.
_HOLDEM_MONEY_OLD_MANIFEST_MATCHES = _source_manifest_matches
_HOLDEM_MONEY_OLD_CURRENT_PROOF = current_proof


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _HOLDEM_MONEY_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import holdem_money_history as history
    raw = (root / history.HOLDEM_PATH).read_bytes()
    previous = history.holdem_money_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest(),
            "Holdem whole-won current source census/raw mismatch")
    comparison = {**hashes, history.HOLDEM_PATH: hashlib.sha256(previous).hexdigest()}
    predecessor_inventory = {**inventory, "source_hashes": comparison,
                             "source_manifest_sha256": exchange.digest(comparison)}
    # Check the actual predecessor through the complete prior proof, including
    # its real MainGame/Scalping/Aruba tuple, before admitting the one new tuple.
    if expected == inventory["source_manifest_sha256"]:
        return _HOLDEM_MONEY_OLD_MANIFEST_MATCHES(
            root, predecessor_inventory, predecessor_inventory["source_manifest_sha256"])
    return _HOLDEM_MONEY_OLD_MANIFEST_MATCHES(root, predecessor_inventory, expected)


def current_proof(root: Path, baseline_commit: str, baseline: Mapping[str, bytes]) -> dict[str, Any]:
    import holdem_money_history as history
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    raw = (root / history.HOLDEM_PATH).read_bytes()
    history.holdem_money_predecessor(raw, root)
    result = _HOLDEM_MONEY_OLD_CURRENT_PROOF(root, baseline_commit, baseline)
    require(result["source_hashes"].get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest()
            and exchange.digest(result["source_hashes"]) == result["source_manifest_sha256"]
            and (root / history.HOLDEM_PATH).read_bytes() == raw,
            "Holdem whole-won source changed during current admission")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head
            and result["evidence"]["head"] == head,
            "Git candidate changed during Holdem whole-won admission")
    return result
# END_HOLDEM_WHOLE_WON_MANIFEST_434


# BEGIN_HOLDEM_CANVAS_WIDTH_MANIFEST_436
# Keep the real whole-won intermediate tuple as well as the prior fifteen
# tuples and the current canvas repair. Never mix new Holdem with old peers.
_HOLDEM_CANVAS_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _HOLDEM_CANVAS_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import holdem_money_history as history
    raw = (root / history.HOLDEM_PATH).read_bytes()
    intermediate = history.holdem_canvas_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest(),
            "Holdem canvas current census/raw mismatch")
    comparison = {**hashes, history.HOLDEM_PATH: hashlib.sha256(intermediate).hexdigest()}
    if expected == exchange.digest(comparison):
        # Admit the intermediate only through the actual current tuple's full
        # predecessor proof. A projected census is not a current raw binding.
        return _HOLDEM_CANVAS_OLD_MANIFEST_MATCHES(
            root, inventory, inventory["source_manifest_sha256"])
    return _HOLDEM_CANVAS_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_HOLDEM_CANVAS_WIDTH_MANIFEST_436


# BEGIN_HOLDEM_BETTING_TURN_MANIFEST_437
# Add only the actual pre-betting tuple. The earlier width/money/history
# wrappers still prove all earlier tuples against current peer source bytes.
_HOLDEM_BETTING_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _HOLDEM_BETTING_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import holdem_money_history as history
    raw = (root / history.HOLDEM_PATH).read_bytes()
    previous = history.holdem_betting_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest(),
            "Holdem betting current census/raw mismatch")
    comparison = {**hashes, history.HOLDEM_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return _HOLDEM_BETTING_OLD_MANIFEST_MATCHES(
            root, inventory, inventory["source_manifest_sha256"])
    return _HOLDEM_BETTING_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_HOLDEM_BETTING_TURN_MANIFEST_437


# BEGIN_HOLDEM_ASYNC_ACTION_MANIFEST_438
# Admit the actual pre-async tuple without combining new Holdem with old peers.
_HOLDEM_ASYNC_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _HOLDEM_ASYNC_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import holdem_money_history as history
    raw = (root / history.HOLDEM_PATH).read_bytes()
    previous = history.holdem_async_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest(),
            "Holdem async current census/raw mismatch")
    comparison = {**hashes, history.HOLDEM_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return _HOLDEM_ASYNC_OLD_MANIFEST_MATCHES(
            root, inventory, inventory["source_manifest_sha256"])
    return _HOLDEM_ASYNC_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_HOLDEM_ASYNC_ACTION_MANIFEST_438


# BEGIN_HOLDEM_CARD_FACE_MANIFEST_441
# Add only the real pre-contrast tuple. Do not combine the current Holdem raw
# with older MainGame/Scalping/Aruba source bytes or rewrite prior receipts.
_HOLDEM_CARD_COLOR_OLD_MANIFEST_MATCHES = _source_manifest_matches


def _source_manifest_matches(root: Path, inventory: dict[str, Any], expected: str) -> bool:
    if "source_hashes" not in inventory:
        return _HOLDEM_CARD_COLOR_OLD_MANIFEST_MATCHES(root, inventory, expected)
    import holdem_money_history as history
    raw = (root / history.HOLDEM_PATH).read_bytes()
    previous = history.holdem_card_color_predecessor(raw, root)
    hashes = inventory["source_hashes"]
    require(exchange.digest(hashes) == inventory["source_manifest_sha256"]
            and hashes.get(history.HOLDEM_PATH) == hashlib.sha256(raw).hexdigest(),
            "Holdem card-face current census/raw mismatch")
    comparison = {**hashes, history.HOLDEM_PATH: hashlib.sha256(previous).hexdigest()}
    if expected == exchange.digest(comparison):
        return _HOLDEM_CARD_COLOR_OLD_MANIFEST_MATCHES(
            root, inventory, inventory["source_manifest_sha256"])
    return _HOLDEM_CARD_COLOR_OLD_MANIFEST_MATCHES(root, inventory, expected)
# END_HOLDEM_CARD_FACE_MANIFEST_441
