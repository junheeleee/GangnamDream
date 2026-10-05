"""Exact PR31 intake, separate current admission and historical comparisons.

Only the pinned, reviewed product transition is admitted. Old 351/350/313/309
modules, their immutable objects and their original corpora remain untouched.
The old prose returned here is comparison-only, never a current inventory.
"""
from __future__ import annotations

import contextlib
import contextvars
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

import order351_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
INTAKE_PARENT = "8a2c9a9e5cc61c05c9f58b238d59bbbe7a3ce39b"
INTAKE_COMMIT = "4b2679239bb76fdc7963f47ee25a505820efcca7"
PR_COMMIT = "b9284e3d28116c93e441e12c346fe15ee2f69fef"
MERGE_BASE = "366e0e621e266eeb1d260b9b614af8a92b38027d"
REPAIR_COMMIT = "db4de2f3ebbc87f60d6877fde0af4d23fbe27757"
# Actual official export/check/import rows, each correcting eight existing
# accepted leaves without changing the already-reviewed localized prose.
REPAIR_BATCH_SHA256 = {
    "ja": "f006e2fc1f836edd7a173da44af3f252d442ff9378a5e560fda0c2ab0b1af4f9",
    "zh-CN": "beb3267f1a5d366898f2c6978b4ff003849069b93c416e12a65ce8cef90f622c",
    "zh-TW": "3373439863962a650c6c1afe1bda3e07c689d123a52fcdbdaeba9ec754039726",
}
LEDGER_PATH = "content/meta/full_game_localization.json"
INVENTORY_PATH = "content/meta/release_content_inventory.json"
INVENTORY_RAW_SHA256 = (
    "f46041343731f5cd64b680f778cff9ee77ea0c67fe114536f27a557fe5c1ead0",
    "3ff3828edbd8146cbcf3d24e7ad8850945db8603f71b80f664c975dbabfb1e6b",
)
LOCALES = ("ja", "zh-CN", "zh-TW")
UI_PATHS = tuple("locale/ui_" + locale + ".json" for locale in LOCALES)
CURRENT_UI_PATHS = (*UI_PATHS, LEDGER_PATH)
_NAMES = ("arc_chapter_themes", "arc_daeun", "arc_daeun_extension", "arc_daeun_married",
          "arc_daeun_romance", "arc_drama", "arc_h2_beats", "arc_midgame",
          "arc_new_characters", "arc_pre_ending", "arc_web_crossbeams",
          "arc_year3_drama", "arc_year_close")
