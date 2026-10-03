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


def investment_fee_correction_self_test() -> tuple[list[str], int]:
    """Exact384 controls only; one-leaf fixture, no collector or old suites."""
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("fee correction: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    key, ledger = append.FEE_KEY, append.LEDGER_PATH
    original = {p: (ROOT / p).read_bytes() for p in append.CURRENT_PATHS}
    leaf = append.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
    inventory = {"leaves": [leaf], "source_manifest_sha256": append._source_manifest(ROOT, append.FEE_BEFORE_COMMIT)}
    before, after, change = append._fee_correction_proof(ROOT, inventory)
    check(change["corrections"] == 2 and change["correction_batches"] == 1
          and change["receipts"] == change["batches"] == 0, "two corrected targets, no new coverage")
    check(append._fee_comparison(after, before, after) == before, "whole raw inverse")
    old_leaf = append.exchange.Leaf("ui", append.CORRECTION_KEY, "runtime:static_ui",
                                   (append.CORRECTION_KEY,), append.CORRECTION_KEY, "ui_static_context")
    old_before, old_after, _ = append._correction_proof(ROOT, {**inventory, "leaves": [old_leaf]})
    comparison = append._correction_comparison(before, old_before, old_after)
    check(len(append._loads(comparison[ledger])["batches"]) == 150,
          "fee then380 inverse preserves original correction boundary")
    reject(lambda: append.validate_append(before, after, inventory), "ordinary append does not permit corrections")
    reject(lambda: append._validate_fee_correction(before, {**after, append.CURRENT_UI_PATHS[0]: original[append.CURRENT_UI_PATHS[0]]},
                                                   inventory), "JA cannot enter three-path correction")
    documents = {p: append._Document(raw) for p, raw in after.items()}
    def mutate(path, field, value):
        doc = documents[path]
        start, end = doc.spans[field]
        edits = [(start, end, append._ordered(value).decode())]
        if path == ledger and field[0] == "accepted":
            accepted = copy.deepcopy(doc.value["accepted"])
            target = accepted
            for part in field[1:-1]:
                target = target[part]
            target[field[-1]] = value
            start, end = doc.spans[("accepted_sha256",)]
            edits.append((start, end, append._ordered(append.exchange.digest(accepted)).decode()))
        text = doc.text
        for start, end, replacement in sorted(edits, reverse=True):
            text = text[:start] + replacement + text[end:]
        return {**after, path: text.encode()}
    for path in append.PATHS:
        reject(lambda p=path: append._validate_fee_correction(before, {**after, p: before[p]}, inventory), "mixed rollback " + path)
        reject(lambda p=path: append._validate_fee_correction(before, {**after, p: after[p] + b"\n"}, inventory), "raw whitespace " + path)
    for path in append.UI_PATHS:
        reject(lambda p=path: append._validate_fee_correction(before, mutate(p, (key,), "changed fee"), inventory), "fee target " + path)
        neighbor = next(k for k in documents[path].value if k != key)
        reject(lambda p=path, k=neighbor: append._validate_fee_correction(before, mutate(p, (k,), "neighbor"), inventory), "UI neighbor " + path)
    mutant = mutate(append.UI_PATHS[0], (append.CORRECTION_KEY,), append.CORRECTION_TEXTS["zh-CN"][0])
    reject(lambda: append._correction_comparison(append._fee_comparison(mutant, before, after), old_before, old_after),
           "old380 rollback is still rejected after fee inverse")
    quoted = json.dumps(key, ensure_ascii=False).encode() + b":"
    mutant = {**after, append.UI_PATHS[0]: after[append.UI_PATHS[0]].replace(quoted, quoted + b' "duplicate", ' + quoted, 1)}
    reject(lambda: append._validate_fee_correction(before, mutant, inventory), "duplicate raw fee member")
    for label, field, value in (
        ("old source receipt", ("accepted", "zh-CN", leaf.id, "source_sha256"), "0" * 64),
        ("target receipt and fresh checksum", ("accepted", "zh-TW", leaf.id, "target_sha256"), "0" * 64),
        ("original383 locale batch", ("batches", 149, "target_leaves_by_locale", "zh-CN"), 0),
        ("boolean source count", ("batches", 151, "source_leaves"), True),
        ("extra correction root", ("batches", 151, "roots"), [key, "another key"]),
        ("previous target claim", ("batches", 151, "before_target_sha256_by_locale", "zh-CN"), "0" * 64),
        ("official receipt digest", ("batches", 151, "receipt_sha256_by_locale", "zh-TW"), "0" * 64),
        ("previous-target selection", ("batches", 151, append.HEADERS_FIELD, "zh-CN", "selection_sha256"), "0" * 64),
        ("official boolean count", ("batches", 151, append.HEADERS_FIELD, "zh-TW", "count"), True),
        ("native claim", ("batches", 151, "native_review"), "GO"),
    ):
        reject(lambda f=field, v=value: append._validate_fee_correction(before, mutate(ledger, f, v), inventory), label)
    rows = documents[ledger].value["batches"]
    for label, value in (("missing correction", rows[:-1]), ("duplicate correction", [*rows, rows[-1]]),
                         ("reordered correction", [*rows[:-2], rows[-1], rows[-2]])):
        reject(lambda v=value: append._validate_fee_correction(before, mutate(ledger, ("batches",), v), inventory), label)
    for field, value in (("source", "changed Korean"), ("protected", True)):
        reject(lambda f=field, v=value: append._validate_fee_correction(before, after,
               {**inventory, "leaves": [replace(leaf, **{f: v})]}), "current leaf " + field)
    reject(lambda: append._validate_fee_correction(before, after, {**inventory, "leaves": [leaf, leaf]}), "duplicate source leaf")
    doc = documents[ledger]
    start, end = doc.spans[("accepted", "zh-CN", leaf.id, "target_sha256")]
    token = doc.text[start:end]
    escaped = token[:1] + "\\u%04x" % ord(token[1]) + token[2:]
    reject(lambda: append._fee_comparison({**after, ledger: (doc.text[:start] + escaped + doc.text[end:]).encode()},
                                          before, after), "same-value corrected hash raw escape")
    real_git = append._git
    with mock.patch.object(append, "_git", side_effect=OSError("fresh Git unavailable")):
        reject(lambda: append._fee_correction_proof(ROOT, inventory), "no stale successful proof cache")
    def forged(where, *args, **kwargs):
        raw = real_git(where, *args, **kwargs)
        return raw + b"forged" if args[:2] == ("cat-file", "--batch") else raw
    with mock.patch.object(append, "_git", side_effect=forged):
        reject(lambda: append._fee_correction_proof(ROOT, inventory), "forged immutable object stream")
    def wrong_paths(where, *args, **kwargs):
        return b"M\0outside.json\0" if args and args[0] == "diff" else real_git(where, *args, **kwargs)
    with mock.patch.object(append, "_git", side_effect=wrong_paths):
        reject(lambda: append._fee_correction_proof(ROOT, inventory), "product path population")
    with mock.patch.object(append, "FEE_BEFORE_COMMIT", append.FEE_AFTER_COMMIT):
        reject(lambda: append._fee_correction_proof(ROOT, inventory), "wrong direct parent")
    check(append._fee_correction_proof(ROOT, inventory)[2] == change, "fresh valid proof restored")

    # Exact transition is isolated, so later legitimate appends cannot make
    # this fixed fixture pretend the live HEAD must still equal product384.
    env = {**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
           "GIT_AUTHOR_NAME": "fee fixture", "GIT_AUTHOR_EMAIL": "fixture@example.invalid",
           "GIT_COMMITTER_NAME": "fee fixture", "GIT_COMMITTER_EMAIL": "fixture@example.invalid"}
    for name in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
        env.pop(name, None)
    with tempfile.TemporaryDirectory(prefix="ui-fee-history-") as directory:
        root = Path(directory)
        def git(*args):
            result = subprocess.run(("git", *args), cwd=root, env=env, capture_output=True, timeout=30)
            if result.returncode:
                raise RuntimeError(result.stderr.decode())
        git("clone", "-q", "--shared", "--no-checkout", str(ROOT), str(root))
        git("update-ref", "HEAD", append.FEE_AFTER_COMMIT)
        git("read-tree", append.FEE_AFTER_COMMIT)
        result = append.validate_history(root, append.FEE_BEFORE_COMMIT, before, after, inventory)
        check(result["corrections"] == 2 and result["batches"] == result["correction_batches"] == 1
              and result["receipts"] == result["append_batches"] == 0, "exact Git lineage with actual historical manifest")
        reject(lambda: append.validate_history(root, append.FEE_BEFORE_COMMIT, before, before, inventory),
               "current rollback differs from actual HEAD")
        reject(lambda: append.validate_history(root, append.FEE_BEFORE_COMMIT, before, after,
               {**inventory, "source_manifest_sha256": "0" * 64}), "current manifest mismatch")
        extra = append.exchange.Leaf("ui", "합성 후속 문구", "runtime:static_ui", ("합성 후속 문구",),
                                     "합성 후속 문구", "ui_static_context")
        extended = {**inventory, "leaves": [leaf, extra]}
        future, headers, hashes = dict(after), {}, {}
        accepted = copy.deepcopy(doc.value["accepted"])
        edits = []
        for locale, path in zip(append.LOCALES, append.UI_PATHS):
            text = "合成后续文字" if locale == "zh-CN" else "合成後續文字"
            ui = documents[path]
            end = ui.spans[(list(ui.value)[-1],)][1]
            addition = ",\n  " + append._ordered(extra.owner).decode() + ": " + append._ordered(text).decode()
            future[path] = (ui.text[:end] + addition + ui.text[end:]).encode()
            row = {"source_sha256": extra.source_sha256, "target_sha256": append.exchange.digest(text)}
            end = doc.spans[("accepted", locale, list(accepted[locale])[-1])][1]
            addition = ",\n      " + append._ordered(extra.id).decode() + ": " + append._ordered(row).decode()
            edits.append((end, end, addition))
            accepted[locale][extra.id] = row
            header = append.exchange.make_batch(extended, locale, [extra], append.FEE_AFTER_COMMIT, {}, {})[0]
            headers[locale] = header
            hashes[locale] = append.exchange.digest({"batch": header, "state": "accepted_machine_validated",
                                                     "native_review": "OPEN", "translations": {extra.id: row}})
        batch = {"order": "synthetic following fee correction", "group": "ui", "roots": [extra.owner], "source_leaves": 1,
                 "target_leaves_by_locale": {"ja": 0, "zh-CN": 1, "zh-TW": 1}, "machine_validation": "PASS",
                 "native_review": "OPEN", append.HEADERS_FIELD: headers, "receipt_sha256_by_locale": hashes}
        end = doc.spans[("batches", 151)][1]
        edits.append((end, end, ",\n    " + append._ordered(batch).decode()))
        start, end = doc.spans[("accepted_sha256",)]
        edits.append((start, end, append._ordered(append.exchange.digest(accepted)).decode()))
        text = doc.text
        for start, end, replacement in sorted(edits, reverse=True):
            text = text[:start] + replacement + text[end:]
        future[ledger] = text.encode()
        rollback = dict(future)
        ui = append._Document(future[append.UI_PATHS[0]])
        start, end = ui.spans[(key,)]
        rollback[append.UI_PATHS[0]] = (ui.text[:start] + append._ordered(append.FEE_TEXTS["zh-CN"][0]).decode() + ui.text[end:]).encode()
        for label, snapshot in (("valid subsequent append", future), ("committed rollback", rollback),
                                ("restoration does not erase rollback", future)):
            for path, raw in snapshot.items():
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
            git("add", "--", *append.PATHS)
            git("commit", "-qm", label)
            if label == "valid subsequent append":
                result = append.validate_history(root, append.FEE_BEFORE_COMMIT, before, snapshot, extended)
                check(result["receipts"] == 2 and result["corrections"] == 2 and result["batches"] == 2, label)
            else:
                reject(lambda value=snapshot: append.validate_history(root, append.FEE_BEFORE_COMMIT, before, value, extended), label)
    check(all((ROOT / p).read_bytes() == raw for p, raw in original.items()), "live product bytes unchanged")
    return failures, cases


def investment_footer_self_test() -> tuple[list[str], int]:
    """Current386 only: exact rendering inverse, current calls and manifests."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("investment footer: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", *append.CURRENT_PATHS)
    original = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, old = history._investment_footer_proof(raw, ROOT)
    check(sha(raw) == "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90"
          and sha(prior) == "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea"
          and sha(old) == "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
          "independent whole current/pre386/pre381 pins")
    check(history.investment_footer_predecessor(raw, ROOT) == prior
          and history.modal_font_predecessor(raw, ROOT) == old, "direct and composed comparison contracts")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " three actual current entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed claim")
        for label, mutant in (("pre386 rollback", prior), ("pre381 rollback", old),
                              ("raw whitespace", raw + b"\n"),
                              ("neighbor", raw.replace(b"max_promotions\", 3", b"max_promotions\", 4", 1))):
            check(mutant != raw and bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for index, (before, after) in enumerate(history.INVESTMENT_REPLACEMENTS):
        mutant = raw.replace(after.encode(), before.encode(), 1)
        check(mutant != raw and bool(history.main_game_history_source_errors(path, mutant)),
              "partial rendering rollback " + str(index))
    for mutant in (b"", None):
        reject(lambda value=mutant: history.investment_footer_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.INVESTMENT_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), label)
    for name, value in (("INVESTMENT_BEFORE_COMMIT", history.INVESTMENT_AFTER_COMMIT),
                        ("INVESTMENT_REPLACEMENTS", history.INVESTMENT_REPLACEMENTS[:-1]),
                        ("JOB_STATUS_REPLACEMENT", (b"wrong", history.JOB_STATUS_REPLACEMENT[1])),
                        ("MODAL_REPLACEMENTS", history.MODAL_REPLACEMENTS[:-1])):
        with mock.patch.object(history, name, value):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), "immutable boundary " + name)
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost proof after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost fresh proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside",
              "other paths have zero projection")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restored without success cache")

    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    before, before_errors = ja.parse_ui_calls(path, prior.decode())
    ordered = lambda calls: sorted(calls, key=lambda c: (c.path, c.line, c.api))
    semantics = lambda calls: [(c.path, c.function, c.api, c.korean, c.english, c.context_id) for c in ordered(calls)]
    check(not actual_errors and not before_errors and semantics(actual) == semantics(before),
          "all KO/EN keys, functions, identities and call order unchanged")
    check(any(a.line != b.line for a, b in zip(ordered(actual), ordered(before))),
          "actual line shifts are observed, not historical coordinates")
    # Exactly one actual UI collection; no original 381/382 or correction suites.
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == tuple(ordered(actual)),
          "current collector exposes actual call locations")
    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    pre386 = {**hashes, path: sha(prior)}
    pre381 = {**hashes, path: sha(old)}
    pre_aruba = {**pre381, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}
    for label, expected in (("actual", source["source_manifest_sha256"]),
                            ("pre386", append.exchange.digest(pre386)),
                            ("pre381", append.exchange.digest(pre381)),
                            ("pre381/preAruba", append.exchange.digest(pre_aruba))):
        check(append._source_manifest_matches(ROOT, source, expected), "manifest comparison " + label)
    check(source == preserved, "actual inventory never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": pre386,
           "source_manifest_sha256": append.exchange.digest(pre386)}, append.exchange.digest(pre386)),
           "historical raw claim cannot masquerade as current")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(pre386)), "census hash mismatch")
    mutant = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": mutant,
          "source_manifest_sha256": append.exchange.digest(mutant)}, append.exchange.digest(pre386)),
          "unowned manifest difference not exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof disappeared")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(pre386)),
               "old official manifest still requires fresh proof")
    check(append._source_manifest(ROOT, history.INVESTMENT_BEFORE_COMMIT) ==
          "e35bbc10c1ec991f15141cbb7ba3baa6f4220661a223b10efcb397a29103cb85",
          "actual Git pre386 official source census")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in original.items()), "all observed files unchanged")
    return failures, cases


def tutorial_copy_self_test() -> tuple[list[str], int]:
    """Current390 exact source correction; no historical/full self invocation."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    import ja_translation_audit as audit
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("tutorial copy: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    original = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, pre386, old = history._tutorial_copy_proof(raw, ROOT)
    check(sha(raw) == "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff"
          and sha(prior) == "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90"
          and sha(pre386) == "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea"
          and sha(old) == "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
          "independent current/pre390/pre386/pre381 whole pins")
    check(raw.replace(history.TUTORIAL_REPLACEMENT[1].encode(),
                      history.TUTORIAL_REPLACEMENT[0].encode(), 1) == prior,
          "one pair inverse preserves every other byte")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " actual three entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed hash")
        for label, mutant in (("rollback", prior), ("whitespace", raw + b"\n"),
                              ("KO-only rollback", raw.replace(history.TUTORIAL_NEW_KO.encode(), history.TUTORIAL_OLD_KO.encode(), 1)),
                              ("EN-only rollback", raw.replace(history.TUTORIAL_NEW_EN.encode(), history.TUTORIAL_OLD_EN.encode(), 1)),
                              ("neighbor", raw.replace(b"max_promotions\", 3", b"max_promotions\", 4", 1))):
            check(mutant != raw and bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for mutant in (b"", None):
        reject(lambda value=mutant: history.tutorial_copy_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.TUTORIAL_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), label)
    for name, value in (("TUTORIAL_BEFORE_COMMIT", history.TUTORIAL_AFTER_COMMIT),
                        ("TUTORIAL_REPLACEMENT", (history.TUTORIAL_REPLACEMENT[0] + " ", history.TUTORIAL_REPLACEMENT[1]))):
        with mock.patch.object(history, name, value):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), "immutable boundary " + name)
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside", "other path projection zero")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof recovers without cross-call cache")

    # One actual collector call and one explicitly historical comparison view;
    # no old self suites and no historical source passed as current raw.
    inventory = ja.collect_ui_inventory()
    before, actual = ja._tutorial_copy_call_views(raw)
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == actual,
          "actual collector current pair and all source coordinates")
    old_ko, new_ko = history.TUTORIAL_OLD_KO, history.TUTORIAL_NEW_KO
    check(old_ko not in inventory.blueprint and new_ko in inventory.blueprint
          and sum(c.korean == new_ko for c in inventory.calls) == 1,
          "new key exact1 and old key zero current calls")
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    rebound = ja.modal_rebind_inventory(baseline, raw)
    check(rebound == inventory, "whole current inventory roundtrip including context layers/stats")
    existing = {e.source: e for e in baseline.legacy_entries if e.source != old_ko}
    check(all(replace(e, context=existing[e.source].context) == existing[e.source]
              and inventory.legacy_blueprint[e.source] == baseline.legacy_blueprint[e.source]
              for e in inventory.legacy_entries if e.source in existing)
          and set(existing) == {e.source for e in inventory.legacy_entries if e.source != new_ko},
          "every unowned entry field and blueprint ID preserved, including branch IDs")
    old_entry = next(e for e in baseline.legacy_entries if e.source == old_ko)
    new_entry = next(e for e in inventory.legacy_entries if e.source == new_ko)
    check(old_entry.source_hash != new_entry.source_hash and old_entry.key != new_entry.key,
          "source change gets new source identity, never a historical hash")
    index = next(i for i, call in enumerate(baseline.calls) if call.path == path)
    for label, calls in (("missing", baseline.calls[:index] + baseline.calls[index + 1:]),
                         ("duplicate", baseline.calls + (baseline.calls[index],)),
                         ("wrong location", baseline.calls[:index] + (replace(baseline.calls[index], line=0),) + baseline.calls[index + 1:])):
        reject(lambda rows=calls: ja.modal_rebind_inventory(replace(baseline, calls=rows), raw), label + " predecessor calls")
    code = (ROOT / "tools/ja_translation_pipeline.py").read_bytes()
    check(sha(ja.tutorial_pipeline_predecessor(code)) == ja.TUTORIAL_PIPELINE_BEFORE_SHA,
          "whole prior collector code and immutable blob")
    check(sha(ja.nonformat_pipeline_predecessor(code)) == ja.NONFORMAT_BEFORE_SHA
          and sha(ja.current_demo_pipeline_predecessor(code)) == ja.CURRENT_DEMO_BEFORE_SHA,
          "direct older collector entry contracts preserved")
    reject(lambda: ja.tutorial_pipeline_predecessor(code + b"\n"), "code neighbor drift")
    targets = audit.read_json(ROOT / "locale/ui_ja.json")
    retained, errors = audit.tutorial_retained_ja_entries(inventory, targets)
    check(not errors and set(retained) == {old_ko}, "only exact historical Japanese target retained")
    for target in ({**targets, old_ko: "changed"}, {k: v for k, v in targets.items() if k != old_ko}):
        found, errors = audit.tutorial_retained_ja_entries(inventory, target)
        check(not found and bool(errors), "changed/missing retired target rejected")
    found, errors = audit.tutorial_retained_ja_entries(baseline, targets)
    check(not found and bool(errors), "retired source cannot be supplied as current")
    leaf_id = "ui:" + old_ko + ":/" + old_ko.replace("~", "~0").replace("/", "~1")
    with mock.patch.object(audit, "read_json", return_value={"accepted": {"ja": {leaf_id: {}}}}):
        found, errors = audit.tutorial_retained_ja_entries(inventory, targets)
        check(not found and bool(errors), "retired source receipt forbidden")
    with mock.patch.object(history, "_modal_git", side_effect=lambda where, *args, **kwargs:
                           b"{}" if args[:1] == ("show",) else real_git(where, *args, **kwargs)):
        found, errors = audit.tutorial_retained_ja_entries(inventory, targets)
        check(not found and bool(errors), "forged historical Japanese blob rejected")
    errors = []
    audit.walk_blueprint("ui", {new_ko: inventory.blueprint[new_ko]}, {}, {new_entry.key: new_entry}, errors)
    check(bool(errors), "missing new Japanese target still fails original checker")

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    manifests = [hashes, {**hashes, path: sha(prior)}, {**hashes, path: sha(pre386)}, {**hashes, path: sha(old)},
                 {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    for index, view in enumerate(manifests):
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)), "exact manifest stage " + str(index))
    check(source == preserved, "current census never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": manifests[1],
           "source_manifest_sha256": append.exchange.digest(manifests[1])}, append.exchange.digest(manifests[1])),
           "historical raw claim cannot masquerade as current")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(manifests[1])), "forged manifest")
    altered_hashes = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": altered_hashes,
          "source_manifest_sha256": append.exchange.digest(altered_hashes)}, append.exchange.digest(manifests[1])),
          "neighbor source manifest never exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof disappeared")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(manifests[1])),
               "old header admission requires fresh proof")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in original.items()), "all observed files unchanged")
    return failures, cases


