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
from order351_source_compat import _Document, _ordered

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
    for commit in commits:
        raw = _objects(root, [(commit, commit, "commit")])[0]
        parents = [line[7:].decode() for line in raw.split(b"\n\n", 1)[0].splitlines() if line.startswith(b"parent ")]
        require(bool(parents) and parents[0] in lineage, "Git transition parent missing from current lineage")
        require(_snapshot(root, parents[0], paths) == previous, "omitted/noncontiguous UI receipt transition")
        successor = _snapshot(root, commit, paths)
        change = validate_append(previous, successor, inventory)
        for revision, expected in change["source_manifests"].items():
            _git(root, "merge-base", "--is-ancestor", revision, parents[0])
            require(_source_manifest_matches(root, inventory, expected),
                    "KO/runtime source changed; use a separate source-change review, not UI append")
            if revision not in source_manifests:
                source_manifests[revision] = _source_manifest(root, revision)
            require(source_manifests[revision] == expected, "receipt source manifest differs from actual Git census")
        transitions.append({"commit": commit, **change})
        totals.update({"receipts": change["receipts"], "batches": change["batches"]})
        previous = successor
    require(previous == candidate, "Git history does not reconstruct current UI receipts")
    # Independently prove the full byte inverse, not just each incremental hop.
    combined = validate_append(baseline, candidate, inventory)
    require(combined["receipts"] == totals["receipts"] and combined["batches"] == totals["batches"],
            "history/current append census mismatch")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
            "Git candidate changed during validation")
    return {"head": head, "transitions": transitions, **combined}


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