CONTENT_PATHS = tuple(sorted(
    ["content/" + directory + "/" + name + ".json"
     for directory in ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")
     for name in _NAMES]
    + ["content/events/arc_jiyeon_married.json"]
    + ["content/endings" + suffix + ".json" for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW")]))
SOURCE_PATHS = tuple(path for path in CONTENT_PATHS
                     if path.startswith("content/events/") or path == "content/endings.json")
HISTORY_CONTENT_PATHS = tuple(path for path in CONTENT_PATHS
                             if path.startswith(("content/events/", "content/events_en/")))
PRODUCT_PATHS = (*CONTENT_PATHS, LEDGER_PATH, INVENTORY_PATH, "docs/CONTENT_RATING_INVENTORY.md")
PROTECTED_PATHS = (*UI_PATHS, "scenes/MainGame.gd", "project.godot", "docs/human_gates.json",
                   *("content/" + directory + "/arc_events.json" for directory in
                     ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")))
REPAIR_IDS = (
    "events:arc_father_legacy:/description",
    "events:arc_father_legacy:/description_memory_if_known/chapter5_general_debt_memory_reconnect_0",
    "events:arc_father_legacy:/description_memory_if_known/chapter5_general_debt_memory_reconnect_1",
    "events:arc_minseo_03_arrival:/description",
    "events:arc_y5_general_name_boundary_exact:/description",
    "events:arc_y5_general_debt_memory_reconnect:/description",
    "events:arc_y5_general_debt_memory_reconnect:/choices/0/result_text",
    "events:arc_y5_final_father_answer_alive:/description",
)
_ACTIVE = contextvars.ContextVar("pr31_intake_proof", default=None)
_Document = previous._Document
_loads = previous._loads
_ordered = previous._ordered
HISTORICAL_PATHS = tuple(dict.fromkeys((*previous.HISTORICAL_PATHS, *HISTORY_CONTENT_PATHS)))


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _digest(value):
    return _sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


def _require(ok, detail):
    if not ok:
        raise ValueError("PR31 intake: " + detail)


def _git(root, *args, input=None):
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    _require(result.returncode == 0, "Git proof unavailable: " + " ".join(args))
    return result.stdout


def _objects(root, requests):
    """Fresh typed/hash-checked objects; no success persists across invocations."""
    output = _git(root, "cat-file", "--batch", input="".join(row[0] + "\n" for row in requests).encode())
    cursor, result = 0, []
    for expression, oid, kind in requests:
        end = output.find(b"\n", cursor)
        header = output[cursor:end].split() if end >= cursor else []
        _require(len(header) == 3 and header[:2] == [oid.encode(), kind.encode()]
                 and header[2].isdigit(), "object identity/type: " + expression)
        size = int(header[2])
        raw = output[end + 1:end + 1 + size]
        cursor = end + 1 + size
        _require(len(raw) == size and output[cursor:cursor + 1] == b"\n"
                 and hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest() == oid,
                 "object bytes: " + expression)
        cursor += 1
        result.append(raw)
    _require(cursor == len(output), "trailing object proof")
    return result


def _snapshot(root, revision, paths):
    """Object membership is bound to a verified immutable commit/tree."""
    _require(re.fullmatch(r"[0-9a-f]{40}", revision) is not None, "unbound product revision")
    commit = _objects(root, [(revision, revision, "commit")])[0]
    headers = commit.split(b"\n\n", 1)[0].splitlines()
    trees = [line[5:].decode() for line in headers if line.startswith(b"tree ")]
    _require(len(trees) == 1 and re.fullmatch(r"[0-9a-f]{40}", trees[0]) is not None, "commit tree")
    _objects(root, [(trees[0], trees[0], "tree")])
    entries = {}
    for record in _git(root, "ls-tree", "-r", "-z", trees[0], "--", *paths).split(b"\0"):
        if record:
            meta, path = record.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            _require(mode == "100644" and kind == "blob", "source mode/type " + path.decode())
            entries[path.decode()] = oid
    _require(set(entries) == set(paths), "exact snapshot path population")
    requests = [(revision + ":" + path, entries[path], "blob") for path in paths]
    return dict(zip(paths, _objects(root, requests))), headers


def _changes(before, after, path=()):
    if type(before) is not type(after):
        yield path, before, after
    elif isinstance(before, dict):
        for key in dict.fromkeys((*before, *after)):
            if key not in before or key not in after:
                yield path + (key,), before.get(key), after.get(key)
            else:
                yield from _changes(before[key], after[key], path + (key,))
    elif isinstance(before, list):
        if len(before) != len(after):
            yield path, before, after
        else:
            for index, (old, new) in enumerate(zip(before, after)):
                yield from _changes(old, new, path + (index,))
    elif before != after:
        yield path, before, after


def _rows(raw):
    rows = _loads(raw)
    _require(isinstance(rows, list) and all(isinstance(row, dict) and isinstance(row.get("id"), str)
                                         for row in rows), "ID-array source shape")
    result = {row["id"]: row for row in rows}
    _require(len(result) == len(rows), "duplicate source ID")
    return result


def _validate_content(before, after):
    """The pinned PR can change prose/variant keys, never gameplay values."""
    changed = {}
    fields = {"title", "description", "description_if_known", "description_if_moral",
              "description_memory_if_known", "description_if_partner", "description_if_flag",
              "condition", "choices"}
    for path in CONTENT_PATHS:
        old, new = _rows(before[path]), _rows(after[path])
        _require(list(old) == list(new), "event/ending identity or order changed: " + path)
        selectors = []
        for eid in old:
            for key, a, b in _changes(old[eid], new[eid]):
                _require(key and key[0] in fields, "gameplay field changed: " + path + "#" + eid + repr(key))
                if key[0] == "choices":
                    _require(len(key) >= 3 and key[2] in {"text", "result_text", "result_text_if_known",
                             "result_text_if_moral", "result_text_if_partner", "result_text_memory_if_known"},
                             "choice gameplay changed: " + path + "#" + eid + repr(key))
                _require((isinstance(a, str) or a is None) and (isinstance(b, str) or b is None),
                         "non-text content delta: " + path + "#" + eid + repr(key))
                selectors.append((eid, key))
        _require(bool(selectors), "registered content file has no semantic change: " + path)
        changed[path] = tuple(selectors)
    return changed


def _ledger_union(base_raw, main_raw, branch_raw, merged_raw):
    base, main, branch, merged = map(_loads, (base_raw, main_raw, branch_raw, merged_raw))
    expected = copy.deepcopy(main)
    for locale in LOCALES:
        a, b, c = (doc["accepted"][locale] for doc in (base, main, branch))
        _require(set(a) <= set(b) and set(a) <= set(c), "accepted receipt deletion")
        for key, value in c.items():
            if key in a and value == a[key]:
                continue
            _require(key not in b or key in a and b[key] == a[key] or b[key] == value,
                     "unresolved three-way receipt conflict: " + locale + ":" + key)
            expected["accepted"][locale][key] = value
    _require(base["batches"] == branch["batches"] and main["batches"][:len(base["batches"])] == base["batches"],
             "branch batch history is not preserved")
    for key in branch:
        if key not in {"accepted", "accepted_sha256"}:
            _require(branch[key] == base[key], "unowned branch ledger metadata: " + key)
    expected["accepted_sha256"] = _digest(expected["accepted"])
    _require(_ordered(merged) == _ordered(expected), "merged ledger is not the exact ordered three-way union")
    _require(sum(map(len, merged["accepted"].values())) == 41830 and len(merged["batches"]) == 237,
             "intake accepted/batch census differs")
    return expected


def inventory_inverse(before, after):
    _require(isinstance(before, bytes) and isinstance(after, bytes)
             and (_sha(before), _sha(after)) == INVENTORY_RAW_SHA256,
             "inventory raw pair is not the reviewed immutable transition")
    old, new = _Document(before), _Document(after)
    allowed = {("corpus_contract", "ending_content_sha256")}
    ids = [row["id"] for row in old.value["content_axes"]]
    _require(ids == [row["id"] for row in new.value["content_axes"]], "inventory axis identity/order")
    for axis in ("gambling", "sexuality", "violence", "fear", "alcohol_tobacco_drugs"):
        allowed.add(("content_axes", ids.index(axis), "candidate_scan", "expected_content_sha256"))
    for axis in ("violence", "fear"):
        for field in ("expected_event_count", "expected_ids_sha256"):
            allowed.add(("content_axes", ids.index(axis), "candidate_scan", field))
    for field in ("expected_file_count", "reviewed_search_noise_ids"):
        allowed.add(("content_axes", ids.index("violence"), "candidate_scan", field))
    changes = list(_changes(old.value, new.value))
    _require({path for path, _, _ in changes} == allowed, "inventory exact reviewed field population")
    text = new.text
    replacements = []
    for path, _, _ in changes:
        a, z = old.spans[path]
        p, q = new.spans[path]
        replacements.append((p, q, old.text[a:z]))
    for p, q, literal in sorted(replacements, reverse=True):
        text = text[:p] + literal + text[q:]
    _require(text.encode() == before, "inventory bytes outside reviewed fields changed")
    return before


def _read_proof(root=ROOT):
    root = Path(root)
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    paths = tuple(dict.fromkeys((*PRODUCT_PATHS, *PROTECTED_PATHS)))
    before, _ = _snapshot(root, INTAKE_PARENT, paths)
    after, headers = _snapshot(root, INTAKE_COMMIT, paths)
    branch, _ = _snapshot(root, PR_COMMIT, paths)
    base, _ = _snapshot(root, MERGE_BASE, (LEDGER_PATH,))
    parents = [line[7:].decode() for line in headers if line.startswith(b"parent ")]
    _require(parents == [INTAKE_PARENT, PR_COMMIT], "exact merge parents")
    _require(_git(root, "merge-base", INTAKE_PARENT, PR_COMMIT).decode().strip() == MERGE_BASE, "merge base differs")
    _git(root, "merge-base", "--is-ancestor", INTAKE_COMMIT, head)
    changed_paths = _git(root, "diff", "--name-only", "-z", INTAKE_PARENT, INTAKE_COMMIT, "--", "content", "scenes", "project.godot").split(b"\0")
    expected_paths = sorted(path for path in PRODUCT_PATHS if path.startswith("content/"))
    _require(changed_paths == [path.encode() for path in expected_paths] + [b""], "product content/runtime path set")
    for path in CONTENT_PATHS:
        _require(after[path] == branch[path], "intake content differs from reviewed PR tip: " + path)
    for path in PROTECTED_PATHS:
        _require(before[path] == after[path], "protected source changed: " + path)
    changes = _validate_content(before, after)
    _ledger_union(base[LEDGER_PATH], before[LEDGER_PATH], branch[LEDGER_PATH], after[LEDGER_PATH])
    inventory_inverse(before[INVENTORY_PATH], after[INVENTORY_PATH])
    current = dict(after)
    repair = None
    if REPAIR_COMMIT is not None:
        repair, repair_headers = _snapshot(root, REPAIR_COMMIT, paths)
        _git(root, "merge-base", "--is-ancestor", INTAKE_COMMIT, REPAIR_COMMIT)
        _git(root, "merge-base", "--is-ancestor", REPAIR_COMMIT, head)
        # The separately reviewed receipt-only product may follow support commits.
        repair_parents = [line[7:].decode() for line in repair_headers if line.startswith(b"parent ")]
        _require(len(repair_parents) == 1, "receipt repair is not a direct-parent product")
        repair_before, _ = _snapshot(root, repair_parents[0], paths)
        _require(repair_before == after, "receipt repair predecessor changed product bytes")
        _require(_git(root, "diff", "--name-status", "-z", repair_parents[0], REPAIR_COMMIT)
                 == b"M\0" + LEDGER_PATH.encode() + b"\0", "receipt repair path set")
        _validate_repair(after, repair, root)
        current = repair
    actual, _ = _snapshot(root, head, paths)
    _require(actual == current, "current HEAD product differs from approved intake/receipt repair")
    for path in paths:
        _require((root / path).read_bytes() == current[path], "current disk differs from Git: " + path)
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head, "HEAD changed during proof")
    return {"root": root.resolve(), "head": head, "before": before, "after": after, "current": current,
            "repair": repair, "changes": changes, "branch": branch}


@contextlib.contextmanager
def fresh_validation_proof(root=ROOT):
    if _ACTIVE.get() is not None:
        _require(Path(root).resolve() == _ACTIVE.get()["root"], "nested proof changed repository")
        yield _ACTIVE.get()
        return
    proof = _read_proof(root)
    token = _ACTIVE.set(proof)
    try:
        yield proof
        # This is a current-intake-only boundary. Later content, receipt or UI
        # work needs its own declared successor; no future append is normalized.
        _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == proof["head"],
                 "HEAD changed inside proof scope")
        actual, _ = _snapshot(root, proof["head"], tuple(proof["current"]))
        _require(actual == proof["current"], "Git product changed inside proof scope")
        _require(all((Path(root) / path).read_bytes() == raw for path, raw in proof["current"].items()),
                 "disk product changed inside proof scope")
    finally:
        _ACTIVE.reset(token)


def current_content_raw(root=ROOT):
    with fresh_validation_proof(root) as proof:
        return {path: proof["current"][path] for path in CONTENT_PATHS}


def source_predecessor_inventory(root, inventory):
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        _require(_digest(hashes) == inventory["source_manifest_sha256"], "current source census digest")
        _require(all(hashes.get(path) == _sha(proof["current"][path]) for path in SOURCE_PATHS),
                 "current source census/content raw binding")
        comparison = {**hashes, **{path: _sha(proof["before"][path]) for path in SOURCE_PATHS}}
        return {**inventory, "source_hashes": comparison, "source_manifest_sha256": _digest(comparison)}


def release_inventory_predecessor(raw, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(raw == proof["current"][INVENTORY_PATH], "current inventory raw differs")
        return inventory_inverse(proof["before"][INVENTORY_PATH], raw)


def _leaf_receipt(snapshot, locale, identifier):
    group, owner, pointer = identifier.split(":", 2)
    _require(group == "events", "receipt recovery group")
    source_path = next((path for path in SOURCE_PATHS if path.startswith("content/events/")
                        and owner in _rows(snapshot[path])), None)
    _require(source_path is not None, "receipt recovery owner")
    tokens = tuple(int(k) if k.isdigit() else k.replace("~1", "/").replace("~0", "~") for k in pointer[1:].split("/"))
    source, target = _rows(snapshot[source_path])[owner], _rows(snapshot[source_path.replace("/events/", "/events_" + locale + "/")])[owner]
    for key in tokens:
        source, target = source[key], target[key]
    _require(isinstance(source, str) and isinstance(target, str), "receipt text leaf shape")
    return {"source_sha256": _digest({"path": source_path, "field": tokens, "ko": source}),
            "target_sha256": _digest(target)}


def _validate_repair(before, after, root=ROOT):
    _require(all(before[path] == after[path] for path in before if path != LEDGER_PATH), "receipt recovery changed content")
    old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
    expected = copy.deepcopy(old)
    for locale in LOCALES:
        for identifier in REPAIR_IDS:
            receipt = _leaf_receipt(after, locale, identifier)
            _require(identifier in old["accepted"][locale] and old["accepted"][locale][identifier] != receipt,
                     "recovery must correct an existing stale receipt")
            expected["accepted"][locale][identifier] = receipt
    expected["accepted_sha256"] = _digest(expected["accepted"])
    _require(new["batches"][:len(old["batches"])] == old["batches"]
             and len(new["batches"]) == len(old["batches"]) + 3,
             "receipt recovery must preserve all original237 batches and append exactly3")
    _require(set(REPAIR_BATCH_SHA256) == set(LOCALES), "actual official receipt row pins are missing")
    seen, source_snapshots = set(), {INTAKE_COMMIT: before}
    for batch in new["batches"][len(old["batches"]):]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(isinstance(headers, dict) and len(headers) == 1, "one official locale per recovery batch")
        locale = next(iter(headers))
        _require(locale in LOCALES and locale not in seen
                 and _digest(batch) == REPAIR_BATCH_SHA256[locale], "exact official recovery batch row")
        seen.add(locale)
        header = headers[locale]
        _require(set(header) == {"kind", "schema_version", "locale", "source_revision", "prompt_version",
                                "source_manifest_sha256", "selection_sha256", "count", "source_language",
                                "native_review", "batch_id"}
                 and header["kind"] == "full_game_localization_batch"
                 and header["schema_version"] == 1 and header["locale"] == locale
                 and header["prompt_version"] == old["prompt_version"]
                 and header["count"] == len(REPAIR_IDS) and header["source_language"] == "ko"
                 and header["native_review"] == "OPEN"
                 and header["batch_id"] == _digest({k: v for k, v in header.items() if k != "batch_id"}),
                 "official recovery header identity/count/state")
        _require(batch.get("order") == "ORDER-468" and batch.get("group") == "events"
                 and batch.get("source_leaves") == len(REPAIR_IDS)
                 and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN",
                 "recovery row scope or machine/native distinction")
        counts = batch.get("target_leaves_by_locale", {})
        _require(set(counts) <= set(LOCALES)
                 and all(counts.get(loc, 0) == (len(REPAIR_IDS) if loc == locale else 0) for loc in LOCALES),
                 "recovery target census is not exact8 for its locale")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {identifier: new["accepted"][locale][identifier] for identifier in REPAIR_IDS}}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)},
                 "official accepted receipt does not match exact8 current leaves")
        revision = header["source_revision"]
        _git(root, "merge-base", "--is-ancestor", revision, REPAIR_COMMIT)
        if revision not in source_snapshots:
            source_snapshots[revision], _ = _snapshot(root, revision, tuple(before))
        _require(source_snapshots[revision] == before,
                 "official export revision has a different product source/ledger")
    _require(seen == set(LOCALES), "official recovery locales are incomplete")
    expected["batches"] = new["batches"]
    _require(_ordered(new) == _ordered(expected), "receipt recovery exceeds exact24 values/batch additions")