def _split_receipt_transaction_self_test(before, pending, complete, inventory) -> tuple[list[str], int]:
    """A rejected ingress must not leave a reusable pending state."""
    errors = []
    state = append._SplitReceiptHistory(ROOT, inventory)
    invalid = {**pending, append.LEDGER_PATH: pending[append.LEDGER_PATH] + b"\n"}
    for commit, previous, successor, expected in (
            (append.SPLIT_INGRESS_COMMIT, before, invalid, "split ingress snapshots differ from proof"),
            (append.SPLIT_REPAIR_COMMIT, pending, complete, "orphan/duplicate split receipt recovery")):
        try:
            state.step(commit, previous, successor)
        except ValueError as exc:
            if expected not in str(exc):
                errors.append("split receipt transaction: wrong rejection boundary: " + str(exc))
        else:
            errors.append("split receipt transaction: invalid ingress/recovery was accepted")
        if state.proof is not None or state.completed:
            errors.append("split receipt transaction: rejected ingress changed state")
    return errors, 2


def _split_receipt_binding_self_test(before, pending, complete, inventory) -> tuple[list[str], int]:
    """Small independently rerunnable semantic/raw controls, with valid checksums."""
    failures, cases = [], 0
    ledger = append.LEDGER_PATH
    document = append._Document(complete[ledger])

    def reject(action, label, expected=None):
        nonlocal cases
        cases += 1
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            if expected is not None and expected not in str(exc):
                failures.append("split receipt binding: " + label + " rejected at wrong boundary: " + str(exc))
        else:
            failures.append("split receipt binding: " + label + " was accepted")

    key = "[b]패드[/b]  LB/RB 페이지 · %s 뒤로  —  %s"
    row_id = append.receipt_id(key)
    for locale, path in zip(append.LOCALES, append.UI_PATHS):
        for field in ("source_sha256", "target_sha256"):
            accepted = copy.deepcopy(document.value["accepted"])
            accepted[locale][row_id][field] = "0" * 64
            edits = []
            for address, value in ((("accepted", locale, row_id, field), "0" * 64),
                                   (("accepted_sha256",), append.exchange.digest(accepted))):
                start, end = document.spans[address]
                edits.append((start, end, append._ordered(value).decode()))
            text = document.text
            for start, end, value in sorted(edits, reverse=True):
                text = text[:start] + value + text[end:]
            candidate = {**complete, ledger: text.encode()}
            reject(lambda value=candidate: append._validate_split_receipt(before, pending, value, inventory),
                   locale + " checksum-valid " + field, "UI/receipt/source/target additions differ: " + locale)
        ui = append._Document(complete[path])
        neighbor = next(name for name in ui.value if name != key)
        for label, address, value, expected in (
                ("preserved target", (key,), "changed", "split delivery is not the exact four preserved targets"),
                ("old neighbor", (neighbor,), "changed", "old UI member/order/value changed: " + locale)):
            start, end = ui.spans[address]
            raw = (ui.text[:start] + append._ordered(value).decode() + ui.text[end:]).encode()
            changed_pending, changed_complete = {**pending, path: raw}, {**complete, path: raw}
            reject(lambda a=changed_pending, b=changed_complete: append._validate_split_receipt(before, a, b, inventory),
                   locale + " both pending/complete " + label, expected)
        changed_pending = {**pending, path: pending[path] + b"\n"}
        changed_complete = {**complete, path: complete[path] + b"\n"}
        reject(lambda a=changed_pending, b=changed_complete: append._validate_split_receipt(before, a, b, inventory),
               locale + " both pending/complete whitespace", "bytes outside exact additions changed: " + path)
    with mock.patch.object(append, "SPLIT_REPAIR_TREE", "3d6b582384591fc6504d95ea54c51e6d9fefe97a"):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong exact repair tree")
    blobs = dict(append.SPLIT_BLOBS)
    path = append.UI_PATHS[0]
    blobs[path] = (blobs[path][0], blobs[path][0], blobs[path][2])
    with mock.patch.object(append, "SPLIT_BLOBS", blobs):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong pending blob pin")
    state = append._SplitReceiptHistory(ROOT, inventory)
    state.step(append.SPLIT_INGRESS_COMMIT, before, pending)
    interim = state.step("4" * 40, pending, pending)
    recovered = state.step(append.SPLIT_REPAIR_COMMIT, pending, complete)
    state.finish()
    cases += 1
    if interim["receipts"] != 0 or interim["batches"] != 0 or recovered["receipts"] != 8:
        failures.append("split receipt binding: unchanged pending observation changed acceptance")
    transaction_errors, transaction_cases = _split_receipt_transaction_self_test(before, pending, complete, inventory)
    failures.extend(transaction_errors)
    cases += transaction_cases
    return failures, cases


