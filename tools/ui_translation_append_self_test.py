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


def aruba_font_self_test() -> tuple[list[str], int]:
    """Current font/manifest comparison boundaries; no runtime or receipt writes."""
    import order365_ui_receipt_compat as boundary
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("Aruba font: " + label)
    def rejected(action, label):
        try:
            action()
        except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    path = append.ARUBA_FONT_PATH
    raw = (ROOT / path).read_bytes()
    observed = hashlib.sha256(raw).hexdigest()
    before = append.aruba_font_predecessor(ROOT, raw)
    old_hash = hashlib.sha256(before).hexdigest()
    check(old_hash == append.ARUBA_FONT_BEFORE_SHA256, "exact three-line full raw inverse")
    with boundary.fresh_validation_proof():
        state = boundary._ACTIVE_CURRENT.get()
        inventory = {key: copy.deepcopy(state[key]) for key in ("source_hashes", "source_manifest_sha256")}
        unchanged = copy.deepcopy(inventory)
        old_manifest = append._source_manifest(ROOT, append.ARUBA_FONT_BEFORE_COMMIT)
        check(append._source_manifest_matches(ROOT, inventory, inventory["source_manifest_sha256"]),
              "actual current manifest is retained")
        check(append._source_manifest_matches(ROOT, inventory, old_manifest), "old manifest comparison only after exact proof")
        check(inventory == unchanged and inventory["source_hashes"][path] == observed, "actual source census was not projected")
        check(boundary.runtime_observed_hash(path, observed, raw, current_admitted=True) == (old_hash, []),
              "Chapter1 comparison uses old pin with current raw")
        claim, errors = boundary.runtime_observed_hash(path, "0" * 64, raw, current_admitted=True)
        check(claim == "0" * 64 and bool(errors), "unbound observed claim")
        check(boundary.runtime_observed_hash("outside/" + path, observed, raw, current_admitted=True) == (observed, []),
              "other path has zero projection")
        with mock.patch.object(append, "_git", wraps=append._git) as git:
            claim, errors = boundary.runtime_observed_hash(path, observed, raw, current_admitted=False)
            check(claim == observed and bool(errors) and not git.called, "admission failure before any Git projection")
        for label, mutant in (("old raw rollback", before), ("whitespace", raw + b"\n"),
                              ("neighbor", raw.replace(b"\t_rng.randomize()", b"\t_rng.randomize() # changed", 1))):
            rejected(lambda value=mutant: append.aruba_font_predecessor(ROOT, value), label)
        for index, line in enumerate(append.ARUBA_FONT_ADDITION.splitlines(keepends=True)):
            rejected(lambda part=line: append.aruba_font_predecessor(ROOT, raw.replace(part, b"", 1)),
                     "font line removed " + str(index))
        altered = copy.deepcopy(inventory)
        neighbor = next(key for key in altered["source_hashes"] if key != path)
        altered["source_hashes"][neighbor] = "0" * 64
        altered["source_manifest_sha256"] = append.exchange.digest(altered["source_hashes"])
        check(not append._source_manifest_matches(ROOT, altered, old_manifest), "other source is not exempted")
        altered = copy.deepcopy(inventory)
        altered["source_hashes"][path] = old_hash
        altered["source_manifest_sha256"] = append.exchange.digest(altered["source_hashes"])
        rejected(lambda: append._source_manifest_matches(ROOT, altered, "0" * 64), "source map claim must bind actual raw")
        snapshot = {p: (ROOT / p).read_bytes() for p in boundary.LIVE_PATHS}
        old_sources = append._snapshot(ROOT, append.ARUBA_FONT_AFTER_COMMIT)
        check(bool(boundary.snapshot_errors({**snapshot, append.LEDGER_PATH: old_sources[append.LEDGER_PATH]})),
              "new current dictionaries with pre376 ledger rollback")
        # Even an old manifest matching old receipts must not admit a rollback
        # of the actual runtime. The production entry checks this before collect.
        read_bytes = Path.read_bytes
        def old_runtime(file):
            return before if file.resolve() == ROOT / path else read_bytes(file)
        with mock.patch.object(Path, "read_bytes", old_runtime), \
                mock.patch.object(append.exchange, "collect", wraps=append.exchange.collect) as collector:
            try:
                append.current_proof(ROOT, boundary.AFTER_COMMIT,
                                     {p: boundary._ACTIVE_PROOF.get()[p][1] for p in append.PATHS})
            except ValueError:
                check(not collector.called, "runtime rollback rejected before collector/manifest shortcut")
            else:
                check(False, "runtime rollback rejected before collector/manifest shortcut")
        real_git = append._git
        with mock.patch.object(append, "_git", side_effect=OSError("Git unavailable after successful proof")):
            claim, errors = boundary.runtime_observed_hash(path, observed, raw, current_admitted=True)
            check(claim == observed and bool(errors), "fresh missing proof after previous success")
        def forged_git(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return value + b"forged" if args[:2] == ("cat-file", "--batch") else value
        with mock.patch.object(append, "_git", side_effect=forged_git):
            claim, errors = boundary.runtime_observed_hash(path, observed, raw, current_admitted=True)
            check(claim == observed and bool(errors), "forged immutable object stream")
        def wrong_population(where, *args, **kwargs):
            return b"M\0outside.gd\0" if args and args[0] == "diff" else real_git(where, *args, **kwargs)
        with mock.patch.object(append, "_git", side_effect=wrong_population):
            rejected(lambda: append.aruba_font_predecessor(ROOT, raw), "wrong exact transition population")
        def rolled_back_head(where, *args, **kwargs):
            if args == ("rev-parse", "HEAD:" + path):
                return (append.ARUBA_FONT_BEFORE_BLOB + "\n").encode()
            return real_git(where, *args, **kwargs)
        with mock.patch.object(append, "_git", side_effect=rolled_back_head):
            rejected(lambda: append.aruba_font_predecessor(ROOT, raw), "Git candidate rollback despite supplied current bytes")
        check(boundary.runtime_observed_hash(path, observed, raw, current_admitted=True) == (old_hash, []),
              "fresh valid proof after failed invocations")
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


def three_locales_self_test() -> tuple[list[str], int]:
    """New JA boundary, unchanged CN/TW mode, and actual47; no old suite run."""
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
    env = {**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
           "GIT_AUTHOR_NAME": "isolated fixture", "GIT_AUTHOR_EMAIL": "fixture@example.invalid",
           "GIT_COMMITTER_NAME": "isolated fixture", "GIT_COMMITTER_EMAIL": "fixture@example.invalid"}
    for key in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
        env.pop(key, None)
    with tempfile.TemporaryDirectory(prefix="ui-append-three-locales-") as directory:
        root = Path(directory)
        def git(*args):
            result = subprocess.run(("git", *args), cwd=root, env=env, capture_output=True, timeout=30)
            if result.returncode:
                raise RuntimeError(result.stderr.decode())
            return result.stdout.decode().strip()
        def write(snapshot):
            for path, raw in snapshot.items():
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
        def commit(snapshot):
            write(snapshot)
            git("add", ".")
            git("commit", "-qm", "bounded append fixture")
            return git("rev-parse", "HEAD")
        git("init", "-q")
        import ja_translation_pipeline as ja
        from third_party_notice_ui import SOURCE_PATHS
        required = {"content/endings.json", "content/meta/event_lifecycle.json",
                    "content/meta/demo_localization_scope.json", "playtests/order124/StoryChoiceM1M6Playtest.gd",
                    *SOURCE_PATHS, *(v[0] for v in ja.CATALOG_SOURCES.values())}
        write({p: b"{}\n" if p.endswith(".json") else b"# synthetic source\n" for p in required})
        keys = ("배달 루트 설정", "비 오는 저녁 배달")
        leaves = sorted([append.exchange.Leaf("ui", k, "runtime:static_ui", (k,), k, "ui_static_context")
                         for k in keys], key=lambda leaf: leaf.id)
        accepted = {loc: {"ui:old:/old": {"source_sha256": "1" * 64, "target_sha256": "2" * 64}}
                    for loc in append.CURRENT_LOCALES}
        ledger = {"schema_version": 1, "native_review": "OPEN", "accepted": accepted,
                  "accepted_sha256": append.exchange.digest(accepted), "batches": [{"order": "immutable"}]}
        before = {p: _raw({"old": "原文"}) for p in append.CURRENT_UI_PATHS}
        before[append.LEDGER_PATH] = _raw(ledger)
        baseline = commit(before)
        inventory = {"leaves": leaves, "source_manifest_sha256": append._source_manifest(root, baseline)}
        texts = {"ja": ("配達ルート設定", "雨の夕方の配達"),
                 "zh-CN": ("配送路线设置", "雨天傍晚配送"), "zh-TW": ("配送路線設定", "雨天傍晚配送")}
        def successor(locales):
            values = {p: append.exchange.loads(raw.decode()) for p, raw in before.items()}
            current, headers, hashes = values[append.LEDGER_PATH], {}, {}
            for locale in locales:
                rows = {}
                for leaf in leaves:
                    text = texts[locale][keys.index(leaf.owner)]
                    values[f"locale/ui_{locale}.json"][leaf.owner] = text
                    rows[leaf.id] = {"source_sha256": leaf.source_sha256, "target_sha256": append.exchange.digest(text)}
                current["accepted"][locale].update(rows)
                header = append.exchange.make_batch(inventory, locale, leaves, baseline, {}, {})[0]
                headers[locale] = header
                hashes[locale] = append.exchange.digest({"batch": header, "state": "accepted_machine_validated",
                                                        "native_review": "OPEN", "translations": rows})
            current["accepted_sha256"] = append.exchange.digest(current["accepted"])
            current["batches"].append({"order": "three-locale-fixture", "group": "ui", "roots": list(keys),
                "source_leaves": 2, "target_leaves_by_locale": {loc: 2 if loc in locales else 0 for loc in append.CURRENT_LOCALES},
                "machine_validation": "PASS", "native_review": "OPEN", "receipt_sha256_by_locale": hashes,
                append.HEADERS_FIELD: headers})
            return {p: _raw(v) for p, v in values.items()}
        after = successor(append.CURRENT_LOCALES)
        check(append.validate_append(before, before, inventory)["receipts"] == 0, "unchanged4")
        check(append.validate_append(before, after, inventory)["receipts"] == 6, "three locales6")
        check(append.validate_append(before, successor(("ja",)), inventory)["receipts"] == 2, "JA-only2")
        cn_after = successor(append.LOCALES)
        check(append.validate_append(before, cn_after, inventory)["receipts"] == 4, "Chinese-only with observed JA")
        check(append.validate_append({p: before[p] for p in append.PATHS}, {p: cn_after[p] for p in append.PATHS}, inventory)["receipts"] == 4,
              "unchanged historical3 interface")
        for path in append.CURRENT_PATHS:
            reject(lambda p=path: append.validate_append(before, {**after, p: before[p]}, inventory), "mixed rollback " + path)
            reject(lambda p=path: append.validate_append(before, {**after, p: after[p] + b"\n"}, inventory), "raw neighbor " + path)
        ja_path = "locale/ui_ja.json"
        for text in (None, True, "", "changed old"):
            value = append.exchange.loads(after[ja_path].decode())
            value["old" if text == "changed old" else keys[0]] = text
            reject(lambda v=value: append.validate_append(before, {**after, ja_path: _raw(v)}, inventory), "JA nontext/old value " + repr(text))
        raw_duplicate = after[ja_path].replace(b'"old":', b'"old": "duplicate", "old":', 1)
        reject(lambda: append.validate_append(before, {**after, ja_path: raw_duplicate}, inventory), "raw duplicate JA")
        for label, mutate in (
            ("missing JA receipt", lambda v: v["accepted"]["ja"].pop(leaves[0].id)),
            ("JA source SHA", lambda v: v["accepted"]["ja"][leaves[0].id].update(source_sha256="0" * 64)),
            ("JA target SHA", lambda v: v["accepted"]["ja"][leaves[0].id].update(target_sha256="0" * 64)),
            ("JA count bool", lambda v: v["batches"][-1]["target_leaves_by_locale"].update(ja=True)),
            ("JA count null", lambda v: v["batches"][-1]["target_leaves_by_locale"].update(ja=None)),
            ("root count bool", lambda v: v["batches"][-1].update(source_leaves=True)),
            ("missing JA header", lambda v: v["batches"][-1][append.HEADERS_FIELD].pop("ja")),
            ("JA header locale", lambda v: v["batches"][-1][append.HEADERS_FIELD]["ja"].update(locale="zh-CN")),
            ("missing JA digest", lambda v: v["batches"][-1]["receipt_sha256_by_locale"].pop("ja")),
        ):
            value = append.exchange.loads(after[append.LEDGER_PATH].decode())
            mutate(value)
            value["accepted_sha256"] = append.exchange.digest(value["accepted"])
            reject(lambda v=value: append.validate_append(before, {**after, append.LEDGER_PATH: _raw(v)}, inventory), label)
        protected = {**inventory, "leaves": [replace(leaves[0], protected=True), leaves[1]]}
        reject(lambda: append.validate_append(before, after, protected), "protected key")
        value = append.exchange.loads(after["locale/ui_zh-CN.json"].decode())
        value["old"] = "changed neighbor"
        reject(lambda: append.validate_append(before, {**after, "locale/ui_zh-CN.json": _raw(value)}, inventory), "other locale old value")
        commit(after)
        check(append.validate_history(root, baseline, before, after, inventory)["receipts"] == 6, "committed4 append")
        reject(lambda: append.validate_history(root, baseline, before, before, inventory), "submitted complete rollback")
        with mock.patch.object(append, "_git", side_effect=OSError("Git lost")):
            reject(lambda: append.validate_history(root, baseline, before, after, inventory), "fresh Git loss after success")
        commit(before)
        reject(lambda: append.validate_history(root, baseline, before, before, inventory), "committed rollback")
        commit(after)
        reject(lambda: append.validate_history(root, baseline, before, after, inventory), "rollback then restoration")
    import order365_ui_receipt_compat as boundary
    snapshot = {p: (ROOT / p).read_bytes() for p in boundary.LIVE_PATHS}
    with boundary.fresh_validation_proof():
        state = boundary._ACTIVE_CURRENT.get()
        check(len(snapshot) == 47 and not boundary.snapshot_errors(snapshot), "actual47 current admission")
        check(set(state["raw"]) == set(append.CURRENT_PATHS), "actual4 current UI/ledger exposure")
        raw = snapshot["locale/ui_ja.json"]
        check(not boundary.source_errors(raw, "locale/ui_ja.json") and
              boundary.observed_byte_hash("locale/ui_ja.json", hashlib.sha256(raw).hexdigest(), raw)
              == (hashlib.sha256(raw).hexdigest(), []), "JA actual identity, no historical projection")
        for path in append.CURRENT_PATHS:
            check(bool(boundary.snapshot_errors({**snapshot, path: snapshot[path] + b"\n"})), "actual submitted mutation " + path)
        check(bool(boundary.source_observation_errors(raw, {}, "locale/ui_ja.json")), "unbound JA payload")
        baseline_raw = state["baseline_raw"]["locale/ui_ja.json"]
        if raw != baseline_raw:
            check(bool(boundary.source_errors(baseline_raw, "locale/ui_ja.json")), "actual JA baseline rollback")
    check(boundary._ACTIVE_CURRENT.get() is None, "current scope cleanup")
    return failures, cases


def correction_self_test() -> tuple[list[str], int]:
    """The exact 380 correction only; no collector, old corpus or consumer suite."""
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("correction: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    key = append.CORRECTION_KEY
    leaf = append.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
    # Explicit one-leaf fixture; the root's current normal separately invokes
    # the actual collector. Its manifest below is reconstructed from real Git.
    inventory = {"leaves": [leaf], "source_manifest_sha256": append._source_manifest(ROOT, append.CORRECTION_BEFORE_COMMIT)}
    before, after, change = append._correction_proof(ROOT, inventory)
    check(change["corrections"] == 2 and change["correction_batches"] == 1
          and change["receipts"] == change["batches"] == 0, "two corrections, zero new translations")
    check(append._correction_comparison(after, before, after) == before, "exact full raw inverse")
    original = {p: (ROOT / p).read_bytes() for p in append.CURRENT_PATHS}
    # Current files may already contain later valid appends. The exact fixed
    # transition is tested in the isolated Git checkout below, not as HEAD.
    reject(lambda: append.validate_append(before, after, inventory), "ordinary append still rejects the correction")
    for path in append.PATHS:
        reject(lambda p=path: append._validate_correction(before, {**after, p: before[p]}, inventory), "mixed rollback " + path)
        reject(lambda p=path: append._validate_correction(before, {**after, p: after[p] + b"\n"}, inventory), "raw whitespace " + path)
    reject(lambda: append._validate_correction(before, original, inventory), "extra path cannot expand correction scope")

    after_documents = {path: append._Document(raw) for path, raw in after.items()}
    def mutate(path, field, value):
        doc = after_documents[path]
        payload = copy.deepcopy(doc.value)
        target = payload
        for part in field[:-1]:
            target = target[part]
        target[field[-1]] = value
        start, end = doc.spans[field]
        edits = [(start, end, append._ordered(value).decode())]
        if path == append.LEDGER_PATH and field[0] == "accepted":
            start, end = doc.spans[("accepted_sha256",)]
            edits.append((start, end, append._ordered(append.exchange.digest(payload["accepted"])).decode()))
        text = doc.text
        for start, end, replacement in sorted(edits, reverse=True):
            text = text[:start] + replacement + text[end:]
        return {**after, path: text.encode()}

    ledger = append.LEDGER_PATH
    for path in append.UI_PATHS:
        for value in ("changed target", None):
            reject(lambda p=path, v=value: append._validate_correction(before, mutate(p, (key,), v), inventory),
                   "changed/nonstring exact target " + path + repr(value))
        other = next(k for k in after_documents[path].value if k != key)
        reject(lambda p=path, k=other: append._validate_correction(before, mutate(p, (k,), "neighbor"), inventory),
               "existing neighbor target " + path)
        quoted = json.dumps(key, ensure_ascii=False).encode() + b":"
        duplicate = after[path].replace(quoted, quoted + b' "duplicate", ' + quoted, 1)
        reject(lambda p=path, raw=duplicate: append._validate_correction(before, {**after, p: raw}, inventory),
               "duplicate raw target " + path)
    for label, field, value in (
        ("source receipt", ("accepted", "zh-CN", leaf.id, "source_sha256"), "0" * 64),
        ("target receipt with fresh checksum", ("accepted", "zh-TW", leaf.id, "target_sha256"), "0" * 64),
        ("old batch", ("batches", 0, "order"), "changed"),
        ("correction scope", ("batches", 148, "roots"), [key, "another key"]),
        ("boolean source count", ("batches", 148, "source_leaves"), True),
        ("null locale count", ("batches", 148, "target_leaves_by_locale", "zh-CN"), None),
        ("old target claim", ("batches", 148, "before_target_sha256_by_locale", "zh-CN"), "0" * 64),
        ("official digest", ("batches", 148, "receipt_sha256_by_locale", "zh-CN"), "0" * 64),
        ("official previous-target selection", ("batches", 148, append.HEADERS_FIELD, "zh-CN", "selection_sha256"), "0" * 64),
        ("boolean official count", ("batches", 148, append.HEADERS_FIELD, "zh-CN", "count"), True),
        ("native claim", ("batches", 148, "native_review"), "GO"),
    ):
        reject(lambda f=field, v=value: append._validate_correction(before, mutate(ledger, f, v), inventory), label)
    for field, value in (("source", "changed Korean"), ("protected", True), ("runtime_support", "unverified_consumer")):
        reject(lambda f=field, v=value: append._validate_correction(before, after,
                   {**inventory, "leaves": [replace(leaf, **{f: v})]}), "current leaf " + field)
    reject(lambda: append._validate_correction(before, after, {**inventory, "leaves": [leaf, leaf]}), "duplicate current leaf")
    doc = after_documents[ledger]
    field = ("accepted", "zh-CN", leaf.id, "target_sha256")
    start, end = doc.spans[field]
    token = doc.text[start:end]
    escaped = token[:1] + "\\u%04x" % ord(token[1]) + token[2:]
    mutant = {**after, ledger: (doc.text[:start] + escaped + doc.text[end:]).encode()}
    reject(lambda: append._correction_comparison(mutant, before, after), "same-value corrected target SHA raw escape")
    batches = doc.value["batches"]
    for label, rows in (("deleted correction batch", batches[:-1]),
                        ("duplicate correction batch", [*batches, batches[-1]]),
                        ("reordered correction batch", [*batches[:-2], batches[-1], batches[-2]])):
        reject(lambda v=rows: append._validate_correction(before, mutate(ledger, ("batches",), v), inventory), label)
    neighbor = next(k for k in doc.value["accepted"]["zh-CN"] if k != leaf.id)
    reject(lambda: append._validate_correction(before, mutate(ledger,
               ("accepted", "zh-CN", neighbor, "target_sha256"), "0" * 64), inventory), "old neighboring accepted receipt")
    real_git = append._git
    with mock.patch.object(append, "_git", side_effect=OSError("Git lost after success")):
        reject(lambda: append._correction_proof(ROOT, inventory), "fresh missing immutable proof")
    def forged(where, *args, **kwargs):
        raw = real_git(where, *args, **kwargs)
        return raw + b"forged" if args[:2] == ("cat-file", "--batch") else raw
    with mock.patch.object(append, "_git", side_effect=forged):
        reject(lambda: append._correction_proof(ROOT, inventory), "forged object stream")
    def wrong_paths(where, *args, **kwargs):
        return b"M\0outside.json\0" if args and args[0] == "diff" else real_git(where, *args, **kwargs)
    with mock.patch.object(append, "_git", side_effect=wrong_paths):
        reject(lambda: append._correction_proof(ROOT, inventory), "exact commit path population")
    check(append._correction_proof(ROOT, inventory)[2] == change, "fresh valid proof after failures")

    # A small shared-object clone materializes only the four UI/ledger files.
    # All source objects remain real and read-only in the original repository.
    env = {**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
           "GIT_AUTHOR_NAME": "correction fixture", "GIT_AUTHOR_EMAIL": "fixture@example.invalid",
           "GIT_COMMITTER_NAME": "correction fixture", "GIT_COMMITTER_EMAIL": "fixture@example.invalid"}
    for name in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
        env.pop(name, None)
    with tempfile.TemporaryDirectory(prefix="ui-correction-history-") as directory:
        root = Path(directory)
        def git(*args):
            result = subprocess.run(("git", *args), cwd=root, env=env, capture_output=True, timeout=30)
            if result.returncode:
                raise RuntimeError(result.stderr.decode())
        git("clone", "-q", "--shared", "--no-checkout", str(ROOT), str(root))
        git("update-ref", "HEAD", append.CORRECTION_AFTER_COMMIT)
        git("read-tree", append.CORRECTION_AFTER_COMMIT)
        check(append._snapshot(root, append.CORRECTION_AFTER_COMMIT, append.PATHS) == after,
              "isolated exact committed correction bytes")
        evidence = append.validate_history(root, append.CORRECTION_BEFORE_COMMIT, before, after, inventory)
        check(evidence["corrections"] == 2 and evidence["correction_batches"] == evidence["batches"] == 1
              and evidence["receipts"] == evidence["append_batches"] == 0, "isolated exact correction lineage")
        # Synthetic subsequent append, explicitly not a runtime-source claim.
        # It exercises the unchanged append validator after the exact inverse.
        extra = append.exchange.Leaf("ui", "합성 후속 문구", "runtime:static_ui", ("합성 후속 문구",),
                                     "합성 후속 문구", "ui_static_context")
        extended = {**inventory, "leaves": [leaf, extra]}
        future = dict(after)
        def insert_member(raw, field, member, value):
            document = append._Document(raw)
            members = document.value
            for part in field:
                members = members[part]
            last = len(members) - 1 if isinstance(members, list) else list(members)[-1]
            end = document.spans[(*field, last)][1]
            addition = ",\n    " + (append._ordered(member).decode() + ": " if member is not None else "") + append._ordered(value).decode()
            return (document.text[:end] + addition + document.text[end:]).encode()
        headers, hashes = {}, {}
        for locale, path in zip(append.LOCALES, append.UI_PATHS):
            text = "合成后续文字" if locale == "zh-CN" else "合成後續文字"
            future[path] = insert_member(future[path], (), extra.owner, text)
            row = {"source_sha256": extra.source_sha256, "target_sha256": append.exchange.digest(text)}
            future[ledger] = insert_member(future[ledger], ("accepted", locale), extra.id, row)
            header = append.exchange.make_batch(extended, locale, [extra], append.CORRECTION_AFTER_COMMIT, {}, {})[0]
            headers[locale] = header
            hashes[locale] = append.exchange.digest({"batch": header, "state": "accepted_machine_validated",
                                                     "native_review": "OPEN", "translations": {extra.id: row}})
        batch = {"order": "synthetic following append", "group": "ui", "roots": [extra.owner], "source_leaves": 1,
                 "target_leaves_by_locale": {"ja": 0, "zh-CN": 1, "zh-TW": 1}, "machine_validation": "PASS",
                 "native_review": "OPEN", append.HEADERS_FIELD: headers, "receipt_sha256_by_locale": hashes}
        future[ledger] = insert_member(future[ledger], ("batches",), None, batch)
        document = append._Document(future[ledger])
        start, end = document.spans[("accepted_sha256",)]
        digest = append._ordered(append.exchange.digest(document.value["accepted"])).decode()
        future[ledger] = (document.text[:start] + digest + document.text[end:]).encode()
        bad_ui = append._Document(future[append.UI_PATHS[0]])
        start, end = bad_ui.spans[(key,)]
        rollback = {**future, append.UI_PATHS[0]: (bad_ui.text[:start]
                    + append._ordered(append.CORRECTION_TEXTS["zh-CN"][0]).decode() + bad_ui.text[end:]).encode()}
        for label, snapshot in (("synthetic append after correction", future),
                                ("committed corrected-key rollback", rollback),
                                ("restoration cannot erase rollback", future)):
            for path, raw in snapshot.items():
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
            git("add", "--", *append.PATHS)
            git("commit", "-qm", label)
            if snapshot is future and label.startswith("synthetic"):
                result = append.validate_history(root, append.CORRECTION_BEFORE_COMMIT, before, snapshot, extended)
                check(result["receipts"] == 2 and result["corrections"] == 2 and result["batches"] == 2
                      and result["append_batches"] == result["correction_batches"] == 1, label)
            else:
                reject(lambda value=snapshot: append.validate_history(root, append.CORRECTION_BEFORE_COMMIT,
                                                                      before, value, extended), label)
    check(all((ROOT / p).read_bytes() == raw for p, raw in original.items()), "actual product bytes unchanged")
    return failures, cases


def main_modal_self_test() -> tuple[list[str], int]:
    """Only the three MainGame repairs, actual locations and manifest bridge."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("Main modal: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    path = history.MAIN_GAME_PATH
    paths = (path, "tools/main_game_locale_history.py", "tools/ja_translation_pipeline.py",
             "tools/ui_translation_append.py", "tools/ui_translation_append_self_test.py", *append.CURRENT_PATHS)
    original = {p: (ROOT / p).read_bytes() for p in paths}
    raw = original[path]
    sha = lambda value: hashlib.sha256(value).hexdigest()
    old = history.modal_font_predecessor(raw, ROOT)
    check(sha(old) == "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"
          and sha(raw) == "6c26e3db61c810cd52022128a459a7160abf49c6a0c3d085f196755f9e232f8d",
          "independent whole runtime pins")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                    ("_source_errors", "_project_bytes", "_project_byte_hash"))
        check(not source(path, raw), name + " current raw")
        check(project(raw, path) == previous[1](old, path), name + " complete prior chain")
        check(digest(sha(raw), path, raw) == sha(previous[1](old, path)), name + " observed hash bound")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " wrong claim stays unchanged")
        for label, mutant in (("rollback", old), ("space", raw + b"\n"),
                              ("neighbor", raw.replace(b"modal_header = HBoxContainer.new()", b"modal_header = VBoxContainer.new()", 1))):
            check(bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " reject " + label)
    for index, (a, b) in enumerate(history.MODAL_REPLACEMENTS):
        reject(lambda x=a, y=b: history.modal_font_predecessor(raw.replace(y.encode(), x.encode(), 1), ROOT),
               "partial repair " + str(index))
    check(history.main_game_history_project_bytes(b"outside", "unowned.gd") ==
          history._MODAL_OLD_PUBLIC[1](b"outside", "unowned.gd"), "off-path dispatch unchanged")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost Git after success")):
        check(bool(history.gift_caption_source_errors(path, raw))
              and history.main_game_history_project_bytes(raw, path) == raw, "fresh proof loss fails closed")
    real_git = history._modal_git
    def forged(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        return value + b"forged" if args[:2] == ("cat-file", "--batch") else value
    with mock.patch.object(history, "_modal_git", side_effect=forged):
        reject(lambda: history.modal_font_predecessor(raw, ROOT), "forged Git stream")
    with mock.patch.object(history, "MODAL_REPLACEMENTS", history.MODAL_REPLACEMENTS[:-1]):
        reject(lambda: history.modal_font_predecessor(raw, ROOT), "missing inverse")
    with mock.patch.object(history, "MODAL_BEFORE_COMMIT", history.MODAL_AFTER_COMMIT):
        reject(lambda: history.modal_font_predecessor(raw, ROOT), "forged parent")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restored without cache")

    code = original["tools/ja_translation_pipeline.py"]
    check(sha(ja.modal_pipeline_predecessor(code)) == "2b68f06da7108ce8a3f21b51fc6cf148ac1979a336bf76d425382e106e47af11",
          "collector original whole body exact")
    check(sha(ja.nonformat_pipeline_predecessor(code)) == ja.NONFORMAT_BEFORE_SHA,
          "direct old378 reader receives exact predecessor")
    check(sha(ja.current_demo_pipeline_predecessor(code)) == ja.CURRENT_DEMO_BEFORE_SHA,
          "direct notice reader receives exact predecessor")
    reject(lambda: ja.modal_pipeline_predecessor(code + b"\n"), "collector neighbor bytes")
    # Exactly one real current UI collection; no full corpus/receipt/old suite.
    inventory = ja.collect_ui_inventory()
    actual, parse_errors = ja.parse_ui_calls(path, raw.decode())
    prior, prior_errors = ja.parse_ui_calls(path, old.decode())
    actual.sort(key=lambda c: (c.path, c.line, c.api))
    prior.sort(key=lambda c: (c.path, c.line, c.api))
    check(not inventory.errors and not parse_errors and not prior_errors, "actual collector admission")
    check(tuple(c for c in inventory.calls if c.path == path) == tuple(actual), "actual MainGame call coordinates")
    check(any(a.line != b.line for a, b in zip(actual, prior))
          and [(c.function, c.api, c.korean, c.english, c.context_id) for c in actual] ==
              [(c.function, c.api, c.korean, c.english, c.context_id) for c in prior], "only coordinates changed")
    positions = iter(prior)
    prior_calls = tuple(next(positions) if c.path == path else c for c in inventory.calls)
    contexts = {e.source: e.context for e in ja._gift_caption_inventory_view(inventory, prior_calls).legacy_entries}
    baseline = replace(inventory, calls=prior_calls,
                       legacy_entries=tuple(replace(e, context=contexts[e.source]) for e in inventory.legacy_entries))
    check(ja.modal_rebind_inventory(baseline, raw) == inventory, "all current fields reconstructed exactly")
    target = next(i for i, call in enumerate(prior_calls) if call.path == path)
    for label, calls in (("missing", prior_calls[:target] + prior_calls[target + 1:]),
                          ("duplicate", (*prior_calls, prior_calls[target])),
                          ("wrong line", tuple(replace(c, line=c.line + 1) if c.path == path else c for c in prior_calls))):
        reject(lambda rows=calls: ja.modal_rebind_inventory(replace(baseline, calls=rows), raw), "call location " + label)
    # Synthetic source-map fixture tests the comparison composition only. The
    # root's five current normals bind the full actual source census separately.
    aruba = (ROOT / append.ARUBA_FONT_PATH).read_bytes()
    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha(aruba), "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    before_modal = {**hashes, path: sha(old)}
    before_both = {**before_modal, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}
    for label, expected in (("current", source["source_manifest_sha256"]),
                            ("prior MainGame", append.exchange.digest(before_modal)),
                            ("prior MainGame and Aruba", append.exchange.digest(before_both))):
        check(append._source_manifest_matches(ROOT, source, expected), "manifest " + label)
    check(source == preserved, "source census remains actual")
    mutant = {**hashes, path: sha(old)}
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": mutant,
               "source_manifest_sha256": append.exchange.digest(mutant)}, "0" * 64), "manifest rollback source claim")
    mutant = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": mutant,
          "source_manifest_sha256": append.exchange.digest(mutant)}, append.exchange.digest(before_both)), "manifest neighbor not exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof unavailable")):
        reject(lambda: append._source_manifest_matches(ROOT, source, source["source_manifest_sha256"]),
               "even equal current manifest does not hide lost proof")
    check(all((ROOT / p).read_bytes() == value for p, value in original.items()), "runtime/tools/UI/ledger unchanged")
    return failures, cases


def job_status_wrap_self_test() -> tuple[list[str], int]:
    """Only ORDER-382's exact successor, current locations and manifest chain."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("Job status wrap: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append_self_test.py",
                 "tools/audit_scope.json", "tools/ja_translation_pipeline.py", "tools/ui_translation_append.py",
                 *append.CURRENT_PATHS)
    original = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, old = history._job_status_wrap_proof(raw, ROOT)
    check(sha(raw) == "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea"
          and sha(prior) == "6c26e3db61c810cd52022128a459a7160abf49c6a0c3d085f196755f9e232f8d"
          and sha(old) == "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
          "independent whole runtime pins")
    check(history.job_status_wrap_predecessor(raw, ROOT) == prior
          and history.modal_font_predecessor(raw, ROOT) == old, "one-stage and public composed contracts")
    check(prior.count(history.JOB_STATUS_REPLACEMENT[0]) == 1
          and prior.replace(*history.JOB_STATUS_REPLACEMENT, 1) == raw, "one token exact whole inverse")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                    ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " all three current entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " wrong observed claim")
        for label, mutant in (("rollback381", prior), ("rollback pre381", old), ("space", raw + b"\n"),
                              ("neighbor", raw.replace(b"max_promotions\", 3", b"max_promotions\", 4", 1))):
            check(mutant != raw and bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for label, mutant in (("empty", b""), ("wrong type", None),
                          ("duplicate token", raw + history.JOB_STATUS_REPLACEMENT[1])):
        reject(lambda value=mutant: history.job_status_wrap_predecessor(value, ROOT), label)
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost proof after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "fresh proof loss fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside",
              "other paths do not project or require successor proof")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.JOB_STATUS_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), label)
    for name, value in (("JOB_STATUS_BEFORE_COMMIT", history.JOB_STATUS_AFTER_COMMIT),
                        ("JOB_STATUS_REPLACEMENT", (b"wrong", history.JOB_STATUS_REPLACEMENT[1])),
                        ("MODAL_REPLACEMENTS", history.MODAL_REPLACEMENTS[:-1])):
        with mock.patch.object(history, name, value):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), "immutable boundary " + name)
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restores without prior success cache")

    # One current collector, not the unchanged 381/378/380 historical suites.
    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    before, before_errors = ja.parse_ui_calls(path, prior.decode())
    check(not actual_errors and not before_errors and actual == before,
          "same-line token keeps every actual call field and coordinate")
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) ==
          tuple(sorted(actual, key=lambda c: (c.path, c.line, c.api))), "collector exposes actual call coordinates")
    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    comparison = {**hashes, path: sha(old)}
    older = {**comparison, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}
    for label, expected in (("actual", source["source_manifest_sha256"]),
                            ("pre381", append.exchange.digest(comparison)),
                            ("pre381 and preAruba", append.exchange.digest(older))):
        check(append._source_manifest_matches(ROOT, source, expected), "manifest comparison " + label)
    check(source == preserved, "actual inventory is not rewritten")
    mutant = {**hashes, path: sha(prior)}
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": mutant,
           "source_manifest_sha256": append.exchange.digest(mutant)}, append.exchange.digest(comparison)),
           "old raw claim cannot mask current manifest")
    mutant = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": mutant,
          "source_manifest_sha256": append.exchange.digest(mutant)}, append.exchange.digest(older)),
          "unowned manifest difference is not exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof disappeared")):
        reject(lambda: append._source_manifest_matches(ROOT, source, source["source_manifest_sha256"]),
               "equal actual manifest still requires fresh proof")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in original.items()), "all observed files unchanged")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--synthetic-only", action="store_true", help="author development only; not current acceptance")
    parser.add_argument("--three-locales", action="store_true", help="bounded JA/current47 change tests only; no historical suite")
    parser.add_argument("--correction", action="store_true", help="exact two-target correction only; no old suite or collector")
    parser.add_argument("--main-modal", action="store_true", help="three rendering repairs and current-location bridge only")
    parser.add_argument("--job-status-wrap", action="store_true", help="current one-token career-wrap successor only; no old suites")
    args = parser.parse_args()
    if args.job_status_wrap:
        errors, cases = job_status_wrap_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"JOB_STATUS_WRAP_SOURCE_SELF_TEST_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    if args.main_modal:
        errors, cases = main_modal_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"MAIN_MODAL_SOURCE_SELF_TEST_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    if args.correction:
        errors, cases = correction_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_CORRECTION_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    if args.three_locales:
        errors, cases = three_locales_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_THREE_LOCALES_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    errors, cases = synthetic_self_test()
    print(f"UI_TRANSLATION_APPEND_SYNTHETIC cases={cases}")
    if not args.synthetic_only:
        current_errors, current_cases = current_self_test()
        errors.extend(current_errors)
        cases += current_cases
        print(f"UI_TRANSLATION_APPEND_CURRENT cases={current_cases}")
        font_errors, font_cases = aruba_font_self_test()
        errors.extend(font_errors)
        cases += font_cases
        print(f"UI_TRANSLATION_APPEND_ARUBA_FONT cases={font_cases}")
        correction_errors, correction_cases = correction_self_test()
        errors.extend(correction_errors)
        cases += correction_cases
        print(f"UI_TRANSLATION_APPEND_CORRECTION cases={correction_cases}")
        # The exact381 body/explicit option remains historical; default checks
        # the actual382 successor instead of pretending381 is still current.
        modal_errors, modal_cases = job_status_wrap_self_test()
        errors.extend(modal_errors)
        cases += modal_cases
        print(f"UI_TRANSLATION_APPEND_JOB_STATUS_WRAP cases={modal_cases}")
    for error in errors:
        print("UI_TRANSLATION_APPEND_ERROR " + error)
    marker = "UI_TRANSLATION_APPEND_SYNTHETIC" if args.synthetic_only else "UI_TRANSLATION_APPEND_SELF_TEST"
    print(f"{marker}_{'FAIL' if errors else 'OK'} cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