def _receipt_comparison(snapshot, before, after):
    _require(set(snapshot) == set(before) == set(after) == set(CURRENT_UI_PATHS), "receipt comparison path population")
    _require(snapshot[LEDGER_PATH] == after[LEDGER_PATH], "receipt comparison is not exact approved ledger")
    _require(all(snapshot[path] == after[path] == before[path] for path in UI_PATHS), "receipt comparison changed UI dictionary")
    return {**snapshot, LEDGER_PATH: before[LEDGER_PATH]}


def receipt_transitions(root, inventory):
    """Actual four-raw snapshots for the UI verifier's existing correction seam."""
    with fresh_validation_proof(root) as proof:
        result = []
        for commit, a, b in ((INTAKE_COMMIT, proof["before"], proof["after"]),
                             (REPAIR_COMMIT, proof["after"], proof["repair"])):
            if commit is None:
                continue
            before = {path: a[path] for path in CURRENT_UI_PATHS}
            after = {path: b[path] for path in CURRENT_UI_PATHS}
            old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
            first = sum(len(set(new["accepted"][loc]) - set(old["accepted"][loc])) for loc in LOCALES)
            corrected = sum(sum(new["accepted"][loc][key] != value
                                for key, value in old["accepted"][loc].items()) for loc in LOCALES)
            manifests = {header["source_revision"]: header["source_manifest_sha256"]
                         for batch in new["batches"][len(old["batches"]):]
                         for header in batch["official_receipt_headers_by_locale"].values()}
            change = {"ui_by_locale": {locale: 0 for locale in LOCALES}, "receipts": 0,
                      "batches": 0, "first_receipts": first, "corrections": corrected,
                      "correction_batches": len(new["batches"]) - len(old["batches"]),
                      "source_manifests": manifests, "pr31_intake_comparison": True}
            result.append((commit, before, after, change, _receipt_comparison))
        return tuple(result)