def split_receipt_self_test() -> tuple[list[str], int]:
    """Exact392 proof and production split state only; no historical suite replay."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("split receipt: " + label)

    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)

    # These independently named real source keys are not synthetic translations.
    keys = (
        "[b]패드[/b]  LB/RB 페이지 · %s 뒤로  —  %s",
        "[b]패드[/b]  LB/RB 페이지 · ↑↓ 자산 · ←→ 행동 · %s %s · %s 뒤로  —  %s",
        "[b]패드[/b]  LB/RB 페이지 · 거래 가능한 자산 없음",
        "거래 불가",
    )
    source_revision = "18dd16d6020b2dcae8484f4b70af3261a6ccd91e"
    ids = {append.receipt_id(key) for key in keys}
    sha = lambda raw: hashlib.sha256(raw).hexdigest()
    protected = (*append.CURRENT_PATHS, "scenes/MainGame.gd",
                 "tools/order350_source_compat.py", "tools/order351_source_compat.py")
    observed = {path: sha((ROOT / path).read_bytes()) for path in protected}
    collected = append.exchange.collect(ROOT)
    leaves = [leaf for leaf in collected["leaves"] if leaf.id in ids]
    check(len(leaves) == 4 and {leaf.owner for leaf in leaves} == set(keys), "four actual Korean source leaves")
    inventory = {**collected, "leaves": leaves}
    before, pending, complete, change = append._split_receipt_proof(ROOT, inventory)
    ledger = append.LEDGER_PATH
    check(change["receipts"] == 8 and change["batches"] == 2
          and all(change["ui_by_locale"][locale] == 4 for locale in append.LOCALES),
          "exact eight receipts in two official batches")
    check(pending[ledger] == before[ledger]
          and all(complete[path] == pending[path] for path in complete if path != ledger),
          "ingress changes dictionaries only; repair changes ledger only")
    check(append._validate_split_receipt(before, pending, complete, inventory) == change,
          "pure exact transition agrees with fresh Git proof")
    check(append.validate_append(before, complete, inventory) == change,
          "unchanged ordinary append validator proves complete composite")
    reject(lambda: append.validate_append(before, pending, inventory), "old missing-receipt failure remains rejected")
    reject(lambda: append.validate_append(pending, complete, inventory), "ordinary append cannot excuse orphan receipt recovery")

    documents = {path: append._Document(raw) for path, raw in complete.items()}
    base_batches = len(append._Document(before[ledger]).value["batches"])

    def mutate(snapshot, path, field, value):
        doc = documents[path] if snapshot is complete else append._Document(snapshot[path])
        start, end = doc.spans[field]
        return {**snapshot, path: (doc.text[:start] + append._ordered(value).decode() + doc.text[end:]).encode()}

    def bad_complete(candidate, label):
        reject(lambda: append._validate_split_receipt(before, pending, candidate, inventory), label)

    for path in complete:
        reject(lambda p=path: append._validate_split_receipt(before, pending,
               {p2: raw for p2, raw in complete.items() if p2 != p}, inventory), "missing snapshot path " + path)
        bad_complete({**complete, path: complete[path] + b"\n"}, "whole raw whitespace " + path)
    bad_complete({**complete, "outside.json": b"{}\n"}, "unowned snapshot path")
    reject(lambda: append._validate_split_receipt(before, complete, complete, inventory), "receipts cannot predate repair")
    reject(lambda: append._validate_split_receipt(before, pending, pending, inventory), "missing complete ledger")
    reject(lambda: append._validate_split_receipt(before, before, complete, inventory), "missing UI ingress")

    for locale, path in zip(append.LOCALES, append.UI_PATHS):
        for key in keys:
            bad_complete(mutate(complete, path, (key,), "错误文字" if locale == "zh-CN" else "錯誤文字"),
                         locale + " target value " + key)
        key = keys[0]
        row_id = append.receipt_id(key)
        rows = copy.deepcopy(documents[ledger].value["accepted"][locale])
        rows.pop(row_id)
        bad_complete(mutate(complete, ledger, ("accepted", locale), rows), locale + " missing receipt")
        rows = copy.deepcopy(documents[ledger].value["accepted"][locale])
        rows["ui:orphan:/orphan"] = rows[row_id]
        bad_complete(mutate(complete, ledger, ("accepted", locale), rows), locale + " orphan receipt")
        doc = documents[ledger]
        start, end = doc.spans[("accepted", locale, row_id)]
        duplicated = doc.text[:end] + ",\n      " + append._ordered(row_id).decode() + ": " + doc.text[start:end] + doc.text[end:]
        bad_complete({**complete, ledger: duplicated.encode()}, locale + " duplicate raw receipt member")

    for index, locale in enumerate(append.LOCALES, base_batches):
        batch = documents[ledger].value["batches"][index]
        header_path = ("batches", index, append.HEADERS_FIELD, locale)
        check(batch[append.HEADERS_FIELD][locale]["source_revision"] == source_revision,
              locale + " preserved original export revision")
        for field, value in (("source_revision", "0" * 40), ("source_manifest_sha256", "0" * 64),
                             ("selection_sha256", "0" * 64), ("batch_id", "0" * 64),
                             ("count", True), ("native_review", "PASS")):
            bad_complete(mutate(complete, ledger, (*header_path, field), value), locale + " official header " + field)
        bad_complete(mutate(complete, ledger, ("batches", index, append.HEADERS_FIELD), {}),
                     locale + " missing official header")
        bad_complete(mutate(complete, ledger, ("batches", index, "receipt_sha256_by_locale", locale), "0" * 64),
                     locale + " official receipt digest")
        bad_complete(mutate(complete, ledger, ("batches", index, "roots"), [*keys[:-1], keys[0]]),
                     locale + " duplicate batch root")
        bad_complete(mutate(complete, ledger, ("batches", index, "roots"), [*keys[:-1], "orphan"]),
                     locale + " orphan batch root")
    batches = documents[ledger].value["batches"]
    bad_complete(mutate(complete, ledger, ("batches",), batches[:-1]), "missing official batch")
    bad_complete(mutate(complete, ledger, ("batches",), [*batches, batches[-1]]), "duplicate official batch")
    for label, changed in (("missing", leaves[:-1]), ("duplicate", [*leaves, leaves[0]]),
                           ("changed Korean", [replace(leaves[0], source="변경된 한국어"), *leaves[1:]]),
                           ("protected", [replace(leaves[0], protected=True), *leaves[1:]])):
        reject(lambda rows=changed: append._validate_split_receipt(before, pending, complete,
               {**inventory, "leaves": rows}), label + " current source leaf")
    binding_errors, binding_cases = _split_receipt_binding_self_test(before, pending, complete, inventory)
    failures.extend(binding_errors)
    cases += binding_cases

    # Only fresh immutable object transport is perturbed; no cached success,
    # forged HEAD or substituted current source inventory is used for a pass.
    real_git = append._git
    with mock.patch.object(append, "_git", side_effect=OSError("fresh Git unavailable")):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "missing fresh Git proof")
    def forged_objects(where, *args, **kwargs):
        raw = real_git(where, *args, **kwargs)
        return raw + b"forged" if args[:2] == ("cat-file", "--batch") else raw
    with mock.patch.object(append, "_git", side_effect=forged_objects):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong immutable object stream")
    def wrong_paths(where, *args, **kwargs):
        return b"M\0outside.json\0" if args and args[0] == "diff" else real_git(where, *args, **kwargs)
    with mock.patch.object(append, "_git", side_effect=wrong_paths):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong changed-path population")
    with mock.patch.object(append, "SPLIT_INGRESS_COMMIT", source_revision):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong ingress commit")
    with mock.patch.object(append, "SPLIT_REPAIR_COMMIT", source_revision):
        reject(lambda: append._split_receipt_proof(ROOT, inventory), "wrong repair commit")
    reject(lambda: append._split_receipt_proof(ROOT, {**inventory, "source_manifest_sha256": "0" * 64}),
           "wrong current source manifest")

    ingress, repair = append.SPLIT_INGRESS_COMMIT, append.SPLIT_REPAIR_COMMIT
    def state():
        return append._SplitReceiptHistory(ROOT, inventory)
    fresh = state()
    check(fresh.step("1" * 40, before, before) is None, "unrelated transition is not claimed")
    fresh.finish()
    opened = state()
    opened_change = opened.step(ingress, before, pending)
    check(opened_change["receipts"] == 0 and opened_change["batches"] == 0,
          "pending ingress never counted as accepted receipts")
    reject(opened.finish, "unresolved pending HEAD")
    reject(lambda: state().step(repair, pending, complete), "orphan repair")
    reject(lambda: opened.step(ingress, before, pending), "duplicate ingress")
    reject(lambda: opened.step("2" * 40, pending, complete), "wrong recovery commit")
    reject(lambda: opened.step("2" * 40, pending, before), "rollback while pending")
    reject(lambda: opened.step(repair, before, complete), "wrong repair predecessor")
    reject(lambda: opened.step(repair, pending, {**complete, ledger: complete[ledger] + b"\n"}),
           "wrong repair raw successor")
    closed = state()
    closed.step(ingress, before, pending)
    check(closed.step(repair, pending, complete) == change, "exact production state recovery")
    closed.finish()
    check(closed.step("3" * 40, complete, complete) is None, "ordinary post-repair transition retains normal validation")
    reject(lambda: closed.step(repair, pending, complete), "duplicate repair")
    reject(lambda: closed.step(ingress, before, pending), "ingress replay after recovery")
    check(append._split_receipt_proof(ROOT, inventory)[3] == change, "fresh valid proof after fault controls")
    check(all(sha((ROOT / path).read_bytes()) == value for path, value in observed.items()),
          "product source and original350/351 modules unchanged")
    return failures, cases


def pad_hint_font_self_test() -> tuple[list[str], int]:
    """Current393 four font lines only; no earlier self suites or split replay."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("pad hint font: " + label)
    def reject(action, label):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired):
            check(True, label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, pre390, pre386, old = history._pad_hint_font_proof(raw, ROOT)
    check(tuple(sha(v) for v in (raw, prior, pre390, pre386, old)) == (
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "independent current/pre393/pre390/pre386/pre381 whole pins")
    check(history.pad_hint_font_predecessor(raw, ROOT) == prior
          and history.tutorial_copy_predecessor(raw, ROOT) == pre390
          and history.investment_footer_predecessor(raw, ROOT) == pre386
          and history.modal_font_predecessor(raw, ROOT) == old, "all direct predecessor contracts")
    reject(lambda: history._tutorial_copy_proof(raw, ROOT), "original390 still rejects non390 current raw")
    for code, marker in (("tools/main_game_locale_history.py", b"# BEGIN_PAD_HINT_FONT_HISTORY_393"),
                         ("tools/ui_translation_append.py", b"# BEGIN_PAD_HINT_FONT_MANIFEST_393")):
        current_code = (ROOT / code).read_bytes()
        original = append._git(ROOT, "show", history.PAD_HINT_BEFORE_COMMIT + ":" + code)
        check(current_code.count(marker) == 1 and current_code.split(marker)[0].rstrip(b"\n") + b"\n" == original,
              "complete older code/pins preserved: " + code)
    check(history._pad_hint_font_inverse(raw, prior) == prior, "pure four-line inverse")
    # Exercise inverse semantics directly, without the outer whole-file digest
    # rejecting first and masking an incomplete/relocated inverse.
    for index, (before, after) in enumerate(history.PAD_HINT_REPLACEMENTS):
        before, after = before.encode(), after.encode()
        for label, mutant in (("partial", raw.replace(after, before, 1)),
                              ("duplicate", raw + after),
                              ("moved", raw.replace(after, before, 1) + after)):
            reject(lambda value=mutant: history._pad_hint_font_inverse(value, prior), label + " consumer " + str(index))
    reject(lambda: history._pad_hint_font_inverse(raw + b"\n", prior), "pure raw whitespace")
    reject(lambda: history._pad_hint_font_inverse(raw.replace(b"max_promotions\", 3", b"max_promotions\", 4", 1), prior),
           "pure unowned neighbor")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " three actual current entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed claim")
        for label, mutant in (("rollback", prior), ("whitespace", raw + b"\n")):
            check(bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for value in (b"", None):
        reject(lambda value=value: history.pad_hint_font_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.PAD_HINT_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.pad_hint_font_predecessor(raw, ROOT), label)
    for name, value in (("PAD_HINT_BEFORE_COMMIT", history.PAD_HINT_AFTER_COMMIT),
                        ("PAD_HINT_TREES", tuple(reversed(history.PAD_HINT_TREES))),
                        ("PAD_HINT_BLOBS", tuple(reversed(history.PAD_HINT_BLOBS))),
                        ("PAD_HINT_REPLACEMENTS", history.PAD_HINT_REPLACEMENTS[:-1]),
                        ("TUTORIAL_REPLACEMENT", (history.TUTORIAL_REPLACEMENT[0] + " ", history.TUTORIAL_REPLACEMENT[1])),
                        ("MODAL_REPLACEMENTS", history.MODAL_REPLACEMENTS[:-1])):
        with mock.patch.object(history, name, value):
            reject(lambda: history.modal_font_predecessor(raw, ROOT), "immutable boundary " + name)
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside", "off-path dispatch preserved")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restores without success cache")

    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    before, before_errors = ja.parse_ui_calls(path, prior.decode())
    ordered = lambda calls: sorted(calls, key=lambda c: (c.path, c.line, c.api))
    semantics = lambda calls: [(c.path, c.function, c.api, c.korean, c.english, c.context_id) for c in ordered(calls)]
    check(not actual_errors and not before_errors and semantics(actual) == semantics(before),
          "all Korean/English keys, functions, identities and call order unchanged")
    shifts = [a.line - b.line for a, b in zip(ordered(actual), ordered(before))]
    check(set(shifts) <= {0, 2, 4} and 2 in shifts and 4 in shifts, "actual two consumer line shifts")
    # One real collector call exercises the seal, current call rebinding and
    # migrated-context metadata that raw-only helper tests cannot cover.
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == tuple(ordered(actual))
          and "migrated_context_ids" in inventory.stats, "actual collector and migrated contexts intact")
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(ja.modal_rebind_inventory(baseline, raw) == inventory,
          "whole collector identity/blueprint/context/stats roundtrip")

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in (prior, pre390, pre386, old)),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    for index, view in enumerate(views):
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)), "manifest stage " + str(index))
    check(source == preserved, "actual source inventory never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1],
           "source_manifest_sha256": append.exchange.digest(views[1])}, append.exchange.digest(views[1])),
           "historical raw cannot masquerade as actual current source")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(views[1])), "forged current census")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor,
          "source_manifest_sha256": append.exchange.digest(neighbor)}, append.exchange.digest(views[1])),
          "unowned source difference never exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof disappeared")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[1])),
               "old official header still requires fresh source proof")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed files unchanged")
    return failures, cases


