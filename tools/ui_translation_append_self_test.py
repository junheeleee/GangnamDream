#!/usr/bin/env python3
"""Generic UI append, official receipt and malformed-input regressions."""
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
    return failures, cases

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--synthetic-only", action="store_true")
    parser.add_argument("--three-locales", action="store_true")
    args = parser.parse_args()
    suites = (three_locales_self_test,) if args.three_locales else (synthetic_self_test, three_locales_self_test)
    failures, total = [], 0
    for suite in suites:
        errors, cases = suite()
        failures.extend(errors)
        total += cases
    for error in failures:
        print("UI_TRANSLATION_APPEND_ERROR " + error)
    print(f"UI_TRANSLATION_APPEND_{'FAIL' if failures else 'OK'} cases={total}")
    return int(bool(failures))


if __name__ == "__main__":
    sys.exit(main())