def __getattr__(name):
    if name in {"HISTORICAL_JSON_LEAVES", "LIVE_EVENT_IDS"}:
        with fresh_validation_proof() as proof:
            if name == "HISTORICAL_JSON_LEAVES":
                result = dict(previous.HISTORICAL_JSON_LEAVES)
                for path in HISTORY_CONTENT_PATHS:
                    result[path] = tuple(dict.fromkeys((*result.get(path, ()), *proof["changes"][path])))
                return result
            result = dict(previous.LIVE_EVENT_IDS)
            for path in HISTORY_CONTENT_PATHS:
                result[path] = frozenset(result.get(path, ())) | frozenset(eid for eid, _ in proof["changes"][path])
            return result
    return getattr(previous, name)


def source_errors(raw, relative):
    if relative not in CONTENT_PATHS:
        return previous.source_errors(raw, relative)
    try:
        with fresh_validation_proof() as proof:
            _require(isinstance(raw, bytes) and raw == proof["current"][relative], "current content differs: " + relative)
        return []
    except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
        return [str(exc)]


def project_bytes(raw, relative):
    if relative not in HISTORY_CONTENT_PATHS:
        return previous.project_bytes(raw, relative)
    with fresh_validation_proof() as proof:
        # Projection is comparison-only and idempotent. Current admission is
        # source_errors(); an unknown/mutated image must never get this inverse.
        compared = proof["before"][relative] if raw == proof["current"][relative] else raw
        return previous.project_bytes(compared, relative)


