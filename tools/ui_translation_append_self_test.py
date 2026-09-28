#!/usr/bin/env python3
"""Bounded current UI append regressions, separate from the original 365 corpus."""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from dataclasses import replace
from pathlib import Path
from unittest import mock

import ui_translation_append as append

ROOT = Path(__file__).resolve().parents[1]
HISTORICAL_COMMIT = "2842b3fa2f3f16de41f5e6e96f55cc53c482beb0"
HISTORICAL_HELPER_SHA256 = "289453b77a80ac0c9922fad4e8968d3b79cfbe26466991bd377b48a20a1f6891"


def _raw(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode()


def synthetic_self_test() -> tuple[list[str], int]:
    """Only temporary Git repositories and synthetic UI/receipt dictionaries."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)

    def git(root, *args):
        env = {**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
               "GIT_AUTHOR_NAME": "isolated fixture", "GIT_AUTHOR_EMAIL": "fixture@example.invalid",
               "GIT_COMMITTER_NAME": "isolated fixture", "GIT_COMMITTER_EMAIL": "fixture@example.invalid"}
        for name in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
            env.pop(name, None)
        result = subprocess.run(("git", *args), cwd=root, env=env, capture_output=True, timeout=30)
        if result.returncode:
            raise RuntimeError(result.stderr.decode())
        return result.stdout.decode().strip()

    def write(root, snapshot):
        for path, raw in snapshot.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)

    def commit(root, snapshot, message):
        write(root, snapshot)
        git(root, "add", ".")
        git(root, "commit", "-qm", message)
        return git(root, "rev-parse", "HEAD")

    with tempfile.TemporaryDirectory(prefix="ui-append-synthetic-") as directory:
        root = Path(directory)
        git(root, "init", "-q")
        import ja_translation_pipeline as ja
        from third_party_notice_ui import SOURCE_PATHS
        required = {"content/endings.json", "content/meta/event_lifecycle.json",
                    "content/meta/demo_localization_scope.json", "playtests/order124/StoryChoiceM1M6Playtest.gd",
                    *SOURCE_PATHS, *(v[0] for v in ja.CATALOG_SOURCES.values())}
        write(root, {p: b"{}\n" if p.endswith(".json") else b"# synthetic source\n" for p in required})
        leaves = [append.exchange.Leaf("ui", f"검사 문구 {i}", "runtime:static_ui", (f"검사 문구 {i}",),
                                       f"검사 문구 {i}", "ui_static_context") for i in range(94)]
        leaves.sort(key=lambda leaf: leaf.id)
        old_receipt = {"source_sha256": "1" * 64, "target_sha256": "2" * 64}
        accepted = {loc: {"ui:old:/old": old_receipt} for loc in ("ja", *append.LOCALES)}
        ledger = {"schema_version": 1, "native_review": "OPEN", "accepted": accepted,
                  "accepted_sha256": append.exchange.digest(accepted), "batches": [{"order": "immutable base"}]}
        before = {p: _raw({"old": "原文"}) for p in append.UI_PATHS}
        before[append.LEDGER_PATH] = _raw(ledger)
        baseline = commit(root, before, "baseline")
        manifest = append._source_manifest(root, baseline)
        inventory = {"leaves": leaves, "source_manifest_sha256": manifest}
        after_values = {p: append.exchange.loads(raw.decode()) for p, raw in before.items()}
        current = after_values[append.LEDGER_PATH]
        headers, hashes = {}, {}
        for locale, path in zip(append.LOCALES, append.UI_PATHS):
            rows = {}
            for leaf in leaves:
                text = ("测试文字 " if locale == "zh-CN" else "測試文字 ") + leaf.source.rsplit(" ", 1)[1]
                after_values[path][leaf.owner] = text
                rows[leaf.id] = {"source_sha256": leaf.source_sha256,
                                 "target_sha256": append.exchange.digest(text)}
            current["accepted"][locale].update(rows)
            header = append.exchange.make_batch(inventory, locale, leaves, baseline, {}, {})[0]
            headers[locale] = header
            hashes[locale] = append.exchange.digest({"batch": header, "state": "accepted_machine_validated",
                                                       "native_review": "OPEN", "translations": rows})
        current["accepted_sha256"] = append.exchange.digest(current["accepted"])
        current["batches"].append({"order": "synthetic", "group": "ui", "roots": [leaf.owner for leaf in leaves],
                                   "source_leaves": 94, "target_leaves_by_locale": {"ja": 0, "zh-CN": 94, "zh-TW": 94},
                                   "machine_validation": "PASS", "native_review": "OPEN",
                                   "receipt_sha256_by_locale": hashes, append.HEADERS_FIELD: headers})
        after = {p: _raw(v) for p, v in after_values.items()}
        check(append.validate_append(before, before, inventory)["receipts"] == 0, "unchanged baseline")
        result = append.validate_append(before, after, inventory)
        check(result["receipts"] == 188 and result["batches"] == 1
              and result["ui_by_locale"] == {"zh-CN": 94, "zh-TW": 94}, "94 by two legal append")
        one = {p: append.exchange.loads(raw.decode()) for p, raw in before.items()}
        one_ledger = one[append.LEDGER_PATH]
        one_batch = copy.deepcopy(current["batches"][-1])
        one_batch.update(roots=[leaves[0].owner], source_leaves=1,
                         target_leaves_by_locale={"ja": 0, "zh-CN": 1, "zh-TW": 1})
        for locale, path in zip(append.LOCALES, append.UI_PATHS):
            one[path][leaves[0].owner] = after_values[path][leaves[0].owner]
            rows = {leaves[0].id: current["accepted"][locale][leaves[0].id]}
            one_ledger["accepted"][locale].update(rows)
            header = append.exchange.make_batch(inventory, locale, leaves[:1], baseline, {}, {})[0]
            one_batch[append.HEADERS_FIELD][locale] = header
            one_batch["receipt_sha256_by_locale"][locale] = append.exchange.digest({
                "batch": header, "state": "accepted_machine_validated", "native_review": "OPEN", "translations": rows})
        one_ledger["accepted_sha256"] = append.exchange.digest(one_ledger["accepted"])
        one_ledger["batches"].append(one_batch)
        check(append.validate_append(before, {p: _raw(v) for p, v in one.items()}, inventory)["receipts"] == 2,
              "single-key append preserves JSON integer types")
        boolean = copy.deepcopy(one)
        boolean[append.LEDGER_PATH]["batches"][-1]["source_leaves"] = True
        reject(lambda: append.validate_append(before, {p: _raw(v) for p, v in boolean.items()}, inventory), "boolean source count")
        for locale in append.LOCALES:
            boolean = copy.deepcopy(one)
            batch = boolean[append.LEDGER_PATH]["batches"][-1]
            header = batch[append.HEADERS_FIELD][locale]
            header["count"] = True
            batch["receipt_sha256_by_locale"][locale] = append.exchange.digest({
                "batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                "translations": {leaves[0].id: current["accepted"][locale][leaves[0].id]}})
            reject(lambda: append.validate_append(before, {p: _raw(v) for p, v in boolean.items()}, inventory),
                   "boolean official header count with recomputed digest " + locale)
        for path in append.PATHS:
            check(append._raw_inverse(before[path], after[path], path) is None, "exact inverse " + path)
            reject(lambda p=path: append.validate_append(before, {**after, p: after[p] + b"\n"}, inventory),
                   "neighbor whitespace " + path)
            reject(lambda p=path: append.validate_append(before, {**after, p: before[p]}, inventory),
                   "mixed rollback " + path)
        for locale, path in zip(append.LOCALES, append.UI_PATHS):
            key = leaves[0].owner
            for label, change in (
                ("old value", lambda x: x.update(old="改变")),
                ("old removal", lambda x: x.pop("old")),
                ("new removal", lambda x: x.pop(key)),
                ("extra key", lambda x: x.update(unknown="不明")),
                ("changed target", lambda x: x.update({key: "改变"})),
                ("blank", lambda x: x.update({key: ""})),
                ("nontext", lambda x: x.update({key: None})),
            ):
                value = copy.deepcopy(after_values[path])
                change(value)
                reject(lambda v=value, p=path: append.validate_append(before, {**after, p: _raw(v)}, inventory),
                       locale + " " + label)
            reversed_ui = dict(reversed(list(after_values[path].items())))
            reject(lambda: append.validate_append(before, {**after, path: _raw(reversed_ui)}, inventory),
                   locale + " reordered UI")
            duplicate = after[path].replace(b'"old":', b'"old":"duplicate",\n  "old":', 1)
            reject(lambda: append.validate_append(before, {**after, path: duplicate}, inventory), locale + " duplicate raw key")
        first_id = leaves[0].id
        for label, change in (
            ("old metadata", lambda v: v.update(native_review="GO")),
            ("old batch", lambda v: v["batches"][0].update(order="forged")),
            ("old receipt", lambda v: v["accepted"]["zh-CN"]["ui:old:/old"].update(source_sha256="0" * 64)),
            ("source hash", lambda v: v["accepted"]["zh-CN"][first_id].update(source_sha256="0" * 64)),
            ("target hash", lambda v: v["accepted"]["zh-CN"][first_id].update(target_sha256="0" * 64)),
            ("missing receipt", lambda v: v["accepted"]["zh-CN"].pop(first_id)),
            ("orphan receipt", lambda v: v["accepted"]["zh-CN"].update(orphan={})),
            ("JA receipt", lambda v: v["accepted"]["ja"].update(orphan={})),
            ("locale", lambda v: v["accepted"].update(fr={})),
            ("missing batch", lambda v: v["batches"].pop()),
            ("duplicate batch", lambda v: v["batches"].append(copy.deepcopy(v["batches"][-1]))),
            ("native claim", lambda v: v["batches"][-1].update(native_review="GO")),
            ("missing header", lambda v: v["batches"][-1].pop(append.HEADERS_FIELD)),
            ("count", lambda v: v["batches"][-1].update(source_leaves=95)),
            ("roots duplicate", lambda v: v["batches"][-1]["roots"].append(v["batches"][-1]["roots"][0])),
            ("digest", lambda v: v["batches"][-1]["receipt_sha256_by_locale"].update({"zh-CN": "0" * 64})),
            ("header selection", lambda v: v["batches"][-1][append.HEADERS_FIELD]["zh-CN"].update(selection_sha256="0" * 64)),
            ("header language", lambda v: v["batches"][-1][append.HEADERS_FIELD]["zh-CN"].update(source_language="en")),
        ):
            value = copy.deepcopy(current)
            change(value)
            value["accepted_sha256"] = append.exchange.digest(value["accepted"])
            reject(lambda v=value: append.validate_append(before, {**after, append.LEDGER_PATH: _raw(v)}, inventory), label)
        for field, value in (("protected", True), ("runtime_support", "unverified_consumer"),
                             ("source", "바뀐 원문"), ("source_path", "runtime:other")):
            altered = [replace(leaves[0], **{field: value}), *leaves[1:]]
            reject(lambda: append.validate_append(before, after, {**inventory, "leaves": altered}), "source " + field)
        reject(lambda: append.validate_append(before, after, {**inventory, "leaves": leaves + [leaves[0]]}), "duplicate source")
        for raw in (b'{"a":NaN}', b'{"a":Infinity}', b'{"a":1e999}'):
            reject(lambda r=raw: append.validate_append(before, {**after, append.UI_PATHS[0]: r}, inventory), "nonfinite JSON")
        successor = commit(root, after, "atomic UI and receipts")
        evidence = append.validate_history(root, baseline, before, after, inventory)
        check(evidence["head"] == successor and len(evidence["transitions"]) == 1, "actual first-parent Git append")
        reject(lambda: append.validate_history(root, baseline, before, after,
                                               {**inventory, "source_manifest_sha256": "0" * 64}),
               "current source census differs from authentic historical header")
        reject(lambda: append.validate_history(root, baseline, before, before, inventory), "old submitted candidate rollback")
        for path in append.PATHS:
            reject(lambda p=path: append.validate_history(root, baseline, before, {**after, p: before[p]}, inventory),
                   "Git/raw mixed candidate " + path)
        # Portable checkout proof: no private accepted.json and no source cache.
        clone = root / "portable"
        git(root, "clone", "-q", "--no-hardlinks", str(root), str(clone))
        check(append.validate_history(clone, baseline, before, after, inventory)["receipts"] == 188,
              "portable checkout without private receipts")
        # Restore commits are deliberate negative fixtures, not resets of user data.
        commit(clone, before, "committed full rollback")
        reject(lambda: append.validate_history(clone, baseline, before, before, inventory), "committed whole rollback")
        commit(clone, after, "restored after rollback")
        reject(lambda: append.validate_history(clone, baseline, before, after, inventory), "rollback then restoration remains rejected")
        partial = {**after, append.UI_PATHS[0]: before[append.UI_PATHS[0]]}
        commit(root, partial, "committed partial rollback")
        reject(lambda: append.validate_history(root, baseline, before, partial, inventory), "committed partial rollback")
        # A separate branch starts at the actual good candidate to isolate forgeries.
        git(root, "checkout", "-qb", "forgery", successor)
        forged = copy.deepcopy(current)
        batch = forged["batches"][-1]
        for locale in append.LOCALES:
            h = append.exchange.make_batch({**inventory, "source_manifest_sha256": "0" * 64},
                                            locale, leaves, baseline, {}, {})[0]
            batch[append.HEADERS_FIELD][locale] = h
            batch["receipt_sha256_by_locale"][locale] = append.exchange.digest({
                "batch": h, "state": "accepted_machine_validated", "native_review": "OPEN",
                "translations": {leaf.id: forged["accepted"][locale][leaf.id] for leaf in leaves}})
        # This deliberately self-consistent receipt can only be rejected by the
        # independently reconstructed Git source manifest, not its own checksums.
        forged_after = {**after, append.LEDGER_PATH: _raw(forged)}
        check(append.validate_append(before, forged_after, inventory)["receipts"] == 188, "forgery reaches external source proof")
        # Commit from baseline so old-batch preservation does not mask this test.
        git(root, "checkout", "-qb", "forged-source", baseline)
        commit(root, forged_after, "coordinated manifest header and digest forgery")
        reject(lambda: append.validate_history(root, baseline, before, forged_after, inventory), "coordinated source manifest forgery")
        reject(lambda: append.validate_history(root, baseline, before, forged_after,
                                               {**inventory, "source_manifest_sha256": "0" * 64}),
               "coordinated header and supplied inventory still fail actual Git source proof")
        git(root, "checkout", "-q", "forgery")
        real_git = append._git
        with mock.patch.object(append, "_git", side_effect=OSError("Git disappeared after success")):
            reject(lambda: append.validate_history(root, baseline, before, after, inventory), "fresh proof unavailable after success")
        def altered_git(where, *args, **kwargs):
            raw = real_git(where, *args, **kwargs)
            return raw + b"forged" if args[:2] == ("cat-file", "--batch") else raw
        with mock.patch.object(append, "_git", side_effect=altered_git):
            reject(lambda: append.validate_history(root, baseline, before, after, inventory), "forged object stream after success")
        check(append.validate_history(root, baseline, before, after, inventory)["receipts"] == 188, "fresh valid proof restored")
    return failures, cases


def current_self_test() -> tuple[list[str], int]:
    """Actual current46 admission and submitted-raw/payload mutations, no files changed."""
    import order365_ui_receipt_compat as boundary
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)
    snapshot = {p: (ROOT / p).read_bytes() for p in boundary.LIVE_PATHS}
    with boundary.fresh_validation_proof():
        check(not boundary.snapshot_errors(snapshot), "actual current46")
        state = boundary._ACTIVE_CURRENT.get()
        for path in append.PATHS:
            raw = snapshot[path]
            check(not boundary.source_errors(raw, path), "actual raw " + path)
            check(boundary.observed_byte_hash(path, hashlib.sha256(raw).hexdigest(), raw)
                  == (hashlib.sha256(raw).hexdigest(), []), "current identity not projected " + path)
            check(not boundary.source_observation_errors(raw, append.exchange.loads(raw.decode()), path), "current payload " + path)
            check(bool(boundary.source_errors(raw + b"\n", path)), "raw whitespace " + path)
            check(bool(boundary.source_observation_errors(raw, {}, path)), "unbound payload " + path)
            check(bool(boundary.observed_byte_hash(path, "0" * 64, raw)[1]), "unbound observed hash " + path)
            old = boundary._ACTIVE_PROOF.get()[path][1]
            if raw != old:
                check(bool(boundary.source_errors(old, path)), "pre-append raw rollback " + path)
        for path in boundary.LIVE_PATHS:
            check(bool(boundary.snapshot_errors({**snapshot, path: snapshot[path] + b"\n"})), "whole46 submitted neighbor " + path)
        with boundary.fresh_validation_proof():
            check(boundary._ACTIVE_CURRENT.get() is state, "same invocation proof reuse")
    check(boundary._ACTIVE_CURRENT.get() is None, "current proof context cleanup")
    with mock.patch.object(append, "_git", side_effect=OSError("Git unavailable")):
        check(bool(boundary.current_source_errors()), "later call must not reuse success")
    check(boundary._ACTIVE_CURRENT.get() is None, "failed current proof context cleanup")
    return failures, cases


def historical_self_test() -> dict:
    """Unchanged 240+12+60 CLI on a sealed pre-375 source tree, never current PASS."""
    source = append._git(ROOT, "rev-parse", HISTORICAL_COMMIT + "^{commit}").decode().strip()
    append.require(source == HISTORICAL_COMMIT, "historical corpus commit identity")
    entries = []
    suffixes = {".py", ".json", ".gd", ".tscn", ".tres", ".md", ".txt", ".sh", ".godot", ".cfg", ".csv", ".toml", ".yml", ".yaml"}
    for entry in append._git(ROOT, "ls-tree", "-r", "-z", source).split(b"\0"):
        if not entry:
            continue
        meta, path = entry.split(b"\t", 1)
        mode, kind, oid = meta.decode().split()
        name = path.decode()
        if kind == "blob" and Path(name).suffix in suffixes:
            append.require(mode in {"100644", "100755"}, "historical fixture contains nonregular source")
            entries.append((name, oid))
    blobs = dict(zip((p for p, _ in entries), append._objects(ROOT, [(source + ":" + p, oid, "blob") for p, oid in entries])))
    helper = "tools/order365_ui_receipt_compat.py"
    append.require(hashlib.sha256(blobs[helper]).hexdigest() == HISTORICAL_HELPER_SHA256, "historical helper identity")
    modules = {p: hashlib.sha256(raw).hexdigest() for p, raw in blobs.items() if p.startswith("tools/") and p.endswith(".py")}
    git_dir = append._git(ROOT, "rev-parse", "--absolute-git-dir").decode().strip()
    with tempfile.TemporaryDirectory(prefix="ui-append-original365-") as directory:
        root = Path(directory)
        for path, raw in blobs.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        runner = '''
import hashlib, importlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1]).resolve()
hashes = json.loads(sys.argv[2])
sys.path.insert(0, str(root / 'tools'))
module = importlib.import_module('order365_ui_receipt_compat')
if module.ROOT != root:
    raise RuntimeError('historical ROOT mismatch')
sys.argv = [str(root / 'tools/order365_ui_receipt_compat.py'), '--self-test']
code = module.main()
identity = {}
for name, imported in tuple(sys.modules.items()):
    file = getattr(imported, '__file__', None)
    if not file:
        continue
    path = pathlib.Path(file).resolve()
    if path.parent.name != 'tools':
        continue
    relative = 'tools/' + path.name
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if path != root / relative or digest != hashes.get(relative):
        raise RuntimeError('historical imported module identity: ' + name)
    declared_root = getattr(imported, 'ROOT', root)
    if pathlib.Path(declared_root).resolve() != root:
        raise RuntimeError('historical imported ROOT: ' + name)
    identity[relative] = {'sha256': digest, 'file': str(path), 'root': str(declared_root)}
print('UI_APPEND_HISTORICAL_IDENTITY ' + json.dumps(identity, sort_keys=True))
raise SystemExit(code)
'''
        env = {**os.environ, "GIT_DIR": git_dir, "GIT_WORK_TREE": str(root), "GIT_OPTIONAL_LOCKS": "0",
               "PYTHONDONTWRITEBYTECODE": "1"}
        command = (sys.executable, "-I", "-B", "-c", runner, str(root), json.dumps(modules))
        process = subprocess.run(command, cwd=root, env=env, capture_output=True, text=True, timeout=600)
        marker = ("ORDER365_UI_RECEIPT_OK current_files=3 ui_keys=44 new_receipts=44 batches=1 accepted=40346 "
                  "batch_total=143 live_files=46 historical_files=17 historical_leaves=107 cases=312")
        errors = []
        if process.returncode or marker not in process.stdout.splitlines() or process.stderr.strip():
            errors.append("original isolated365 312-case CLI failed")
        if not any(line.startswith("UI_APPEND_HISTORICAL_IDENTITY ") for line in process.stdout.splitlines()):
            errors.append("historical imported identity evidence missing")
        for path, raw in blobs.items():
            if (root / path).read_bytes() != raw:
                errors.append("historical source mutated " + path)
        return {"meaning": "historical pre375 fixture only, not current admission", "source_revision": source,
                "helper_sha256": HISTORICAL_HELPER_SHA256, "fixture_files": len(blobs), "modules": modules,
                "returncode": process.returncode, "stdout": process.stdout, "stderr": process.stderr,
                "cases": 312 if not errors else 0, "errors": errors}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--synthetic-only", action="store_true", help="author development only; not current acceptance")
    args = parser.parse_args()
    errors, cases = synthetic_self_test()
    print(f"UI_TRANSLATION_APPEND_SYNTHETIC cases={cases}")
    if not args.synthetic_only:
        current_errors, current_cases = current_self_test()
        errors.extend(current_errors)
        cases += current_cases
        print(f"UI_TRANSLATION_APPEND_CURRENT cases={current_cases}")
    for error in errors:
        print("UI_TRANSLATION_APPEND_ERROR " + error)
    marker = "UI_TRANSLATION_APPEND_SYNTHETIC" if args.synthetic_only else "UI_TRANSLATION_APPEND_SELF_TEST"
    print(f"{marker}_{'FAIL' if errors else 'OK'} cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