# BEGIN_PEOPLE_CARD_HEIGHT_SELF_TEST_402
def people_card_height_self_test() -> tuple[list[str], int]:
    """Current402 local height only; no historical self suites or split replay."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("people card height: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, pre393, pre390, pre386, old = history._people_card_height_proof(raw, ROOT)
    check(tuple(sha(v) for v in (raw, prior, pre393, pre390, pre386, old)) == (
        "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "independent current/pre402/pre393/pre390/pre386/pre381 raw pins")
    check(history.people_card_height_predecessor(raw, ROOT) == prior
          and history.pad_hint_font_predecessor(raw, ROOT) == pre393
          and history.tutorial_copy_predecessor(raw, ROOT) == pre390
          and history.investment_footer_predecessor(raw, ROOT) == pre386
          and history.modal_font_predecessor(raw, ROOT) == old, "all direct predecessor contracts")
    reject(lambda: history._pad_hint_font_proof(raw, ROOT), "original393 still rejects non393 current raw")
    for code, marker in (("tools/main_game_locale_history.py", b"# BEGIN_PEOPLE_CARD_HEIGHT_HISTORY_402"),
                         ("tools/ui_translation_append.py", b"# BEGIN_PEOPLE_CARD_HEIGHT_MANIFEST_402"),
                         ("tools/ui_translation_append_self_test.py", b"# BEGIN_PEOPLE_CARD_HEIGHT_SELF_TEST_402")):
        current_code = (ROOT / code).read_bytes()
        original = append._git(ROOT, "show", history.PEOPLE_CARD_BEFORE_COMMIT + ":" + code)
        if code.endswith("_self_test.py"):
            original = original.split(b"def main() -> int:")[0].rstrip(b"\n") + b"\n"
        check(current_code.splitlines().count(marker) == 1 and current_code.split(marker)[0].rstrip(b"\n") + b"\n" == original,
              "complete older code/pins preserved: " + code)
    check(history._people_card_height_inverse(raw, prior) == prior, "pure local inverse")
    intermediate = append._git(ROOT, "show", history.PEOPLE_CARD_AFTER_COMMIT + ":" + path)
    check(sha(intermediate) == "b8a03419633a837b5493ddc22569c6f256ac91e602551eb5327cf0e71dabb881",
          "failed first candidate retained as exact checkpoint")
    reject(lambda: history.people_card_height_predecessor(intermediate, ROOT), "failed checkpoint is not current")
    for label, previous, following, replacement in (
            ("initial", prior, intermediate, history.PEOPLE_CARD_INITIAL_REPLACEMENT),
            ("repair", intermediate, raw, history.PEOPLE_CARD_REPAIR_REPLACEMENT)):
        check(history._people_card_height_step_inverse(following, previous, replacement) == previous,
              "exact individual product inverse " + label)
        old_hunk, new_hunk = (part.encode() for part in replacement)
        for fault, mutant in (("partial", following.replace(new_hunk, new_hunk[:len(new_hunk)//2], 1)),
                              ("duplicate", following + new_hunk),
                              ("moved", following.replace(new_hunk, old_hunk, 1) + new_hunk),
                              ("neighbor", following + b"\n"), ("rollback", previous)):
            reject(lambda value=mutant, before=previous, pair=replacement:
                   history._people_card_height_step_inverse(value, before, pair), label + " pure " + fault)
    before, after = (part.encode() for part in history.PEOPLE_CARD_REPLACEMENT)
    for label, mutant in (("rollback", prior), ("partial", raw.replace(after, after[:len(after)//2], 1)),
                          ("duplicate", raw + after), ("moved", raw.replace(after, before, 1) + after),
                          ("whitespace", raw + b"\n")):
        reject(lambda value=mutant: history._people_card_height_inverse(value, prior), "pure " + label)
    # Exercise the actual local Atlas-only guard independently of raw hashes.
    guard, changed_guard = b"\tif thumb is AtlasTexture:\n", b"\tif true:\n"
    check(raw.count(guard) == 1, "actual Atlas guard exact1")
    reject(lambda: history._people_card_height_inverse(raw.replace(guard, changed_guard, 1), prior),
           "pure Atlas guard changed")
    for label, line in (
            ("tree/instance guard", b"\t\t\t\t\tif is_instance_valid(btn) and is_instance_valid(child) and btn.is_inside_tree():\n"),
            ("ready hook", b"\t\t\t\tbtn.ready.connect(fit_height, CONNECT_ONE_SHOT)\n"),
            ("minimum change hook", b"\t\t\t\tchild.minimum_size_changed.connect(fit_height)\n")):
        check(raw.count(line) == 1, "lifecycle control exact1 " + label)
        reject(lambda line=line: history._people_card_height_inverse(raw.replace(line, b"", 1), prior),
               "pure removed " + label)
    for label, old_line, new_line in (
            ("common builder", b"btn.custom_minimum_size = Vector2(0, 56)", b"btn.custom_minimum_size = Vector2(0, 57)"),
            ("portrait dimensions", b"else Vector2(42, 42)", b"else Vector2(43, 43)"),
            ("gameplay neighbor", b'\tvar max_promotions := int(GameState.current_job.get("max_promotions", 3))',
             b'\tvar max_promotions := int(GameState.current_job.get("max_promotions", 4))')):
        check(raw.count(old_line) == 1, "control target exact1 " + label)
        reject(lambda a=old_line, b=new_line: history._people_card_height_inverse(raw.replace(a, b, 1), prior),
               "pure unowned " + label)
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " three actual current entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed claim")
        for label, mutant in (("rollback", prior), ("failed checkpoint", intermediate), ("whitespace", raw + b"\n")):
            check(bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for value in (b"", None):
        reject(lambda value=value: history.people_card_height_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.PEOPLE_CARD_REPAIR_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.people_card_height_predecessor(raw, ROOT), label)
    for name in ("PEOPLE_CARD_TREES", "PEOPLE_CARD_REPAIR_TREES"):
        with mock.patch.object(history, name, tuple(reversed(getattr(history, name)))):
            reject(lambda: history.people_card_height_predecessor(raw, ROOT),
                   "valid objects wrong tree binding " + name, "immutable tree differs")
    # Re-sign the malformed parent object so its SHA check cannot mask the
    # direct-parent assertion. All other immutable objects remain actual.
    after_commit = history.PEOPLE_CARD_REPAIR_AFTER_COMMIT
    original = real_git(ROOT, "cat-file", "commit", after_commit)
    parent = b"parent " + history.PEOPLE_CARD_REPAIR_BEFORE_COMMIT.encode()
    check(original.count(parent + b"\n") == 1, "actual product direct parent exact1")
    forged = original.replace(parent, b"parent " + history.PEOPLE_CARD_BEFORE_COMMIT.encode(), 1)
    forged_oid = hashlib.sha1(b"commit " + str(len(forged)).encode() + b"\0" + forged).hexdigest()
    old_block = after_commit.encode() + b" commit " + str(len(original)).encode() + b"\n" + original + b"\n"
    new_block = forged_oid.encode() + b" commit " + str(len(forged)).encode() + b"\n" + forged + b"\n"
    def resigned_parent(where, *args, **kwargs):
        if args[:2] != ("cat-file", "--batch"):
            return real_git(where, *args, **kwargs)
        incoming = kwargs["input"].replace(forged_oid.encode(), after_commit.encode())
        data = real_git(where, *args, **{**kwargs, "input": incoming})
        if data.count(old_block) != 1:
            raise ValueError("parent-control immutable population differs")
        return data.replace(old_block, new_block, 1)
    with mock.patch.object(history, "PEOPLE_CARD_REPAIR_AFTER_COMMIT", forged_oid), \
            mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.people_card_height_predecessor(raw, ROOT),
               "re-signed forged single pre402-to-final parent", "direct parent differs")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside", "off-path dispatch preserved")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restores without success cache")

    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    before_calls, before_errors = ja.parse_ui_calls(path, prior.decode())
    ordered = lambda calls: sorted(calls, key=lambda c: (c.path, c.line, c.api))
    semantics = lambda calls: [(c.path, c.function, c.api, c.korean, c.english, c.context_id) for c in ordered(calls)]
    check(not actual_errors and not before_errors and semantics(actual) == semantics(before_calls),
          "all Korean/English keys, functions, identities and order unchanged")
    shifts = [a.line - b.line for a, b in zip(ordered(actual), ordered(before_calls))]
    expected_shift = after.count(b"\n") - before.count(b"\n")
    check(set(shifts) <= {0, expected_shift} and (expected_shift == 0 or expected_shift in shifts),
          "actual local hunk line shifts only")
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == tuple(ordered(actual))
          and "migrated_context_ids" in inventory.stats, "actual collector and migrated contexts intact")
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(ja.modal_rebind_inventory(baseline, raw) == inventory,
          "whole collector identity/blueprint/context/stats roundtrip")

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in (prior, pre393, pre390, pre386, old)),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    for index, view in enumerate(views):
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)), "manifest stage " + str(index))
    check(source == preserved, "actual source inventory never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1],
           "source_manifest_sha256": append.exchange.digest(views[1])}, append.exchange.digest(views[1])),
           "historical raw cannot masquerade as actual current source")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(views[1])), "forged current census")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor,
          "source_manifest_sha256": append.exchange.digest(neighbor)}, append.exchange.digest(views[1])),
          "unowned source difference never exempted")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("proof disappeared")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[1])),
               "old official header still requires fresh source proof")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed files unchanged")
    return failures, cases
# END_PEOPLE_CARD_HEIGHT_SELF_TEST_402


# BEGIN_AXIS_BADGE_FIT_SELF_TEST_403
def axis_badge_fit_self_test() -> tuple[list[str], int]:
    """Current403 axis-only boundary and single-call manifest equivalence; no historical suites."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    import time
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("axis badge fit: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prior, pre402, pre393, pre390, pre386, old = history._axis_badge_fit_proof(raw, ROOT)
    check(tuple(sha(v) for v in (raw, prior, pre402, pre393, pre390, pre386, old)) == (
        "4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf",
        "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "independent current/pre403/pre402/pre393/pre390/pre386/pre381 raw pins")
    check(history.axis_badge_fit_predecessor(raw, ROOT) == prior
          and history.people_card_height_predecessor(raw, ROOT) == pre402
          and history.pad_hint_font_predecessor(raw, ROOT) == pre393
          and history.tutorial_copy_predecessor(raw, ROOT) == pre390
          and history.investment_footer_predecessor(raw, ROOT) == pre386
          and history.modal_font_predecessor(raw, ROOT) == old, "all direct predecessor contracts")
    reject(lambda: history._people_card_height_proof(raw, ROOT), "original402 still rejects non402 current raw")
    for code, marker in (("tools/main_game_locale_history.py", b"# BEGIN_AXIS_BADGE_FIT_HISTORY_403"),
                         ("tools/ui_translation_append.py", b"# BEGIN_AXIS_BADGE_FIT_MANIFEST_403"),
                         ("tools/ui_translation_append_self_test.py", b"# BEGIN_AXIS_BADGE_FIT_SELF_TEST_403")):
        current_code = (ROOT / code).read_bytes()
        original = append._git(ROOT, "show", history.AXIS_BADGE_BEFORE_COMMIT + ":" + code)
        if code.endswith("_self_test.py"):
            original = original.split(b"\ndef main() -> int:\n")[0].rstrip(b"\n") + b"\n"
        check(current_code.splitlines().count(marker) == 1 and current_code.split(marker)[0].rstrip(b"\n") + b"\n" == original,
              "complete older code/pins preserved: " + code)
    check(history._axis_badge_fit_inverse(raw, prior) == prior, "pure local inverse")
    intermediate = append._git(ROOT, "show", history.PEOPLE_CARD_AFTER_COMMIT + ":" + path)
    check(sha(intermediate) == "b8a03419633a837b5493ddc22569c6f256ac91e602551eb5327cf0e71dabb881",
          "failed402 checkpoint kept as failure")
    before, after = (part.encode() for part in history.AXIS_BADGE_REPLACEMENT)
    for label, mutant in (("rollback", prior), ("partial", raw.replace(after, after[:len(after)//2], 1)),
                          ("duplicate", raw + after), ("moved", raw.replace(after, before, 1) + after),
                          ("whitespace", raw + b"\n"), ("failed402", intermediate)):
        reject(lambda value=mutant: history._axis_badge_fit_inverse(value, prior), "pure " + label)
    for label, original, changed in (
            ("axis clip", b"axis_lbl.clip_text = false", b"axis_lbl.clip_text = true"),
            ("shared label clip", b"\tlabel.clip_text = true", b"\tlabel.clip_text = false"),
            ("badge width", b"axis_badge.custom_minimum_size = Vector2(58, 30)", b"axis_badge.custom_minimum_size = Vector2(59, 30)"),
            ("people lifecycle", b"\t\t\t\tchild.minimum_size_changed.connect(fit_height)\n", b""),
            ("gameplay neighbor", b'\tvar max_promotions := int(GameState.current_job.get("max_promotions", 3))',
             b'\tvar max_promotions := int(GameState.current_job.get("max_promotions", 4))')):
        check(raw.count(original) == 1, "control target exact1 " + label)
        reject(lambda a=original, b=changed: history._axis_badge_fit_inverse(raw.replace(a, b, 1), prior),
               "pure unowned " + label)
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " three actual current entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed claim")
        for label, mutant in (("rollback", prior), ("failed checkpoint", intermediate), ("whitespace", raw + b"\n")):
            check(bool(source(path, mutant)) and project(mutant, path) == mutant
                  and digest(sha(mutant), path, mutant) == sha(mutant), name + " rejects " + label)
    for value in (b"", None):
        reject(lambda value=value: history.axis_badge_fit_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.AXIS_BADGE_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.axis_badge_fit_predecessor(raw, ROOT), label)
    for name in ("AXIS_BADGE_TREES",):
        with mock.patch.object(history, name, tuple(reversed(getattr(history, name)))):
            reject(lambda: history.axis_badge_fit_predecessor(raw, ROOT),
                   "valid objects wrong tree binding " + name, "immutable tree differs")
    # Re-sign the malformed parent object so its SHA check cannot mask the
    # direct-parent assertion. All other immutable objects remain actual.
    after_commit = history.AXIS_BADGE_AFTER_COMMIT
    original = real_git(ROOT, "cat-file", "commit", after_commit)
    parent = b"parent " + history.AXIS_BADGE_BEFORE_COMMIT.encode()
    check(original.count(parent + b"\n") == 1, "actual product direct parent exact1")
    forged = original.replace(parent, b"parent " + history.PEOPLE_CARD_REPAIR_BEFORE_COMMIT.encode(), 1)
    forged_oid = hashlib.sha1(b"commit " + str(len(forged)).encode() + b"\0" + forged).hexdigest()
    old_block = after_commit.encode() + b" commit " + str(len(original)).encode() + b"\n" + original + b"\n"
    new_block = forged_oid.encode() + b" commit " + str(len(forged)).encode() + b"\n" + forged + b"\n"
    def resigned_parent(where, *args, **kwargs):
        if args[:2] != ("cat-file", "--batch"):
            return real_git(where, *args, **kwargs)
        incoming = kwargs["input"].replace(forged_oid.encode(), after_commit.encode())
        data = real_git(where, *args, **{**kwargs, "input": incoming})
        if data.count(old_block) != 1:
            raise ValueError("parent-control immutable population differs")
        return data.replace(old_block, new_block, 1)
    with mock.patch.object(history, "AXIS_BADGE_AFTER_COMMIT", forged_oid), \
            mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.axis_badge_fit_predecessor(raw, ROOT),
               "re-signed wrong direct parent", "direct parent differs")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside", "off-path dispatch preserved")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restores without success cache")

    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    before_calls, before_errors = ja.parse_ui_calls(path, prior.decode())
    ordered = lambda calls: sorted(calls, key=lambda c: (c.path, c.line, c.api))
    semantics = lambda calls: [(c.path, c.function, c.api, c.korean, c.english, c.context_id) for c in ordered(calls)]
    check(not actual_errors and not before_errors and semantics(actual) == semantics(before_calls),
          "all Korean/English keys, functions, identities and order unchanged")
    shifts = [a.line - b.line for a, b in zip(ordered(actual), ordered(before_calls))]
    expected_shift = after.count(b"\n") - before.count(b"\n")
    check(set(shifts) <= {0, expected_shift} and (expected_shift == 0 or expected_shift in shifts),
          "actual local hunk line shifts only")
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == tuple(ordered(actual))
          and "migrated_context_ids" in inventory.stats, "actual collector and migrated contexts intact")
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(ja.modal_rebind_inventory(baseline, raw) == inventory,
          "whole collector identity/blueprint/context/stats roundtrip")

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in (prior, pre402, pre393, pre390, pre386, old)),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    check(len(views) == len({append.exchange.digest(v) for v in views}) == 8,
          "independent exact eight manifest combinations")
    real_proof = history._axis_badge_fit_proof
    new_seconds = legacy_seconds = 0.0
    legacy_calls = 0
    for index, view in enumerate(views):
        expected = append.exchange.digest(view)
        begin = time.monotonic()
        with mock.patch.object(history, "_axis_badge_fit_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, expected), "manifest stage " + str(index))
            check(proof.call_count == 1, "one fresh proof per comparison " + str(index))
        if index != 1:
            new_seconds += time.monotonic() - begin
            begin = time.monotonic()
            with mock.patch.object(history, "_axis_badge_fit_proof", wraps=real_proof) as proof:
                check(append._AXIS_BADGE_OLD_MANIFEST_MATCHES(ROOT, source, expected),
                      "unchanged old wrapper accepts existing combination " + str(index))
                legacy_calls += proof.call_count
            legacy_seconds += time.monotonic() - begin
    check(not append._AXIS_BADGE_OLD_MANIFEST_MATCHES(ROOT, source, append.exchange.digest(views[1])),
          "pre403 is the only added combination")
    print(f"UI_TRANSLATION_APPEND_AXIS_BADGE_MANIFEST_COST comparisons=7 fresh_proof_calls=7 "
          f"legacy_proof_calls={legacy_calls} fresh_seconds={new_seconds:.6f} legacy_seconds={legacy_seconds:.6f}")
    invalid = {"unknown": "0" * 64,
               "failed402": append.exchange.digest({**hashes, path: sha(intermediate)})}
    for index, view in enumerate(views[:-2]):
        invalid["wrong preAruba pair " + str(index)] = append.exchange.digest(
            {**view, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256})
    for label, expected in invalid.items():
        check(not append._source_manifest_matches(ROOT, source, expected), "reject " + label)
        if label in {"unknown", "failed402"}:
            check(not append._AXIS_BADGE_OLD_MANIFEST_MATCHES(ROOT, source, expected),
                  "unchanged old wrapper also rejects " + label)
    check(source == preserved, "actual source inventory never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1],
           "source_manifest_sha256": append.exchange.digest(views[1])}, append.exchange.digest(views[1])),
           "historical raw cannot masquerade as actual current source")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(views[1])), "forged current census")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor,
          "source_manifest_sha256": append.exchange.digest(neighbor)}, append.exchange.digest(views[2])),
          "unowned source difference never exempted")
    with mock.patch.object(append, "aruba_font_predecessor", wraps=append.aruba_font_predecessor) as font:
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
              and font.call_count == 0, "current-Aruba short circuit preserved after fresh MainGame proof")
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[-1]))
              and font.call_count == 1, "preAruba requires separate fresh font proof")
    with mock.patch.object(append, "aruba_font_predecessor", side_effect=OSError("font proof lost")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[-1])),
               "lost Aruba proof rejects old font combination")
    # Every call starts again: passing actual current manifest cannot bypass proof,
    # and a later raw/Git/HEAD fault cannot borrow the previous call's success.
    real_read = Path.read_bytes
    def head_fault(where, *args, **kwargs):
        if args == ("rev-parse", "HEAD:" + path):
            return history.AXIS_BADGE_BLOBS[0].encode() + b"\n"
        return real_git(where, *args, **kwargs)
    def raw_fault(file):
        data = real_read(file)
        return data + b"\n" if file == ROOT / path else data
    faults = (("Git", mock.patch.object(history, "_modal_git", side_effect=OSError("lost after pass"))),
              ("HEAD", mock.patch.object(history, "_modal_git", side_effect=head_fault)),
              ("raw", mock.patch.object(Path, "read_bytes", raw_fault)))
    for label, fault in faults:
        with mock.patch.object(history, "_axis_badge_fit_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
                  and proof.call_count == 1, label + " first call freshly passes")
            with fault:
                reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0])),
                       label + " next call fails")
            check(proof.call_count == 2, label + " next call performed fresh proof")
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
                  and proof.call_count == 3, label + " recovery freshly proves again")
    synthetic = {"source_manifest_sha256": "synthetic"}
    check(append._source_manifest_matches(ROOT, synthetic, "synthetic")
          == append._AXIS_BADGE_OLD_MANIFEST_MATCHES(ROOT, synthetic, "synthetic"),
          "source-hash-free synthetic delegate preserved")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed files unchanged")
    return failures, cases
# END_AXIS_BADGE_FIT_SELF_TEST_403