def project_payload(payload, relative):
    if relative not in HISTORY_CONTENT_PATHS:
        return previous.project_payload(payload, relative)
    with fresh_validation_proof() as proof:
        old, current = _rows(proof["before"][relative]), _rows(proof["current"][relative])
        projected = copy.deepcopy(payload)
        if not isinstance(projected, list):
            return previous.project_payload(projected, relative)
        for index, row in enumerate(projected):
            eid = row.get("id") if isinstance(row, dict) else None
            if eid in current and current[eid] != old[eid] and _ordered(row) == _ordered(current[eid]):
                projected[index] = copy.deepcopy(old[eid])
        return previous.project_payload(projected, relative)


def project_byte_hash(observed, relative):
    if relative not in HISTORY_CONTENT_PATHS:
        return previous.project_byte_hash(observed, relative)
    with fresh_validation_proof() as proof:
        if observed == _sha(proof["current"][relative]):
            return _sha(previous.project_bytes(proof["before"][relative], relative))
        return previous.project_byte_hash(observed, relative)


def historical_blobs(relative):
    if relative not in HISTORY_CONTENT_PATHS:
        return previous.historical_blobs(relative)
    with fresh_validation_proof() as proof:
        return previous.project_bytes(proof["before"][relative], relative), proof["current"][relative]


def verified_blobs(relative):
    if relative not in CONTENT_PATHS:
        return previous.verified_blobs(relative)
    with fresh_validation_proof() as proof:
        return proof["before"][relative], proof["current"][relative]


def source_observation_errors(raw, payload, relative):
    errors = source_errors(raw, relative)
    try:
        _require(_ordered(_loads(raw)) == _ordered(payload), "payload differs from observed raw: " + relative)
    except (ValueError, TypeError, UnicodeError) as exc:
        errors.append(str(exc))
    return errors


def observed_byte_hash(relative, observed, raw):
    errors = source_errors(raw, relative)
    if not isinstance(raw, bytes) or _sha(raw) != observed:
        errors.append("PR31 intake: observed hash differs from raw: " + relative)
    return (observed, errors) if errors else (project_byte_hash(observed, relative), [])
