#!/usr/bin/env python3
"""Validate portable, append-only Chinese UI receipts above an immutable base.

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
HEADERS_FIELD = "official_receipt_headers_by_locale"


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
    if relative in UI_PATHS:
        if len(new.value) > len(old.value):
            replacements.append(_tail(new, (), list(old.value), list(new.value)))
    else:
        for locale in LOCALES:
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
    require(set(before) == set(after) == set(PATHS), "exact three-path snapshot required")
    old = {path: _Document(before[path]).value for path in PATHS}
    new = {path: _Document(after[path]).value for path in PATHS}
    additions = {}
    for locale, path in zip(LOCALES, UI_PATHS):
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
    require(not receipt_additions["ja"], "Japanese receipt append is outside the two-file UI boundary")
    require(isinstance(a["batches"], list) and isinstance(b["batches"], list)
            and _ordered(b["batches"][:len(a["batches"])]) == _ordered(a["batches"]),
            "old batches changed/deleted/reordered")
    batches = b["batches"][len(a["batches"]):]
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    require(len(leaves) == len(inventory["leaves"]), "duplicate current source leaf ID")
    for locale in LOCALES:
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
    assigned = {locale: set() for locale in LOCALES}
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
                and type(counts["ja"]) is int and counts["ja"] == 0
                and all(type(counts[loc]) is int and counts[loc] in (0, len(roots)) for loc in LOCALES),
                "new batch locale/count mismatch")
        locales = {loc for loc in LOCALES if counts[loc]}
        headers, hashes = batch.get(HEADERS_FIELD), batch.get("receipt_sha256_by_locale")
        require(bool(locales) and isinstance(headers, dict) and isinstance(hashes, dict)
                and set(headers) == set(hashes) == locales, "portable official receipt headers/locales missing")
        ids = {receipt_id(key) for key in roots}
        for locale in locales:
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
    require(all(assigned[loc] == set(receipt_additions[loc]) for loc in LOCALES),
            "new receipts lack exactly one official unit batch")
    for path in PATHS:
        _raw_inverse(before[path], after[path], path)
    return {"ui_by_locale": {loc: len(additions[loc]) for loc in LOCALES}, "batches": len(batches),
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


def _snapshot(root: Path, revision: str) -> dict[str, bytes]:
    expressions = [revision + ":" + path for path in PATHS]
    ids = _git(root, "rev-parse", *expressions).decode().splitlines()
    require(len(ids) == len(PATHS) and all(re.fullmatch(r"[0-9a-f]{40}", oid) for oid in ids),
            "current Git file identities malformed")
    return dict(zip(PATHS, _objects(root, [(expr, oid, "blob") for expr, oid in zip(expressions, ids)])))


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
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", head) is not None, "invalid current Git candidate")
    lineage = _git(root, "rev-list", "--first-parent", head).decode().splitlines()
    require(baseline_commit in lineage, "baseline is not on the current first-parent lineage")
    require(_snapshot(root, baseline_commit) == baseline, "Git baseline differs from immutable caller proof")
    candidate = _snapshot(root, head)
    require(candidate == current, "submitted/current raw differs from actual Git candidate")
    commits = _git(root, "log", "--first-parent", "--full-history", "--reverse", "--format=%H",
                   baseline_commit + ".." + head, "--", *PATHS).decode().splitlines()
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
        require(_snapshot(root, parents[0]) == previous, "omitted/noncontiguous UI receipt transition")
        successor = _snapshot(root, commit)
        change = validate_append(previous, successor, inventory)
        for revision, expected in change["source_manifests"].items():
            _git(root, "merge-base", "--is-ancestor", revision, parents[0])
            require(expected == inventory["source_manifest_sha256"],
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
    current = {path: (root / path).read_bytes() for path in PATHS}
    inventory = exchange.collect(root)
    errors = [row for row in inventory["unsupported"]
              if row["kind"] in {"static_ui_contract", "demo_dynamic_contract"}]
    require(not errors, "current source collector contract failed: " + str(errors))
    evidence = validate_history(root, baseline_commit, baseline, current, inventory)
    require(all((root / path).read_bytes() == raw for path, raw in current.items()),
            "current UI/receipt bytes changed during validation")
    return {"raw": current, "evidence": evidence}
