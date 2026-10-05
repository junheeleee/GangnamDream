#!/usr/bin/env python3
"""Actual Git and fail-closed controls for the source-only six-event retirement."""
from __future__ import annotations

import copy
import json
import sys
from dataclasses import replace
from unittest import mock

import order469_source_compat as history


def run():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER-469 source: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    with history.fresh_validation_proof() as proof:
        check(len(history.PRODUCT_PATHS) == len(history.RAW_SHA256) == 7, "exact seven product paths")
        before, after = proof["before"], proof["after"]
        for path in history.PRODUCT_PATHS:
            check(history.product_inverse(before[path], after[path], path) == before[path], "raw inverse " + path)
            for label, raw in (("whitespace", after[path] + b"\n"), ("rollback", before[path]),
                               ("nonbytes", after[path].decode())):
                reject(lambda p=path, r=raw: history.product_inverse(before[p], r, p), label + " " + path)
            if path.endswith(".json"):
                altered = json.loads(after[path])
                altered["unowned_neighbor"] = "not part of retirement"
                raw = (json.dumps(altered, ensure_ascii=False, indent=2) + "\n").encode()
                with mock.patch.dict(history.RAW_SHA256, {path: (history._sha(before[path]), history._sha(raw))}):
                    reject(lambda p=path, r=raw: history.product_inverse(before[p], r, p),
                           "semantic ownership survives rehashed neighbor " + path)
        raw = after[history.MAIN_PATH].replace(b'return daeun_id', b'return unattached_id', 1)
        with mock.patch.dict(history.RAW_SHA256, {history.MAIN_PATH:
                            (history._sha(before[history.MAIN_PATH]), history._sha(raw))}):
            reject(lambda: history.product_inverse(before[history.MAIN_PATH], raw, history.MAIN_PATH),
                   "Main raw structural inverse survives changed retained branch")
        check(history.main_predecessor(after[history.MAIN_PATH]) == before[history.MAIN_PATH],
              "actual current Main predecessor")
        reject(lambda: history.main_predecessor(before[history.MAIN_PATH]), "old Main cannot claim current")
        reject(lambda: history.main_predecessor(after[history.MAIN_PATH] + b"\n"), "mutated Main cannot claim current")
        reject(lambda: history.product_inverse(before[history.MAIN_PATH], after[history.MAIN_PATH],
                                              "./" + history.MAIN_PATH), "path alias")
    check(history._ACTIVE.get() is None, "scope cleared")

    # Immutable history, objects and exact pathset are independently checked.
    real_git = history._git
    with mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT):
        reject(lambda: history._read_proof(history.ROOT), "wrong parent")

    def altered_git(kind):
        def call(root, *args, **kwargs):
            if args[:2] == ("cat-file", "--batch") and kind == "missing":
                return b"missing missing\n"
            result = real_git(root, *args, **kwargs)
            if args[:2] == ("cat-file", "--batch") and kind == "object bytes":
                return result[:-2] + b"X\n"
            if args[:3] == ("diff", "--name-status", "-z") and kind == "pathset":
                return result + b"M\0content/meta/full_game_localization.json\0"
            return result
        return call
    for kind in ("missing", "object bytes", "pathset"):
        with mock.patch.object(history, "_git", altered_git(kind)):
            reject(lambda: history._read_proof(history.ROOT), "fail closed " + kind)

    def changed_inside_scope():
        with history.fresh_validation_proof():
            with mock.patch.object(history, "_git", altered_git("missing")):
                history.main_predecessor(after[history.MAIN_PATH])
    reject(changed_inside_scope, "nested proof cannot reuse missing objects after warm success")
    check(history._ACTIVE.get() is None, "failed nested scope cleared")

    from full_game_localization import collect
    inventory = collect(history.ROOT)
    result = history.source_predecessor_inventory(history.ROOT, inventory)
    check(result["source_manifest_sha256"] == history.PR31_SOURCE_MANIFEST_SHA256,
          "actual complete source maps to original e300")
    check(result["source_hashes"] == {**inventory["source_hashes"],
                                    **{path: history.RAW_SHA256[path][0] for path in history.SOURCE_PATHS}},
          "only exact Main/lifecycle/spine source hashes change")
    for label, path, value in (("Main", history.MAIN_PATH, "0" * 64),
                               ("neighbor", "systems/RelationshipSystem.gd", "0" * 64),
                               ("receipt inserted", "content/meta/full_game_localization.json", "0" * 64)):
        forged = copy.deepcopy(inventory)
        forged["source_hashes"][path] = value
        forged["source_manifest_sha256"] = history._digest(forged["source_hashes"])
        reject(lambda d=forged: history.source_predecessor_inventory(history.ROOT, d), "rehashed census " + label)
    reject(lambda: history.source_predecessor_inventory(history.ROOT, result), "predecessor cannot claim current census")

    import main_game_locale_history as main_history
    views = main_history._ending_father_proof(after[history.MAIN_PATH], history.ROOT)
    check(len(views) == 14, "sixteen historical stages retain fourteen comparison views")
    reject(lambda: main_history._ending_father_proof(after[history.MAIN_PATH] + b"\n", history.ROOT),
           "Main consumer rejects mutated current bytes")
    import ja_translation_pipeline as pipeline
    before_calls, errors = pipeline.parse_ui_calls(history.MAIN_PATH, before[history.MAIN_PATH].decode())
    actual_calls, current_errors = pipeline.parse_ui_calls(history.MAIN_PATH, after[history.MAIN_PATH].decode())
    before_calls = tuple(sorted(before_calls, key=lambda c: (c.path, c.line, c.api)))
    actual_calls = tuple(sorted(actual_calls, key=lambda c: (c.path, c.line, c.api)))
    pipeline._chapter_four_call_offsets(before[history.MAIN_PATH], after[history.MAIN_PATH], before_calls, actual_calls)
    check(not errors and not current_errors, "actual UI semantics and exact minus-eight coordinates")
    for label, changed in (("line", replace(actual_calls[-1], line=actual_calls[-1].line + 1)),
                            ("text", replace(actual_calls[-1], korean=actual_calls[-1].korean + " mutation"))):
        reject(lambda row=changed: pipeline._chapter_four_call_offsets(before[history.MAIN_PATH],
               after[history.MAIN_PATH], before_calls, (*actual_calls[:-1], row)), "UI call " + label + " drift")
    raw = (history.ROOT / "tools/ja_translation_pipeline.py").read_bytes()
    pipeline.chapter_four_pipeline_predecessor(raw)
    check(True, "collector whole-prefix and appendix seal")
    reject(lambda: pipeline.chapter_four_pipeline_predecessor(b" " + raw), "collector prefix mutation")
    reject(lambda: pipeline.chapter_four_pipeline_predecessor(raw.replace(
        b"chapter-four UI calls or exact source coordinates differ", b"mutated diagnostic", 1)),
        "collector appendix mutation")
    return failures, cases


def main():
    failures, cases = run()
    for message in failures:
        print(message, file=sys.stderr)
    print(f"ORDER469_SOURCE_COMPAT_{'FAIL' if failures else 'OK'} cases={cases} retired=6 receipts=0")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