# BEGIN_PROMOTION_REVIEW_SELF_TEST_406
def promotion_review_self_test() -> tuple[list[str], int]:
    """Current406 pair, collector, retained target and three receipts; no old suites."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    import ja_translation_audit as audit
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("promotion review: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    predecessors = history._promotion_review_copy_proof(raw, ROOT)
    prior, pre403, pre402, pre393, pre390, pre386, old = predecessors
    check(tuple(sha(v) for v in (raw, *predecessors)) == (
        "bda4961c1a377edcaee454b83937c3a580bce029b3a802ef293118f3f2d3823d",
        "4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf",
        "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "independent current and seven predecessor pins")
    for index, name in enumerate(("promotion_review", "axis_badge_fit", "people_card_height",
                                  "pad_hint_font", "tutorial_copy", "investment_footer", "modal_font")):
        check(getattr(history, name + "_predecessor")(raw, ROOT) == predecessors[index],
              "direct predecessor contract " + name)
    reject(lambda: history._axis_badge_fit_proof(raw, ROOT), "original403 still rejects non403 current raw")
    for code, marker in (("tools/main_game_locale_history.py", b"# BEGIN_PROMOTION_REVIEW_HISTORY_406"),
                         ("tools/ui_translation_append.py", b"# BEGIN_PROMOTION_REVIEW_MANIFEST_406"),
                         ("tools/ui_translation_append_self_test.py", b"# BEGIN_PROMOTION_REVIEW_SELF_TEST_406")):
        current_code = (ROOT / code).read_bytes()
        original = append._git(ROOT, "show", history.PROMOTION_BEFORE_COMMIT + ":" + code)
        if code.endswith("_self_test.py"):
            original = original.split(b"\ndef main() -> int:\n")[0]
        check(current_code.splitlines().count(marker) == 1 and current_code.startswith(original)
              and not current_code[len(original):current_code.index(marker)].strip(),
              "entire older code/pins preserved: " + code)
    code = (ROOT / "tools/ja_translation_audit.py").read_bytes()
    a, z = b"# BEGIN_PROMOTION_REVIEW_RETAINED_JA_406\n", b"# END_PROMOTION_REVIEW_RETAINED_JA_406\n\n"
    check(code[:code.index(a)] + code[code.index(z) + len(z):] == append._git(
          ROOT, "show", history.PROMOTION_BEFORE_COMMIT + ":tools/ja_translation_audit.py"),
          "entire older Japanese audit preserved")
    check(history._promotion_review_copy_inverse(raw, prior) == prior, "pure exact anchored inverse")
    before, after = (part.encode() for part in history.PROMOTION_REPLACEMENT)
    intermediate = append._git(ROOT, "show", history.PEOPLE_CARD_AFTER_COMMIT + ":" + path)
    for label, mutant in (
            ("rollback", prior), ("partial", raw.replace(after, after[:len(after)//2], 1)),
            ("duplicate", raw + after), ("moved", raw.replace(after, before, 1) + after),
            ("KO-only", raw.replace(history.PROMOTION_NEW_KO.encode(), history.PROMOTION_OLD_KO.encode(), 1)),
            ("EN-only", raw.replace(history.PROMOTION_NEW_EN.encode(), history.PROMOTION_OLD_EN.encode(), 1)),
            ("condition", raw.replace(b"if tenure >= threshold and perf >= 60:", b"if tenure >= threshold and perf >= 59:", 1)),
            ("neighbor", raw.replace(b'var promo_count = int(GameState.current_job.get("promotion_count", 0))',
                                    b'var promo_count = int(GameState.current_job.get("promotion_count", 1))', 1)),
            ("whitespace", raw + b"\n"), ("failed402", intermediate)):
        check(mutant != raw, "independent control differs " + label)
        reject(lambda value=mutant: history._promotion_review_copy_inverse(value, prior), "pure " + label)
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in
                                  ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected
              and digest(sha(raw), path, raw) == sha(expected), name + " three actual entrances")
        check(digest("0" * 64, path, raw) == "0" * 64, name + " rejects forged observed claim")
    for value in (b"", None):
        reject(lambda value=value: history.promotion_review_predecessor(value, ROOT), "invalid raw type/empty")
    real_git = history._modal_git
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("forged object", ("cat-file", "--batch"), lambda value: value.replace(b"tree ", b"Tree ", 1)),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.PROMOTION_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.promotion_review_predecessor(raw, ROOT), label)
    for name in ("PROMOTION_TREES",):
        with mock.patch.object(history, name, tuple(reversed(getattr(history, name)))):
            reject(lambda: history.promotion_review_predecessor(raw, ROOT),
                   "valid objects wrong tree binding " + name, "immutable tree differs")
    # Re-sign the malformed parent object so its SHA check cannot mask the
    # direct-parent assertion. All other immutable objects remain actual.
    after_commit = history.PROMOTION_AFTER_COMMIT
    original = real_git(ROOT, "cat-file", "commit", after_commit)
    parent = b"parent " + history.PROMOTION_BEFORE_COMMIT.encode()
    check(original.count(parent + b"\n") == 1, "actual product direct parent exact1")
    forged = original.replace(parent, b"parent " + history.PEOPLE_CARD_REPAIR_BEFORE_COMMIT.encode(), 1)
    forged_oid = hashlib.sha1(b"commit " + str(len(forged)).encode() + b"\0" + forged).hexdigest()
    old_block = after_commit.encode() + b" commit " + str(len(original)).encode() + b"\n" + original + b"\n"
    new_block = forged_oid.encode() + b" commit " + str(len(forged)).encode() + b"\n" + forged + b"\n"
    def resigned_parent(where, *args, **kwargs):
        if args[:2] != ("cat-file", "--batch"):
            return real_git(where, *args, **kwargs)
        incoming = kwargs["input"].replace(forged_oid.encode(), after_commit.encode())
        data = real_git(where, *args, **{**kwargs, "input": incoming})
        if data.count(old_block) != 1:
            raise ValueError("parent-control immutable population differs")
        return data.replace(old_block, new_block, 1)
    with mock.patch.object(history, "PROMOTION_AFTER_COMMIT", forged_oid), \
            mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.promotion_review_predecessor(raw, ROOT),
               "re-signed wrong direct parent", "direct parent differs")
    with mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success")):
        check(bool(history.main_game_history_source_errors(path, raw))
              and history.gift_caption_project_bytes(raw, path) == raw, "lost proof fails closed")
        check(history.main_game_history_project_bytes(b"outside", "unowned.gd") == b"outside", "off-path dispatch preserved")
    check(history.modal_font_predecessor(raw, ROOT) == old, "fresh proof restores without success cache")

    actual, parse_errors = ja.parse_ui_calls(path, raw.decode())
    previous_calls, previous_errors = ja.parse_ui_calls(path, prior.decode())
    ordered = lambda calls: tuple(sorted(calls, key=lambda c: (c.path, c.line, c.api)))
    before_calls, actual_calls = ja._promotion_review_call_views(raw)
    check(not parse_errors and not previous_errors and actual_calls == ordered(actual),
          "fresh two-pair view exposes actual source coordinates")
    old_ko, new_ko = history.PROMOTION_OLD_KO, history.PROMOTION_NEW_KO
    expected_prior = tuple(replace(c, korean=new_ko, english=history.PROMOTION_NEW_EN)
                           if c.korean == old_ko else c for c in ordered(previous_calls))
    check(expected_prior == actual_calls, "pre406 versus actual exactly one KO/EN pair, no coordinate change")
    reject(lambda: ja._PROMOTION_OLD_TUTORIAL_CALL_VIEWS(raw), "unchanged390 one-pair body still rejects added change")
    # Independent semantic controls deliberately bypass only the raw/hash gate.
    with mock.patch.object(history, "modal_font_predecessor", return_value=old):
        for label, mutant in (
                ("KO-only", raw.replace(new_ko.encode(), old_ko.encode(), 1)),
                ("EN-only", raw.replace(history.PROMOTION_NEW_EN.encode(), history.PROMOTION_OLD_EN.encode(), 1)),
                ("wrong owner", raw.replace(b"func _open_cat_work():", b"func _unowned_work():", 1)),
                ("duplicate pair", raw + after),
                ("tutorial lost", raw.replace(history.TUTORIAL_NEW_KO.encode(), history.TUTORIAL_OLD_KO.encode(), 1))):
            reject(lambda value=mutant: ja._promotion_review_call_views(value), "semantic " + label,
                   "two selectors")
    inventory = ja.collect_ui_inventory()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == actual_calls
          and "migrated_context_ids" in inventory.stats, "real current collector, coordinates and contexts")
    check(old_ko not in inventory.blueprint and new_ko in inventory.blueprint
          and sum(c.korean == new_ko for c in inventory.calls) == 1
          and history.TUTORIAL_OLD_KO not in inventory.blueprint
          and history.TUTORIAL_NEW_KO in inventory.blueprint, "two old sources absent, both new sources live")
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(ja.modal_rebind_inventory(baseline, raw) == inventory,
          "whole inventory identity/blueprint/context/stats roundtrip")
    # Use the original390 rebinder only on explicit parser comparison tuples.
    # This is not a historical current-source proof or historical test suite.
    with mock.patch.object(ja, "_tutorial_copy_call_views", return_value=(before_calls, ordered(previous_calls))):
        prior_inventory = ja._PROMOTION_OLD_REBIND_INVENTORY(baseline, prior)
    existing = {e.source: e for e in prior_inventory.legacy_entries if e.source != old_ko}
    check(all(replace(e, context=existing[e.source].context) == existing[e.source]
              and inventory.legacy_blueprint[e.source] == prior_inventory.legacy_blueprint[e.source]
              for e in inventory.legacy_entries if e.source in existing)
          and set(existing) == {e.source for e in inventory.legacy_entries if e.source != new_ko}
          and len(inventory.legacy_entries) == len(prior_inventory.legacy_entries),
          "all unowned entries including390 tutorial and branch IDs remain identical")
    check(inventory.planned_context_entries == prior_inventory.planned_context_entries
          and inventory.observed_context_entries == prior_inventory.observed_context_entries
          and inventory.planned_context_blueprint == prior_inventory.planned_context_blueprint
          and inventory.observed_context_blueprint == prior_inventory.observed_context_blueprint,
          "all context layers unchanged")
    old_entry = next(e for e in prior_inventory.legacy_entries if e.source == old_ko)
    new_entry = next(e for e in inventory.legacy_entries if e.source == new_ko)
    check(old_entry.source_hash != new_entry.source_hash and old_entry.key != new_entry.key,
          "new source has fresh identity")
    index = next(i for i, call in enumerate(baseline.calls) if call.path == path)
    for label, calls in (("missing", baseline.calls[:index] + baseline.calls[index + 1:]),
                         ("duplicate", baseline.calls + (baseline.calls[index],)),
                         ("coordinate", baseline.calls[:index] + (replace(baseline.calls[index], line=0),) + baseline.calls[index + 1:])):
        reject(lambda rows=calls: ja.modal_rebind_inventory(replace(baseline, calls=rows), raw),
               label + " supplied predecessor")
    code = (ROOT / "tools/ja_translation_pipeline.py").read_bytes()
    previous_code = ja.promotion_pipeline_predecessor(code)
    check(previous_code == append._git(ROOT, "show", history.PROMOTION_BEFORE_COMMIT + ":tools/ja_translation_pipeline.py"),
          "new appendix inverse restores immutable whole prior collector")
    check(sha(ja.tutorial_pipeline_predecessor(previous_code)) == ja.TUTORIAL_PIPELINE_BEFORE_SHA,
          "historical tutorial entrance gets explicit pre406 byte view only")
    check(sha(ja.nonformat_pipeline_predecessor(code)) == ja.NONFORMAT_BEFORE_SHA
          and sha(ja.current_demo_pipeline_predecessor(code)) == ja.CURRENT_DEMO_BEFORE_SHA,
          "direct older entrances follow new global modal predecessor")
    for label, mutant in (("neighbor", code + b"\n"),
                          ("appendix", code.replace(b"def _promotion_review_call_views(raw):",
                                                   b"def _promotion_review_call_views(raw): # changed", 1)),
                          ("duplicate appendix", code + code[code.index(b"# BEGIN_PROMOTION_REVIEW_COLLECTOR_406\n"):])):
        reject(lambda value=mutant: ja.promotion_pipeline_predecessor(value), "collector self seal " + label)
    targets = audit.read_json(ROOT / "locale/ui_ja.json")
    retained, errors = audit.promotion_retained_ja_entries(inventory, targets)
    check(not errors and set(retained) == {old_ko}, "one exact retained promotion target")
    tutorial, errors = audit.tutorial_retained_ja_entries(inventory, targets)
    check(not errors and set(tutorial) == {history.TUTORIAL_OLD_KO}, "unchanged tutorial retained body accepts current calls")
    combined, errors = audit.retired_relationship_ui_entries(inventory)
    earlier, earlier_errors = audit._PROMOTION_OLD_RETIRED_ENTRIES(inventory)
    check(not errors and not earlier_errors and set(combined) - set(earlier) == {old_ko}
          and {k: combined[k] for k in earlier} == earlier, "retired allowlist adds only exact one key")
    for target in ({**targets, old_ko: "changed"}, {k: v for k, v in targets.items() if k != old_ko}):
        found, errors = audit.promotion_retained_ja_entries(inventory, target)
        check(not found and bool(errors), "changed/missing retired target rejected")
    found, errors = audit.promotion_retained_ja_entries(prior_inventory, targets)
    check(not found and bool(errors), "old live calls cannot masquerade as current")
    for locale in append.CURRENT_LOCALES:
        with mock.patch.object(audit, "read_json", return_value={"accepted": {locale: {append.receipt_id(old_ko): {}}}}):
            found, errors = audit.promotion_retained_ja_entries(inventory, targets)
            check(not found and bool(errors), "retired receipt forbidden " + locale)
    with mock.patch.object(history, "_modal_git", side_effect=lambda where, *args, **kwargs:
                           b"{}" if args[:1] == ("show",) else real_git(where, *args, **kwargs)):
        found, errors = audit.promotion_retained_ja_entries(inventory, targets)
        check(not found and bool(errors), "forged retained Japanese blob rejected")
    for values in ({}, {new_ko: targets[new_ko], "unowned-extra-key": "余分"}):
        errors = []
        audit.walk_blueprint("ui", {new_ko: inventory.blueprint[new_ko]}, values, {new_entry.key: new_entry}, errors)
        check(bool(errors), "original checker still rejects missing/extra target")

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()),
              "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in predecessors),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    check(len(views) == len({append.exchange.digest(v) for v in views}) == 9,
          "independent exact nine manifest combinations")
    real_proof = history._promotion_review_copy_proof
    for index, view in enumerate(views):
        with mock.patch.object(history, "_promotion_review_copy_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)),
                  "manifest stage " + str(index))
            check(proof.call_count == 1, "one fresh proof per comparison " + str(index))
    invalid = {"unknown": "0" * 64,
               "failed402": append.exchange.digest({**hashes, path: sha(intermediate)})}
    for index, view in enumerate(views[:-2]):
        invalid["wrong preAruba pair " + str(index)] = append.exchange.digest(
            {**view, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256})
    for label, expected in invalid.items():
        check(not append._source_manifest_matches(ROOT, source, expected), "reject " + label)
    check(source == preserved, "actual source inventory never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1],
           "source_manifest_sha256": append.exchange.digest(views[1])}, append.exchange.digest(views[1])),
           "historical raw cannot masquerade as actual current source")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64},
           append.exchange.digest(views[1])), "forged current census")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor,
          "source_manifest_sha256": append.exchange.digest(neighbor)}, append.exchange.digest(views[2])),
          "unowned source difference never exempted")
    with mock.patch.object(append, "aruba_font_predecessor", wraps=append.aruba_font_predecessor) as font:
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
              and font.call_count == 0, "current-Aruba short circuit preserved after fresh MainGame proof")
        check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[-1]))
              and font.call_count == 1, "preAruba requires separate fresh font proof")
    with mock.patch.object(append, "aruba_font_predecessor", side_effect=OSError("font proof lost")):
        reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[-1])),
               "lost Aruba proof rejects old font combination")
    # Every call starts again: passing actual current manifest cannot bypass proof,
    # and a later raw/Git/HEAD fault cannot borrow the previous call's success.
    real_read = Path.read_bytes
    def head_fault(where, *args, **kwargs):
        if args == ("rev-parse", "HEAD:" + path):
            return history.PROMOTION_BLOBS[0].encode() + b"\n"
        return real_git(where, *args, **kwargs)
    def raw_fault(file):
        data = real_read(file)
        return data + b"\n" if file == ROOT / path else data
    faults = (("Git", mock.patch.object(history, "_modal_git", side_effect=OSError("lost after pass"))),
              ("HEAD", mock.patch.object(history, "_modal_git", side_effect=head_fault)),
              ("raw", mock.patch.object(Path, "read_bytes", raw_fault)))
    for label, fault in faults:
        with mock.patch.object(history, "_promotion_review_copy_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
                  and proof.call_count == 1, label + " first call freshly passes")
            with fault:
                reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0])),
                       label + " next call fails")
            check(proof.call_count == 2, label + " next call performed fresh proof")
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(views[0]))
                  and proof.call_count == 3, label + " recovery freshly proves again")
    synthetic = {"source_manifest_sha256": "synthetic"}
    check(append._source_manifest_matches(ROOT, synthetic, "synthetic")
          == append._PROMOTION_OLD_MANIFEST_MATCHES(ROOT, synthetic, "synthetic"),
          "source-hash-free synthetic delegate preserved")
    forged_font = {**hashes, append.ARUBA_FONT_PATH: "0" * 64}
    forged_font_digest = append.exchange.digest(forged_font)
    reject(lambda: append._source_manifest_matches(ROOT,
           {"source_hashes": forged_font, "source_manifest_sha256": forged_font_digest}, forged_font_digest),
           "matching current expected cannot bypass actual Aruba census", "Aruba source census")

    # Reuse the real current entry for a one-leaf append comparison. The
    # separate normal production pass owns full collection/history replay.
    leaf = append.exchange.Leaf("ui", new_ko, "runtime:static_ui", (new_ko,),
                                new_entry.source, "ui_static_context", format_template=new_entry.format_template)
    before_ui = append._snapshot(ROOT, history.PROMOTION_AFTER_COMMIT, append.CURRENT_PATHS)
    after_ui = {p: (ROOT / p).read_bytes() for p in append.CURRENT_PATHS}
    narrow = {"leaves": [leaf], "source_manifest_sha256": "comparison supplied by official headers"}
    change = append.validate_append(before_ui, after_ui, narrow)
    check(change["ui_by_locale"] == {locale: 1 for locale in append.CURRENT_LOCALES}
          and change["receipts"] == 3 and change["batches"] == 3,
          "actual three locales append one source-bound target and official receipt each")
    current_head = append._git(ROOT, "rev-parse", "HEAD").decode().strip()
    current_manifest = append._source_manifest(ROOT, current_head)
    for revision, expected in change["source_manifests"].items():
        append._git(ROOT, "merge-base", "--is-ancestor", revision, "HEAD")
        check(append._source_manifest(ROOT, revision) == expected == current_manifest,
              "official header actual Git census and current source unchanged")
    ledger = json.loads(after_ui[append.LEDGER_PATH])
    old_ledger = json.loads(before_ui[append.LEDGER_PATH])
    check(all(append.receipt_id(old_ko) not in ledger["accepted"][locale] for locale in append.CURRENT_LOCALES),
          "old promotion source has zero accepted receipts")
    for locale in append.CURRENT_LOCALES:
        target = json.loads(after_ui["locale/ui_" + locale + ".json"])[new_ko]
        check(ledger["accepted"][locale][leaf.id] == {
              "source_sha256": leaf.source_sha256, "target_sha256": append.exchange.digest(target)},
              "actual current leaf and target freshness " + locale)
        for field in ("source_sha256", "target_sha256"):
            mutant = copy.deepcopy(ledger)
            mutant["accepted"][locale][leaf.id][field] = "0" * 64
            mutant["accepted_sha256"] = append.exchange.digest(mutant["accepted"])
            altered = {**after_ui, append.LEDGER_PATH: _raw(mutant)}
            reject(lambda value=altered: append.validate_append(before_ui, value, narrow),
                   "fresh receipt mismatch " + locale + " " + field, "source/target additions differ")
    first_new = len(old_ledger["batches"])
    for label in ("missing official header", "duplicate batch"):
        mutant = copy.deepcopy(ledger)
        if label == "missing official header":
            mutant["batches"][first_new].pop(append.HEADERS_FIELD)
        else:
            mutant["batches"].append(copy.deepcopy(mutant["batches"][first_new]))
        altered = {**after_ui, append.LEDGER_PATH: _raw(mutant)}
        reject(lambda value=altered: append.validate_append(before_ui, value, narrow), label)
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed files unchanged")
    return failures, cases
# END_PROMOTION_REVIEW_SELF_TEST_406


# BEGIN_CAREER_TENURE_SELF_TEST_409
def career_tenure_self_test() -> tuple[list[str], int]:
    """Current409 two-line repair only; no historical suites or rendered claims."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("career tenure: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    before_commit = "8b62fea21b41802cffbeadee5fb006535b2f86dc"
    after_commit = "8d570d8b26cd834122b890615180d33a6a5c5443"
    check((history.TENURE_BEFORE_COMMIT, history.TENURE_AFTER_COMMIT) == (before_commit, after_commit),
          "independent exact MainGame-only checkpoint pair")
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prefixes = ("MODAL", "JOB_STATUS", "INVESTMENT", "TUTORIAL", "PAD_HINT", "PEOPLE_CARD",
                "PEOPLE_CARD_REPAIR", "AXIS_BADGE", "PROMOTION", "TENURE")
    stages = [tuple(getattr(history, prefix + suffix) for suffix in
                    ("_BEFORE_COMMIT", "_AFTER_COMMIT", "_TREES", "_BLOBS", "_HASHES"))
              for prefix in prefixes]
    real_git = history._modal_git
    trace, batches = [], []
    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        trace.append((args, kwargs.get("input")))
        if args == ("cat-file", "--batch"):
            batches.append(value)
        return value
    with mock.patch.object(history, "_modal_git", side_effect=traced):
        predecessors = history._career_tenure_proof(raw, ROOT)
    prior, pre406, pre403, pre402, pre393, pre390, pre386, old = predecessors
    check(tuple(sha(value) for value in (raw, *predecessors)) == (
        "9eb5c522e8be5f81ee56ba683f9d1db61d2625b38acf96b99169d7b7aed7c976",
        "bda4961c1a377edcaee454b83937c3a580bce029b3a802ef293118f3f2d3823d",
        "4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf",
        "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "current and eight independent predecessor raw pins")
    expected_requests = []
    for before, after, trees, _blobs, _hashes in stages:
        expected_requests.extend((before, after, *trees, before + ":" + path, after + ":" + path))
    check([data for args, data in trace if args == ("cat-file", "--batch")]
          == [("\n".join(expected_requests) + "\n").encode()], "all sixty immutable objects requested once")
    check([args for args, _ in trace if args[:1] == ("diff",)] == [
          ("diff", "--name-status", "-z", before, after) for before, after, *_ in stages],
          "all ten MainGame-only path populations checked")
    expected_ancestry = [("merge-base", "--is-ancestor", stages[i - 1][1], stages[i][0]) for i in range(1, 10)]
    expected_ancestry.append(("merge-base", "--is-ancestor", after_commit, "HEAD"))
    check([args for args, _ in trace if args[:1] == ("merge-base",)] == expected_ancestry,
          "all nine stage links and current HEAD ancestry checked")
    check([args for args, _ in trace if args[:1] == ("rev-parse",)] == [("rev-parse", "HEAD:" + path)],
          "actual current HEAD blob checked")
    for index, name in enumerate(("career_tenure", "promotion_review", "axis_badge_fit", "people_card_height",
                                  "pad_hint_font", "tutorial_copy", "investment_footer", "modal_font")):
        check(getattr(history, name + "_predecessor")(raw, ROOT) == predecessors[index], "predecessor " + name)
    reject(lambda: history._promotion_review_copy_proof(raw, ROOT), "unchanged406 rejects non406 current raw")
    for code, marker in (("tools/main_game_locale_history.py", b"# BEGIN_CAREER_TENURE_HISTORY_409"),
                         ("tools/ui_translation_append.py", b"# BEGIN_CAREER_TENURE_MANIFEST_409"),
                         ("tools/ui_translation_append_self_test.py", b"# BEGIN_CAREER_TENURE_SELF_TEST_409")):
        current_code = (ROOT / code).read_bytes()
        original = append._git(ROOT, "show", before_commit + ":" + code)
        if code.endswith("_self_test.py"):
            original = original.split(b"\ndef main() -> int:\n")[0]
        check(current_code.splitlines().count(marker) == 1 and current_code.startswith(original)
              and not current_code[len(original):current_code.index(marker)].strip(), "older bodies/pins preserved " + code)
    check((ROOT / "tools/ja_translation_audit.py").read_bytes() == append._git(
          ROOT, "show", before_commit + ":tools/ja_translation_audit.py"), "Japanese audit unchanged")
    check(len(history.TENURE_REPLACEMENTS) == 2 and history._career_tenure_inverse(raw, prior) == prior,
          "exact two anchored changes inverse to actual predecessor")
    for index, (before, after) in enumerate(history.TENURE_REPLACEMENTS):
        before, after = before.encode(), after.encode()
        for label, mutant in (("partial", raw.replace(after, after[:len(after)//2], 1)),
                              ("rollback one", raw.replace(after, before, 1)), ("duplicate", raw + after),
                              ("moved", raw.replace(after, before, 1) + after)):
            reject(lambda value=mutant: history._career_tenure_inverse(value, prior), "hunk " + str(index) + " " + label)
    for label, source, target in (
            ("tenure floor", b"tenure_lbl.custom_minimum_size = Vector2(36, 0)", b"tenure_lbl.custom_minimum_size = Vector2(37, 0)"),
            ("months floor", b"months_lbl.custom_minimum_size = Vector2(72, 0)", b"months_lbl.custom_minimum_size = Vector2(73, 0)"),
            ("row separation", b'tenure_row.add_theme_constant_override("separation", 8)', b'tenure_row.add_theme_constant_override("separation", 9)'),
            ("wrong label", b"tenure_lbl.clip_text = false", b"months_lbl.clip_text = false"),
            ("clip retained", b"tenure_lbl.clip_text = false", b"tenure_lbl.clip_text = true"),
            ("condition", b"if tenure >= threshold and perf >= 60:", b"if tenure >= threshold and perf > 60:"),
            ("Korean source", history.TENURE_KO.encode(), (history.TENURE_KO + " ").encode())):
        check(raw.count(source) == 1, "negative control exact1 " + label)
        reject(lambda a=source, b=target: history._career_tenure_inverse(raw.replace(a, b, 1), prior), "unowned " + label)
    for label, mutant in (("whole rollback", prior), ("whitespace", raw + b"\n"), ("invalid type", None)):
        reject(lambda value=mutant: history.career_tenure_predecessor(value, ROOT), label)
    # Corrupt one actual immutable commit payload at each of the ten stages.
    # This is a scoped Git-output fault; real objects/repository are never edited.
    batch = batches[0]
    offsets, cursor = [], 0
    for _ in range(60):
        end = batch.index(b"\n", cursor)
        size = int(batch[cursor:end].split()[2])
        offsets.append(end + 1)
        cursor = end + 2 + size
    check(cursor == len(batch), "actual sixty-object output decoded exactly")
    for stage, prefix in enumerate(prefixes):
        offset = offsets[stage * 6 + 1]
        mutant = batch[:offset] + bytes([batch[offset] ^ 1]) + batch[offset + 1:]
        with mock.patch.object(history, "_modal_git", side_effect=lambda where, *args, altered=mutant, **kw:
                               altered if args == ("cat-file", "--batch") else real_git(where, *args, **kw)):
            reject(lambda: history._career_tenure_proof(raw, ROOT), "immutable stage " + prefix, "forged immutable object")
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.TENURE_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.career_tenure_predecessor(raw, ROOT), label)
    for target in expected_ancestry:
        def unavailable(where, *args, **kwargs):
            if args == target:
                raise ValueError("synthetic unavailable ancestor")
            return real_git(where, *args, **kwargs)
        with mock.patch.object(history, "_modal_git", side_effect=unavailable):
            reject(lambda: history.career_tenure_predecessor(raw, ROOT), "ancestor " + target[-1], "unavailable ancestor")
    with mock.patch.object(history, "TENURE_TREES", tuple(reversed(history.TENURE_TREES))):
        reject(lambda: history.career_tenure_predecessor(raw, ROOT), "valid objects wrong tree", "immutable tree differs")
    original = real_git(ROOT, "cat-file", "commit", after_commit)
    parent = b"parent " + before_commit.encode()
    check(original.count(parent + b"\n") == 1, "actual direct parent exact1")
    forged = original.replace(parent, b"parent " + history.PROMOTION_BEFORE_COMMIT.encode(), 1)
    forged_oid = hashlib.sha1(b"commit " + str(len(forged)).encode() + b"\0" + forged).hexdigest()
    old_block = after_commit.encode() + b" commit " + str(len(original)).encode() + b"\n" + original + b"\n"
    new_block = forged_oid.encode() + b" commit " + str(len(forged)).encode() + b"\n" + forged + b"\n"
    def resigned_parent(where, *args, **kwargs):
        if args != ("cat-file", "--batch"):
            return real_git(where, *args, **kwargs)
        incoming = kwargs["input"].replace(forged_oid.encode(), after_commit.encode())
        data = real_git(where, *args, **{**kwargs, "input": incoming})
        if data.count(old_block) != 1:
            raise ValueError("parent-control population differs")
        return data.replace(old_block, new_block, 1)
    with mock.patch.object(history, "TENURE_AFTER_COMMIT", forged_oid), mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.career_tenure_predecessor(raw, ROOT), "re-signed wrong parent", "direct parent differs")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected and digest(sha(raw), path, raw) == sha(expected), name + " current entrances")
        check(bool(source(path, prior)) and project(prior, path) == prior and digest("0" * 64, path, raw) == "0" * 64,
              name + " rollback/unbound hash fail closed")

    ordered = lambda calls: tuple(sorted(calls, key=lambda c: (c.path, c.line, c.api)))
    prior_calls, prior_errors = ja.parse_ui_calls(path, prior.decode())
    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    pre381_calls, actual_calls = ja._career_tenure_call_views(raw)
    prior_calls = ordered(prior_calls)
    check(not prior_errors and not actual_errors and actual_calls == ordered(actual), "actual parser/current view coordinates")
    clip_line = raw[:raw.index(b"\t\t\ttenure_lbl.clip_text = false\n")].count(b"\n") + 1
    expected_calls = tuple(replace(call, english=history.TENURE_NEW_EN if call.korean == history.TENURE_KO else call.english,
                                   line=call.line + (call.line >= clip_line)) for call in prior_calls)
    check(expected_calls == actual_calls and sum(c.korean == history.TENURE_KO for c in actual_calls) == 1,
          "same Korean selectors/order, one English update, exact insertion-line shift")
    with mock.patch.object(history, "modal_font_predecessor", return_value=old):
        for label, mutant in (("old English", raw.replace(history.TENURE_NEW_EN.encode(), history.TENURE_OLD_EN.encode(), 1)),
                              ("new Korean", raw.replace(history.TENURE_KO.encode(), (history.TENURE_KO + " ").encode(), 1)),
                              ("wrong owner", raw.replace(b"func _open_cat_work():", b"func _unowned_work():", 1))):
            reject(lambda value=mutant: ja._career_tenure_call_views(value), "semantic-only " + label)
    inventory = ja.collect_ui_inventory()
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == actual_calls
          and ja.modal_rebind_inventory(baseline, raw) == inventory, "actual full collector rebinding")
    with mock.patch.object(ja, "_promotion_review_call_views", return_value=(pre381_calls, prior_calls)):
        prior_inventory = ja._TENURE_OLD_REBIND_INVENTORY(baseline, prior)
    old_entries = {e.source: e for e in prior_inventory.legacy_entries}
    new_entries = {e.source: e for e in inventory.legacy_entries}
    check(set(old_entries) == set(new_entries) and inventory.legacy_blueprint == prior_inventory.legacy_blueprint
          and all(replace(entry, context=old_entries[key].context) == old_entries[key] for key, entry in new_entries.items()),
          "all legacy source/key/format identities and selection set unchanged except context coordinates")
    expected_contexts = {e.source: e.context for e in ja._gift_caption_inventory_view(prior_inventory, inventory.calls).legacy_entries}
    check(all(entry.context == expected_contexts[key] for key, entry in new_entries.items()), "every context uses actual source coordinates")
    for field in ("planned_context_entries", "observed_context_entries", "planned_context_blueprint", "observed_context_blueprint", "stats"):
        check(getattr(inventory, field) == getattr(prior_inventory, field), "unchanged context layer " + field)
    leaf = lambda entry: append.exchange.Leaf("ui", entry.source, "runtime:static_ui", (entry.source,), entry.source,
                                               "ui_static_context", format_template=entry.format_template)
    check({key: (leaf(e).id, leaf(e).source_sha256) for key, e in old_entries.items()} ==
          {key: (leaf(e).id, leaf(e).source_sha256) for key, e in new_entries.items()}, "every Korean-source leaf identity unchanged")
    code = (ROOT / "tools/ja_translation_pipeline.py").read_bytes()
    check(ja.career_tenure_pipeline_predecessor(code) == append._git(ROOT, "show", before_commit + ":tools/ja_translation_pipeline.py"),
          "collector appendix inverse preserves complete old module")
    for label, mutant in (("neighbor", code + b"\n"), ("appendix", code.replace(b"def _career_tenure_call_views(raw):", b"def _career_tenure_call_views(raw): # changed", 1))):
        check(mutant != code, "collector control differs " + label)
        reject(lambda value=mutant: ja.career_tenure_pipeline_predecessor(value), "collector seal " + label)
    before_ui = append._snapshot(ROOT, before_commit, append.CURRENT_PATHS)
    after_ui = {p: (ROOT / p).read_bytes() for p in append.CURRENT_PATHS}
    check(after_ui == before_ui, "all three dictionaries and whole official receipt/header ledger byte-identical")
    ledger = json.loads(after_ui[append.LEDGER_PATH])
    check(sum(len(rows) for rows in ledger["accepted"].values()) == 41152 and len(ledger["batches"]) == 178
          and ledger["accepted_sha256"] == append.exchange.digest(ledger["accepted"]), "accepted41152/batches178 and checksum preserved")
    for locale in ("zh-CN", "zh-TW"):
        entry = new_entries[history.TENURE_KO]
        target = json.loads(after_ui["locale/ui_" + locale + ".json"])[history.TENURE_KO]
        check(ledger["accepted"][locale][leaf(entry).id] == {"source_sha256": leaf(entry).source_sha256,
              "target_sha256": append.exchange.digest(target)}, "existing unchanged source/target receipt " + locale)

    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()), "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in predecessors),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    check(len(views) == len({append.exchange.digest(view) for view in views}) == 10, "exact ten manifest views")
    real_proof = history._career_tenure_proof
    for index, view in enumerate(views):
        with mock.patch.object(history, "_career_tenure_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)) and proof.call_count == 1,
                  "one fresh proof for allowed manifest " + str(index))
    intermediate = append._git(ROOT, "show", history.PEOPLE_CARD_AFTER_COMMIT + ":" + path)
    invalid = ["0" * 64, append.exchange.digest({**hashes, path: sha(intermediate)})]
    invalid += [append.exchange.digest({**view, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}) for view in views[:-2]]
    for index, expected in enumerate(invalid):
        check(not append._source_manifest_matches(ROOT, source, expected), "unknown/failed402/wrong-font manifest " + str(index))
    check(source == preserved, "actual census never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1], "source_manifest_sha256": append.exchange.digest(views[1])},
                                                   append.exchange.digest(views[1])), "historical raw masquerading as current")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64}, append.exchange.digest(hashes)), "forged census digest")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor, "source_manifest_sha256": append.exchange.digest(neighbor)},
                                              append.exchange.digest(views[1])), "unowned source difference not exempted")
    forged_font = {**hashes, append.ARUBA_FONT_PATH: "0" * 64}
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": forged_font, "source_manifest_sha256": append.exchange.digest(forged_font)},
                                                   append.exchange.digest(forged_font)), "current expected cannot bypass Aruba raw census", "Aruba source census")
    real_read = Path.read_bytes
    def head_fault(where, *args, **kwargs):
        return history.TENURE_BLOBS[0].encode() + b"\n" if args == ("rev-parse", "HEAD:" + path) else real_git(where, *args, **kwargs)
    def raw_fault(file):
        value = real_read(file)
        return value + b"\n" if file == ROOT / path else value
    for label, fault in (("Git", mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success"))),
                         ("HEAD", mock.patch.object(history, "_modal_git", side_effect=head_fault)),
                         ("raw", mock.patch.object(Path, "read_bytes", raw_fault))):
        with mock.patch.object(history, "_career_tenure_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " first success")
            with fault:
                reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " fresh failure")
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)) and proof.call_count == 3,
                  label + " fresh recovery, no cross-call cache")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed source/dictionary/receipt bytes unchanged")
    return failures, cases
# END_CAREER_TENURE_SELF_TEST_409


# BEGIN_GIFT_PRICE_BADGE_SELF_TEST_412
def gift_price_badge_self_test() -> tuple[list[str], int]:
    """Current412 only: real immutable admission plus scoped fault controls."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("gift price badge: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    before_commit = "45386ccac552962e04ad377f3e92b263475a73ea"
    after_commit = "50d5e3586d05e141439ce5e59d18466a9ffc523c"
    check((history.GIFT_PRICE_BEFORE_COMMIT, history.GIFT_PRICE_AFTER_COMMIT) == (before_commit, after_commit),
          "independent MainGame-only checkpoint pair")
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prefixes = ("MODAL", "JOB_STATUS", "INVESTMENT", "TUTORIAL", "PAD_HINT", "PEOPLE_CARD",
                "PEOPLE_CARD_REPAIR", "AXIS_BADGE", "PROMOTION", "TENURE", "GIFT_PRICE")
    stages = [tuple(getattr(history, prefix + suffix) for suffix in
                    ("_BEFORE_COMMIT", "_AFTER_COMMIT", "_TREES", "_BLOBS", "_HASHES")) for prefix in prefixes]
    real_git = history._modal_git
    trace, batches = [], []
    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        trace.append((args, kwargs.get("input")))
        if args == ("cat-file", "--batch"):
            batches.append(value)
        return value
    with mock.patch.object(history, "_modal_git", side_effect=traced):
        predecessors = history._gift_price_badge_proof(raw, ROOT)
    prior, old = predecessors[0], predecessors[-1]
    check(tuple(sha(value) for value in (raw, *predecessors)) == (
        "2e4cb063d12de4b35abad634df1bdb8772c358b3eead7b030a781d3b86c43433",
        "9eb5c522e8be5f81ee56ba683f9d1db61d2625b38acf96b99169d7b7aed7c976",
        "bda4961c1a377edcaee454b83937c3a580bce029b3a802ef293118f3f2d3823d",
        "4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf",
        "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
        "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
        "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
        "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
        "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
        "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
        "current and nine independent predecessor raw pins")
    expected_requests = []
    for before, after, trees, _blobs, _hashes in stages:
        expected_requests.extend((before, after, *trees, before + ":" + path, after + ":" + path))
    check([data for args, data in trace if args == ("cat-file", "--batch")]
          == [("\n".join(expected_requests) + "\n").encode()], "all sixty-six immutable objects requested once")
    check([args for args, _ in trace if args[:1] == ("diff",)] == [
          ("diff", "--name-status", "-z", before, after) for before, after, *_ in stages], "eleven exact MainGame path populations")
    ancestry = [("merge-base", "--is-ancestor", stages[i - 1][1], stages[i][0]) for i in range(1, 11)]
    ancestry.append(("merge-base", "--is-ancestor", after_commit, "HEAD"))
    check([args for args, _ in trace if args[:1] == ("merge-base",)] == ancestry, "ten stage links and current HEAD ancestry")
    check([args for args, _ in trace if args[:1] == ("rev-parse",)] == [("rev-parse", "HEAD:" + path)], "actual HEAD blob checked")
    for index, name in enumerate(("gift_price_badge", "career_tenure", "promotion_review", "axis_badge_fit", "people_card_height",
                                  "pad_hint_font", "tutorial_copy", "investment_footer", "modal_font")):
        check(getattr(history, name + "_predecessor")(raw, ROOT) == predecessors[index], "public predecessor " + name)
    reject(lambda: history._career_tenure_proof(raw, ROOT), "unchanged409 proof rejects new current raw")
    for code, marker, digest in (
            ("tools/main_game_locale_history.py", b"# BEGIN_GIFT_PRICE_BADGE_HISTORY_412", "f1f8335b21bd759a4f2be47e7efab1cae2dfe3a876c355cc7420fa7188a40135"),
            ("tools/ui_translation_append.py", b"# BEGIN_GIFT_PRICE_BADGE_MANIFEST_412", "587c31c4a4778b9e08fff4c2a6a1ab8b123658e7ddaec802af20ca9944580c7f"),
            ("tools/ui_translation_append_self_test.py", b"# BEGIN_GIFT_PRICE_BADGE_SELF_TEST_412", "a4c659f01bf955797e0bdf8eab0ed727c10df92b6b2bf12c814c95297c2c27e7")):
        previous = append._git(ROOT, "show", before_commit + ":" + code)
        check(sha(previous) == digest, "independent old module hash " + code)
        if code.endswith("_self_test.py"):
            previous = previous.split(b"\ndef main() -> int:\n")[0]
        current = (ROOT / code).read_bytes()
        check(current.splitlines().count(marker) == 1 and current.startswith(previous)
              and not current[len(previous):current.index(marker)].strip(), "all old bodies/pins preserved " + code)
    for code, digest in (("tools/ja_translation_pipeline.py", "55a3b65670765fdf8aedb75e78fbbd94b0306e97f873c5e4a8580b9e171e9e27"),
                         ("tools/ja_translation_audit.py", "9212613d345be575ce262fd8f5aefac180d3280b9629c513ad33e0702ac591b4")):
        check((ROOT / code).read_bytes() == append._git(ROOT, "show", before_commit + ":" + code)
              and sha((ROOT / code).read_bytes()) == digest, "unchanged whole collector/audit " + code)
    check(history._gift_price_badge_inverse(raw, prior) == prior, "pure exact inverse recovers actual pre412")
    old_anchor, new_anchor = (part.encode() for part in history.GIFT_PRICE_REPLACEMENT)
    addition = b'\tif icon_id == "shop" and not forced_badge.is_empty():\n\t\tbadge_lbl.clip_text = false\n'
    check(raw.count(addition) == 1 and raw.replace(addition, b"", 1) == prior, "independent exact two-line inverse")
    for label, mutant in (("partial", raw.replace(new_anchor, new_anchor[:-2], 1)), ("rollback", prior),
                          ("duplicate", raw + new_anchor), ("moved", raw.replace(new_anchor, old_anchor, 1) + new_anchor),
                          ("whitespace", raw + b"\n"), ("invalid type", None)):
        reject(lambda value=mutant: history._gift_price_badge_inverse(value, prior), "pure boundary " + label)
    body = ja._gd_function_source(raw.decode(), "_make_essential_action_card").encode()
    for label, before, after in (
            ("icon narrowed wrongly", b'icon_id == "shop" and not forced_badge.is_empty()', b'icon_id == "life" and not forced_badge.is_empty()'),
            ("forced condition removed", b'icon_id == "shop" and not forced_badge.is_empty()', b'icon_id == "shop"'),
            ("condition broadened", b'icon_id == "shop" and not forced_badge.is_empty()', b'icon_id == "shop" or not forced_badge.is_empty()'),
            ("condition negated", b'icon_id == "shop" and not forced_badge.is_empty()', b'icon_id == "shop" and forced_badge.is_empty()'),
            ("wrong label", b'badge_lbl.clip_text = false', b'title_lbl.clip_text = false'),
            ("clip retained", b'badge_lbl.clip_text = false', b'badge_lbl.clip_text = true'),
            ("badge floor", b'badge.custom_minimum_size = Vector2(62, 30)', b'badge.custom_minimum_size = Vector2(63, 30)'),
            ("padding", b'badge_style.content_margin_left = 8', b'badge_style.content_margin_left = 9'),
            ("font request", b'_label(badge_text, 11,', b'_label(badge_text, 12,'),
            ("card height", b'btn.custom_minimum_size = Vector2(0, 56)', b'btn.custom_minimum_size = Vector2(0, 57)')):
        check(body.count(before) == 1 and raw.count(body) == 1, "exact mutation location " + label)
        reject(lambda a=before, b=after: history._gift_price_badge_inverse(raw.replace(body, body.replace(a, b, 1), 1), prior), "unowned " + label)
    # Scoped Git-output doubles below test control flow; above is actual object admission.
    batch = batches[0]
    offsets, cursor = [], 0
    for _ in range(66):
        end = batch.index(b"\n", cursor)
        size = int(batch[cursor:end].split()[2])
        offsets.append(end + 1)
        cursor = end + 2 + size
    check(cursor == len(batch), "sixty-six actual objects decoded exactly")
    for stage, prefix in enumerate(prefixes):
        offset = offsets[stage * 6 + 1]
        mutant = batch[:offset] + bytes([batch[offset] ^ 1]) + batch[offset + 1:]
        with mock.patch.object(history, "_modal_git", side_effect=lambda where, *args, altered=mutant, **kw:
                               altered if args == ("cat-file", "--batch") else real_git(where, *args, **kw)):
            reject(lambda: history._gift_price_badge_proof(raw, ROOT), "immutable stage " + prefix, "forged immutable object")
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.GIFT_PRICE_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.gift_price_badge_predecessor(raw, ROOT), label)
    for target in ancestry:
        def unavailable(where, *args, **kwargs):
            if args == target:
                raise ValueError("synthetic unavailable ancestor")
            return real_git(where, *args, **kwargs)
        with mock.patch.object(history, "_modal_git", side_effect=unavailable):
            reject(lambda: history.gift_price_badge_predecessor(raw, ROOT), "ancestor " + target[-1], "unavailable ancestor")
    with mock.patch.object(history, "GIFT_PRICE_TREES", tuple(reversed(history.GIFT_PRICE_TREES))):
        reject(lambda: history.gift_price_badge_predecessor(raw, ROOT), "valid objects wrong tree", "immutable tree differs")
    original = real_git(ROOT, "cat-file", "commit", after_commit)
    parent = b"parent " + before_commit.encode()
    check(original.count(parent + b"\n") == 1, "direct parent independently observed")
    forged = original.replace(parent, b"parent " + history.TENURE_BEFORE_COMMIT.encode(), 1)
    forged_oid = hashlib.sha1(b"commit " + str(len(forged)).encode() + b"\0" + forged).hexdigest()
    old_block = after_commit.encode() + b" commit " + str(len(original)).encode() + b"\n" + original + b"\n"
    new_block = forged_oid.encode() + b" commit " + str(len(forged)).encode() + b"\n" + forged + b"\n"
    def resigned_parent(where, *args, **kwargs):
        if args != ("cat-file", "--batch"):
            return real_git(where, *args, **kwargs)
        incoming = kwargs["input"].replace(forged_oid.encode(), after_commit.encode())
        data = real_git(where, *args, **{**kwargs, "input": incoming})
        if data.count(old_block) != 1:
            raise ValueError("parent-control population differs")
        return data.replace(old_block, new_block, 1)
    with mock.patch.object(history, "GIFT_PRICE_AFTER_COMMIT", forged_oid), mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.gift_price_badge_predecessor(raw, ROOT), "re-signed wrong parent", "direct parent differs")
    for name, previous in (("main_game_history", history._MODAL_OLD_PUBLIC), ("gift_caption", history._MODAL_OLD_GIFT)):
        source, project, digest = (getattr(history, name + suffix) for suffix in ("_source_errors", "_project_bytes", "_project_byte_hash"))
        expected = previous[1](old, path)
        check(not source(path, raw) and project(raw, path) == expected and digest(sha(raw), path, raw) == sha(expected), name + " current entrances")
        check(bool(source(path, prior)) and project(prior, path) == prior and digest("0" * 64, path, raw) == "0" * 64,
              name + " rollback/unbound hash fail closed")
    ordered = lambda calls: tuple(sorted(calls, key=lambda c: (c.path, c.line, c.api)))
    prior_calls, prior_errors = ja.parse_ui_calls(path, prior.decode())
    actual, actual_errors = ja.parse_ui_calls(path, raw.decode())
    prior_calls, actual = ordered(prior_calls), ordered(actual)
    clip_line = raw[:raw.index(addition)].count(b"\n") + 1
    check(not prior_errors and not actual_errors and actual == tuple(replace(c, line=c.line + 2 * (c.line >= clip_line)) for c in prior_calls),
          "entire collector map has same KO/EN/key/owner and exact two-line coordinate shift")
    pre381_calls, current_calls = ja._career_tenure_call_views(raw)
    check(current_calls == actual, "unchanged409 collector accepts current coordinates through public predecessor")
    inventory = ja.collect_ui_inventory()
    baseline = ja._MODAL_LOCATION_OLD_COLLECT()
    check(not inventory.errors and tuple(c for c in inventory.calls if c.path == path) == actual
          and ja.modal_rebind_inventory(baseline, raw) == inventory, "actual whole current collector/rebinding")
    # Comparison-only prior inventory, never an admission substitute.
    with mock.patch.object(history, "modal_font_predecessor", return_value=old):
        prior_inventory = ja.modal_rebind_inventory(baseline, prior)
    old_entries = {e.source: e for e in prior_inventory.legacy_entries}
    new_entries = {e.source: e for e in inventory.legacy_entries}
    check(set(old_entries) == set(new_entries) and inventory.legacy_blueprint == prior_inventory.legacy_blueprint
          and all(replace(e, context=old_entries[key].context) == old_entries[key] for key, e in new_entries.items()), "all legacy identities unchanged")
    expected_contexts = {e.source: e.context for e in ja._gift_caption_inventory_view(prior_inventory, inventory.calls).legacy_entries}
    check(all(e.context == expected_contexts[key] for key, e in new_entries.items()), "every context uses actual current coordinates")
    for field in ("planned_context_entries", "observed_context_entries", "planned_context_blueprint", "observed_context_blueprint", "stats"):
        check(getattr(inventory, field) == getattr(prior_inventory, field), "unchanged semantic context layer " + field)
    leaf = lambda e: append.exchange.Leaf("ui", e.source, "runtime:static_ui", (e.source,), e.source, "ui_static_context", format_template=e.format_template)
    check({k: (leaf(e).id, leaf(e).source_sha256) for k, e in old_entries.items()} ==
          {k: (leaf(e).id, leaf(e).source_sha256) for k, e in new_entries.items()}, "every Korean leaf/source hash unchanged")
    before_ui = append._snapshot(ROOT, before_commit, append.CURRENT_PATHS)
    after_ui = {p: (ROOT / p).read_bytes() for p in append.CURRENT_PATHS}
    check(after_ui == before_ui, "three dictionaries and whole official header/receipt ledger byte-identical")
    ledger = json.loads(after_ui[append.LEDGER_PATH])
    check(sum(len(rows) for rows in ledger["accepted"].values()) == 41220 and len(ledger["batches"]) == 182
          and ledger["accepted_sha256"] == append.exchange.digest(ledger["accepted"]), "accepted41220/batches182 and checksum preserved")
    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()), "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in predecessors),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    check(len(views) == len({append.exchange.digest(view) for view in views}) == 11, "exact eleven manifest views")
    real_proof = history._gift_price_badge_proof
    for index, view in enumerate(views):
        with mock.patch.object(history, "_gift_price_badge_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(view)) and proof.call_count == 1, "one fresh proof per allowed manifest " + str(index))
    failed402 = append._git(ROOT, "show", history.PEOPLE_CARD_AFTER_COMMIT + ":" + path)
    invalid = ["0" * 64, append.exchange.digest({**hashes, path: sha(failed402)})]
    invalid += [append.exchange.digest({**view, append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}) for view in views[:-2]]
    for index, expected in enumerate(invalid):
        check(not append._source_manifest_matches(ROOT, source, expected), "unknown/failed402/wrong-font manifest " + str(index))
    check(source == preserved, "source census never rewritten")
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": views[1], "source_manifest_sha256": append.exchange.digest(views[1])},
                                                   append.exchange.digest(views[1])), "historical raw masquerading as current")
    reject(lambda: append._source_manifest_matches(ROOT, {**source, "source_manifest_sha256": "0" * 64}, append.exchange.digest(hashes)), "forged census digest")
    neighbor = {**hashes, "unchanged.json": "0" * 64}
    check(not append._source_manifest_matches(ROOT, {"source_hashes": neighbor, "source_manifest_sha256": append.exchange.digest(neighbor)},
                                              append.exchange.digest(views[1])), "unowned source difference not exempted")
    forged_font = {**hashes, append.ARUBA_FONT_PATH: "0" * 64}
    reject(lambda: append._source_manifest_matches(ROOT, {"source_hashes": forged_font, "source_manifest_sha256": append.exchange.digest(forged_font)},
                                                   append.exchange.digest(forged_font)), "current expected cannot bypass Aruba census", "Aruba source census")
    real_read = Path.read_bytes
    def head_fault(where, *args, **kwargs):
        return history.GIFT_PRICE_BLOBS[0].encode() + b"\n" if args == ("rev-parse", "HEAD:" + path) else real_git(where, *args, **kwargs)
    def raw_fault(file):
        value = real_read(file)
        return value + b"\n" if file == ROOT / path else value
    for label, fault in (("Git", mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success"))),
                         ("HEAD", mock.patch.object(history, "_modal_git", side_effect=head_fault)),
                         ("raw", mock.patch.object(Path, "read_bytes", raw_fault))):
        with mock.patch.object(history, "_gift_price_badge_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " first success")
            with fault:
                reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " next fresh failure")
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)) and proof.call_count == 3, label + " recovery without cross-call cache")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed source/dictionary/receipt bytes unchanged")
    return failures, cases
# END_GIFT_PRICE_BADGE_SELF_TEST_412


# BEGIN_JA_GIFT_COPY_SELF_TEST_414
def ja_gift_copy_self_test() -> tuple[list[str], int]:
    """One real414 transition and narrow faults; no older suite/history replay."""
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("JA gift copy: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label + " rejection boundary: " + str(exc))
        else:
            check(False, label + " was accepted")

    ja, ledger = append.LEGACY_GIFT_PATH, append.LEDGER_PATH
    keys = append.LEGACY_GIFT_KEYS
    leaves = sorted([append.exchange.Leaf("ui", key, "runtime:static_ui", (key,), key, "ui_static_context")
                     for key in keys], key=lambda leaf: leaf.id)
    # Explicit two-leaf fixture and real historical source census. The normal
    # admission owns current full collection/history/HEAD, not this focused run.
    inventory = {"leaves": leaves, "source_manifest_sha256": append._source_manifest(ROOT, append.LEGACY_GIFT_BEFORE_COMMIT)}
    observed = {path: (ROOT / path).read_bytes() for path in (*append.CURRENT_PATHS, "scenes/MainGame.gd")}
    real_objects, real_git = append._objects, append._git
    with mock.patch.object(append, "_objects", wraps=real_objects) as objects:
        before, after, change = append._legacy_ja_gift_proof(ROOT, inventory)
    requests = [request for call in objects.call_args_list for request in call.args[1]]
    check(len(requests) == 13 and [r[2] for r in requests].count("commit") == 2
          and [r[2] for r in requests].count("tree") == 2 and [r[2] for r in requests].count("blob") == 9,
          "actual thirteen immutable objects including legacy origin")
    check((append.LEGACY_GIFT_ORIGIN_COMMIT + ":" + ja, append.LEGACY_GIFT_ORIGIN_BLOB, "blob") in requests,
          "legacy source is an actual pinned origin blob, not an invented prior receipt")
    check(set(before) == set(after) == set(append.CURRENT_PATHS), "four observed snapshots")
    check(change["ui_by_locale"] == {locale: 0 for locale in append.CURRENT_LOCALES}
          and change["receipts"] == change["batches"] == 0 and change["corrections"] == 2
          and change["correction_batches"] == 1 and change["first_receipts"] == 2,
          "zero new UI keys, two corrected values, two first receipts, one correction batch")
    check(append._legacy_ja_gift_comparison(after, before, after) == before, "exact four-file raw inverse")
    check(all(before[p] == after[p] for p in append.UI_PATHS), "Chinese dictionaries byte-identical")
    docs = {p: append._Document(raw) for p, raw in after.items()}
    old = {p: append._Document(raw).value for p, raw in before.items()}
    index = append.LEGACY_GIFT_BATCH_INDEX
    batch = docs[ledger].value["batches"][index]
    check(index == 184 and len(old[ledger]["batches"]) == 184 and len(docs[ledger].value["batches"]) == 185,
          "one actual tail batch")
    check(sum(map(len, old[ledger]["accepted"].values())) == 41250
          and sum(map(len, docs[ledger].value["accepted"].values())) == 41252, "first acceptance population, not new UI coverage")
    check(list(old[ja]) == list(docs[ja].value) and len(old[ja]) == len(docs[ja].value), "existing dictionary keys/order unchanged")
    for leaf in leaves:
        check(leaf.id not in old[ledger]["accepted"]["ja"] and docs[ledger].value["accepted"]["ja"][leaf.id]
              == {"source_sha256": leaf.source_sha256, "target_sha256": append.exchange.digest(append.LEGACY_GIFT_TEXTS[leaf.owner][1])},
              "actual first receipt " + leaf.owner)
    official = append.exchange.make_batch(inventory, "ja", leaves, append.LEGACY_GIFT_BEFORE_COMMIT, {ja: old[ja]}, {})
    check(batch[append.HEADERS_FIELD]["ja"] == official[0] and all(row["previous_target_sha256"]
          == append.exchange.digest(old[ja][row["owner"]]) for row in official[1:]), "official selection binds real legacy target values")
    reject(lambda: append.validate_append(before, after, inventory), "generic append still rejects existing JA edits", "old UI member/order/value changed: ja")

    def edit(snapshot, path, field, value):
        doc = append._Document(snapshot[path])
        start, end = doc.spans[field]
        changes = [(start, end, append._ordered(value).decode())]
        if path == ledger and field[0] == "accepted":
            payload = copy.deepcopy(doc.value)
            target = payload
            for part in field[:-1]: target = target[part]
            target[field[-1]] = value
            start, end = doc.spans[("accepted_sha256",)]
            changes.append((start, end, append._ordered(append.exchange.digest(payload["accepted"])).decode()))
        text = doc.text
        for start, end, value in sorted(changes, reverse=True): text = text[:start] + value + text[end:]
        return {**snapshot, path: text.encode()}

    validate = append._validate_legacy_ja_gift_correction
    inverse = append._legacy_ja_gift_comparison
    for path in append.CURRENT_PATHS:
        reject(lambda p=path: validate(before, {**after, p: after[p] + b"\n"}, inventory), "neighbor raw whitespace " + path)
        reject(lambda p=path: validate({k: raw for k, raw in before.items() if k != p}, after, inventory), "missing snapshot " + path)
    reject(lambda: validate(before, {**after, "outside.json": b"{}"}, inventory), "extra snapshot path")
    for path in (ja, ledger):
        reject(lambda p=path: validate(before, {**after, p: before[p]}, inventory), "partial rollback " + path)
    for key in keys:
        for value in (append.LEGACY_GIFT_TEXTS[key][0], "勝手に変えた説明", "", None):
            reject(lambda k=key, v=value: validate(before, edit(after, ja, (k,), v), inventory), "wrong exact target " + key + repr(value))
        quoted = json.dumps(key, ensure_ascii=False).encode() + b":"
        duplicate = after[ja].replace(quoted, quoted + b' "duplicate", ' + quoted, 1)
        reject(lambda raw=duplicate: validate(before, {**after, ja: raw}, inventory), "raw duplicate target " + key)
    for path in append.CURRENT_UI_PATHS:
        neighbor = next(key for key in docs[path].value if key not in keys)
        reject(lambda p=path, k=neighbor: validate(before, edit(after, p, (k,), "neighbor"), inventory), "unowned locale/neighbor " + path)
    reordered = dict(reversed(list(docs[ja].value.items())))
    reject(lambda: validate(before, {**after, ja: _raw(reordered)}, inventory), "dictionary reorder")
    for leaf in leaves:
        for field in ("source_sha256", "target_sha256"):
            mutant = edit(after, ledger, ("accepted", "ja", leaf.id, field), "0" * 64)
            check(append._loads(mutant[ledger])["accepted_sha256"] == append.exchange.digest(append._loads(mutant[ledger])["accepted"]),
                  "mutant checksum is fresh " + leaf.owner + field)
            reject(lambda v=mutant: validate(before, v, inventory), "checksum-valid false receipt " + leaf.owner + field,
                   "legacy JA gift changed an old receipt/batch or ledger field")
        accepted = dict(docs[ledger].value["accepted"]["ja"])
        accepted.pop(leaf.id)
        reject(lambda v=accepted: validate(before, edit(after, ledger, ("accepted", "ja"), v), inventory), "missing first receipt " + leaf.owner)
    first = leaves[0]
    prior = dict(old[ledger]["accepted"]["ja"])
    prior.pop(next(iter(prior)))  # Keep the total fixed: absence must be checked, not only count.
    prior[first.id] = {"source_sha256": first.source_sha256, "target_sha256": append.exchange.digest(old[ja][first.owner])}
    reject(lambda: validate(edit(before, ledger, ("accepted", "ja"), prior), after, inventory), "fabricated prior accepted receipt",
           "legacy JA gift falsely claims absent prior acceptance")
    fake_history = copy.deepcopy(old[ledger]["batches"][-1])
    fake_history.update(roots=list(keys), target_leaves_by_locale={"ja": 2, "zh-CN": 0, "zh-TW": 0})
    reject(lambda: validate(edit(before, ledger, ("batches", index - 1), fake_history), after, inventory), "fabricated prior Japanese batch",
           "legacy JA gift falsely claims absent prior acceptance")
    accepted = dict(docs[ledger].value["accepted"]["ja"])
    accepted["ui:orphan:/orphan"] = accepted[first.id]
    reject(lambda: validate(before, edit(after, ledger, ("accepted", "ja"), accepted), inventory), "orphan added receipt")
    neighbor = next(key for key in docs[ledger].value["accepted"]["ja"] if key not in {leaf.id for leaf in leaves})
    reject(lambda: validate(before, edit(after, ledger, ("accepted", "ja", neighbor, "target_sha256"), "0" * 64), inventory), "old neighboring receipt")

    for label, field, value in (
        ("old metadata", ("native_review",), "GO"), ("old batch", ("batches", 0, "order"), "forged"),
        ("count bool", ("batches", index, "source_leaves"), True),
        ("JA count bool", ("batches", index, "target_leaves_by_locale", "ja"), True),
        ("wrong locale", ("batches", index, "target_leaves_by_locale", "zh-CN"), 2),
        ("wrong roots", ("batches", index, "roots"), list(reversed(keys))),
        ("wrong group", ("batches", index, "group"), "ui"),
        ("fake old acceptance", ("batches", index, "prior_acceptance"), "accepted"),
        ("fake origin", ("batches", index, "legacy_origin_commit"), "0" * 40),
        ("false previous value", ("batches", index, "before_target_sha256_by_locale", "ja", first.id), "0" * 64),
        ("official digest", ("batches", index, "receipt_sha256_by_locale", "ja"), "0" * 64),
        ("header count bool", ("batches", index, append.HEADERS_FIELD, "ja", "count"), True),
        ("header selection", ("batches", index, append.HEADERS_FIELD, "ja", "selection_sha256"), "0" * 64),
        ("header revision", ("batches", index, append.HEADERS_FIELD, "ja", "source_revision"), "0" * 40),
        ("header manifest", ("batches", index, append.HEADERS_FIELD, "ja", "source_manifest_sha256"), "0" * 64),
        ("header locale", ("batches", index, append.HEADERS_FIELD, "ja", "locale"), "zh-CN"),
        ("missing header", ("batches", index, append.HEADERS_FIELD), {}),
        ("native claim", ("batches", index, "native_review"), "GO")):
        reject(lambda f=field, v=value: validate(before, edit(after, ledger, f, v), inventory), label)
    wrong_header = append.exchange.make_batch(inventory, "ja", leaves, append.LEGACY_GIFT_BEFORE_COMMIT, {}, {})[0]
    forged_batch = copy.deepcopy(batch)
    forged_batch[append.HEADERS_FIELD]["ja"] = wrong_header
    forged_batch["receipt_sha256_by_locale"]["ja"] = append.exchange.digest({"batch": wrong_header, "state": "accepted_machine_validated",
        "native_review": "OPEN", "translations": {leaf.id: docs[ledger].value["accepted"]["ja"][leaf.id] for leaf in leaves}})
    reject(lambda: validate(before, edit(after, ledger, ("batches", index), forged_batch), inventory), "re-signed None previous-target selection",
           "legacy JA gift official previous-target selection differs")
    batches = docs[ledger].value["batches"]
    for label, value in (("missing batch", batches[:-1]), ("duplicate batch", [*batches, batch]),
                         ("reordered batch", [*batches[:-2], batches[-1], batches[-2]])):
        reject(lambda v=value: validate(before, edit(after, ledger, ("batches",), v), inventory), label)
    for field, value in (("source", "changed KO"), ("protected", True), ("runtime_support", "unverified_consumer")):
        reject(lambda f=field, v=value: validate(before, after, {**inventory, "leaves": [replace(first, **{f: v}), leaves[1]]}), "current leaf " + field)
    reject(lambda: validate(before, after, {**inventory, "leaves": leaves + [first]}), "duplicate current leaf")
    start, end = docs[ja].spans[(keys[0],)]
    token = docs[ja].text[start:end]
    escaped = token[:1] + "\\u%04x" % ord(token[1]) + token[2:]
    raw_escape = {**after, ja: (docs[ja].text[:start] + escaped + docs[ja].text[end:]).encode()}
    reject(lambda: inverse(raw_escape, before, after), "same-value target raw escape is not exact inverse")

    def forged_stream(where, *args, **kwargs):
        raw = real_git(where, *args, **kwargs)
        return raw + b"forged" if args[:2] == ("cat-file", "--batch") else raw
    def wrong_paths(where, *args, **kwargs):
        return b"M\0locale/ui_ja.json\0M\0outside.json\0" if args and args[0] == "diff" else real_git(where, *args, **kwargs)
    def wrong_parent(root, requests):
        result = real_objects(root, requests)
        for i, request in enumerate(requests):
            if request[1:] == (append.LEGACY_GIFT_AFTER_COMMIT, "commit"):
                result[i] = result[i].replace(("parent " + append.LEGACY_GIFT_BEFORE_COMMIT).encode(), b"parent " + b"0" * 40, 1)
        return result
    for label, fault in (
        ("fresh Git loss", mock.patch.object(append, "_git", side_effect=OSError("Git unavailable after success"))),
        ("forged object stream", mock.patch.object(append, "_git", side_effect=forged_stream)),
        ("wrong product paths", mock.patch.object(append, "_git", side_effect=wrong_paths)),
        ("post-object direct-parent fault", mock.patch.object(append, "_objects", side_effect=wrong_parent)),
        ("wrong origin blob", mock.patch.object(append, "LEGACY_GIFT_ORIGIN_BLOB", "0" * 40))):
        with fault: reject(lambda: append._legacy_ja_gift_proof(ROOT, inventory), label)
    check(append._legacy_ja_gift_proof(ROOT, inventory) == (before, after, change), "fresh actual proof after faults, no successful cross-call cache")

    # One synthetic JA append tail, using the production comparison and ordinary
    # append checker directly. Do not re-run 380/384/392 or widen their baseline.
    extra = append.exchange.Leaf("ui", "합성 후속 선물 문구", "runtime:static_ui", ("합성 후속 선물 문구",), "합성 후속 선물 문구", "ui_static_context")
    extended = {**inventory, "leaves": [*leaves, extra]}
    target = "次の贈り物の文言"
    row = {"source_sha256": extra.source_sha256, "target_sha256": append.exchange.digest(target)}
    header = append.exchange.make_batch(extended, "ja", [extra], append.LEGACY_GIFT_AFTER_COMMIT, {}, {})[0]
    new_batch = {"order": "synthetic after414", "group": "ui", "roots": [extra.owner], "source_leaves": 1,
                 "target_leaves_by_locale": {"ja": 1, "zh-CN": 0, "zh-TW": 0}, "machine_validation": "PASS", "native_review": "OPEN",
                 append.HEADERS_FIELD: {"ja": header}, "receipt_sha256_by_locale": {"ja": append.exchange.digest({
                     "batch": header, "state": "accepted_machine_validated", "native_review": "OPEN", "translations": {extra.id: row}})}}
    future = dict(after)
    end = docs[ja].spans[(list(docs[ja].value)[-1],)][1]
    future[ja] = (docs[ja].text[:end] + ",\n  " + append._ordered(extra.owner).decode() + ": " + append._ordered(target).decode() + docs[ja].text[end:]).encode()
    accepted = copy.deepcopy(docs[ledger].value["accepted"])
    accepted["ja"][extra.id] = row
    tail = docs[ledger].spans[("accepted", "ja", list(docs[ledger].value["accepted"]["ja"])[-1])][1]
    batch_tail = docs[ledger].spans[("batches", index)][1]
    checksum = docs[ledger].spans[("accepted_sha256",)]
    changes = [(tail, tail, ",\n      " + append._ordered(extra.id).decode() + ": " + append._ordered(row).decode()),
               (batch_tail, batch_tail, ",\n    " + append._ordered(new_batch).decode()),
               (*checksum, append._ordered(append.exchange.digest(accepted)).decode())]
    text = docs[ledger].text
    for start, end, replacement in sorted(changes, reverse=True): text = text[:start] + replacement + text[end:]
    future[ledger] = text.encode()
    tail_change = append.validate_append(after, future, extended)
    comparison = inverse(future, before, after)
    check(tail_change["receipts"] == tail_change["batches"] == 1 and append.validate_append(before, comparison, extended) == tail_change,
          "normal subsequent JA append survives exact correction inverse")
    for key in keys:
        rollback = edit(future, ja, (key,), append.LEGACY_GIFT_TEXTS[key][0])
        reject(lambda value=rollback: inverse(value, before, after), "following target rollback " + key)
        reject(lambda value=rollback: append.validate_append(future, value, extended), "generic subsequent rollback " + key)
    reject(lambda: inverse(before, before, after), "complete correction rollback")
    check(all((ROOT / path).read_bytes() == raw for path, raw in observed.items()), "source and all product bytes unchanged")
    return failures, cases
# END_JA_GIFT_COPY_SELF_TEST_414


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--synthetic-only", action="store_true", help="author development only; not current acceptance")
    parser.add_argument("--three-locales", action="store_true", help="bounded JA/current47 change tests only; no historical suite")
    parser.add_argument("--correction", action="store_true", help="exact two-target correction only; no old suite or collector")
    parser.add_argument("--main-modal", action="store_true", help="three rendering repairs and current-location bridge only")
    parser.add_argument("--job-status-wrap", action="store_true", help="current one-token career-wrap successor only; no old suites")
    parser.add_argument("--investment-fee-correction", action="store_true", help="exact384 two-target correction only; no old suites")
    parser.add_argument("--investment-footer", action="store_true", help="current386 rendering/source successor only; no old suites")
    parser.add_argument("--tutorial-copy", action="store_true", help="current390 source-pair, collector and retained-JA boundaries only")
    parser.add_argument("--split-receipt", action="store_true", help="exact392 split UI/receipt proof and state only; no historical suites")
    parser.add_argument("--pad-hint-font", action="store_true", help="current393 four font lines, source and collector only; no historical suites")
    parser.add_argument("--people-card-height", action="store_true", help="current402 local people-card height and source boundary only; no historical suites")
    parser.add_argument("--axis-badge-fit", action="store_true", help="current403 axis fit, source and exact manifest equivalence only; no historical suites")
    parser.add_argument("--promotion-review", action="store_true", help="current406 pair, actual collector, retained JA and three receipts only; no historical suites")
    parser.add_argument("--career-tenure", action="store_true", help="current409 tenure width/English pair and unchanged receipt identity only; no historical suites")
    parser.add_argument("--gift-price-badge", action="store_true", help="current412 gift-only price fit/source and unchanged collector/receipt identities; no historical suites")
    parser.add_argument("--ja-gift-copy", action="store_true", help="exact414 legacy Japanese two-value correction and first receipts only; no older suites")
    args = parser.parse_args()
    if args.ja_gift_copy:
        errors, cases = ja_gift_copy_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_JA_GIFT_COPY_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.gift_price_badge:
        errors, cases = gift_price_badge_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_GIFT_PRICE_BADGE_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.career_tenure:
        errors, cases = career_tenure_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_CAREER_TENURE_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.promotion_review:
        errors, cases = promotion_review_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_PROMOTION_REVIEW_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.axis_badge_fit:
        errors, cases = axis_badge_fit_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_AXIS_BADGE_FIT_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.people_card_height:
        errors, cases = people_card_height_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_PEOPLE_CARD_HEIGHT_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.pad_hint_font:
        errors, cases = pad_hint_font_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_PAD_HINT_FONT_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.split_receipt:
        errors, cases = split_receipt_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_SPLIT_RECEIPT_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
        return int(bool(errors))
    if args.tutorial_copy:
        errors, cases = tutorial_copy_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"TUTORIAL_COPY_SOURCE_SELF_TEST_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    if args.investment_footer:
        errors, cases = investment_footer_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"INVESTMENT_FOOTER_SOURCE_SELF_TEST_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
    if args.investment_fee_correction:
        errors, cases = investment_fee_correction_self_test()
        for error in errors:
            print("UI_TRANSLATION_APPEND_ERROR " + error)
        print(f"UI_TRANSLATION_APPEND_FEE_CORRECTION_{'FAIL' if errors else 'OK'} cases={cases}")
        return int(bool(errors))
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
        # Earlier source bodies and explicit options remain historical. The
        # default current transition check follows414's exact legacy JA repair.
        modal_errors, modal_cases = ja_gift_copy_self_test()
        errors.extend(modal_errors)
        cases += modal_cases
        print(f"UI_TRANSLATION_APPEND_JA_GIFT_COPY cases={modal_cases}")
        fee_errors, fee_cases = investment_fee_correction_self_test()
        errors.extend(fee_errors)
        cases += fee_cases
        print(f"UI_TRANSLATION_APPEND_FEE_CORRECTION cases={fee_cases}")
    for error in errors:
        print("UI_TRANSLATION_APPEND_ERROR " + error)
    marker = "UI_TRANSLATION_APPEND_SYNTHETIC" if args.synthetic_only else "UI_TRANSLATION_APPEND_SELF_TEST"
    print(f"{marker}_{'FAIL' if errors else 'OK'} cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
