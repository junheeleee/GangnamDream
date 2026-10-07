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
        current = proof["current"][history.MAIN_PATH]
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
        check(history.main_predecessor(current) == before[history.MAIN_PATH],
              "actual current Main predecessor")
        reject(lambda: history.main_predecessor(before[history.MAIN_PATH]), "old Main cannot claim current")
        reject(lambda: history.main_predecessor(current + b"\n"), "mutated Main cannot claim current")
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
                history.main_predecessor(current)
    reject(changed_inside_scope, "nested proof cannot reuse missing objects after warm success")
    check(history._ACTIVE.get() is None, "failed nested scope cleared")

    from full_game_localization import collect
    inventory = collect(history.ROOT)
    result = history.source_predecessor_inventory(history.ROOT, inventory)
    check(result["source_manifest_sha256"] == history.PR31_SOURCE_MANIFEST_SHA256,
          "actual complete source maps to original e300")
    import order470_source_compat as later
    pre470, _ = history._snapshot(history.ROOT, later.PRODUCT_PARENT, tuple(inventory["source_hashes"]))
    check(result["source_hashes"] == {**{p: history._sha(raw) for p, raw in pre470.items()},
                                    **{path: history.RAW_SHA256[path][0] for path in history.SOURCE_PATHS}},
          "only exact476/470 then Main/lifecycle/spine source hashes change")
    for label, path, value in (("Main", history.MAIN_PATH, "0" * 64),
                               ("neighbor", "systems/RelationshipSystem.gd", "0" * 64),
                               ("receipt inserted", "content/meta/full_game_localization.json", "0" * 64)):
        forged = copy.deepcopy(inventory)
        forged["source_hashes"][path] = value
        forged["source_manifest_sha256"] = history._digest(forged["source_hashes"])
        reject(lambda d=forged: history.source_predecessor_inventory(history.ROOT, d), "rehashed census " + label)
    reject(lambda: history.source_predecessor_inventory(history.ROOT, result), "predecessor cannot claim current census")

    import main_game_locale_history as main_history
    views = main_history._ending_father_proof(current, history.ROOT)
    check(len(views) == 14, "sixteen historical stages retain fourteen comparison views")
    reject(lambda: main_history._ending_father_proof(current + b"\n", history.ROOT),
           "Main consumer rejects mutated current bytes")
    import ja_translation_pipeline as pipeline
    before_calls, errors = pipeline.parse_ui_calls(history.MAIN_PATH, before[history.MAIN_PATH].decode())
    actual_calls, current_errors = pipeline.parse_ui_calls(history.MAIN_PATH, current.decode())
    before_calls = tuple(sorted(before_calls, key=lambda c: (c.path, c.line, c.api)))
    actual_calls = tuple(sorted(actual_calls, key=lambda c: (c.path, c.line, c.api)))
    pipeline._chapter_four_call_offsets(before[history.MAIN_PATH], current, before_calls, actual_calls)
    check(not errors and not current_errors, "actual UI semantics and retained historical minus-eight coordinates")
    for label, changed in (("line", replace(actual_calls[-1], line=actual_calls[-1].line + 1)),
                            ("text", replace(actual_calls[-1], korean=actual_calls[-1].korean + " mutation"))):
        reject(lambda row=changed: pipeline._chapter_four_call_offsets(before[history.MAIN_PATH],
               current, before_calls, (*actual_calls[:-1], row)), "UI call " + label + " drift")
    raw = (history.ROOT / "tools/ja_translation_pipeline.py").read_bytes()
    raw = pipeline.story_fact_pipeline_predecessor(pipeline.first_loss_pipeline_predecessor(raw))
    pipeline.chapter_four_pipeline_predecessor(raw)
    check(True, "collector whole-prefix and appendix seal")
    reject(lambda: pipeline.chapter_four_pipeline_predecessor(b" " + raw), "collector prefix mutation")
    reject(lambda: pipeline.chapter_four_pipeline_predecessor(raw.replace(
        b"chapter-four UI calls or exact source coordinates differ", b"mutated diagnostic", 1)),
        "collector appendix mutation")
    return failures, cases


def run_first_loss_checks(root=history.ROOT, inventory=None):
    """Only the476 seam; callers may supply their one actual collected census."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER-476 first-loss source: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    outer = history._ACTIVE.get()
    with history.fresh_validation_proof(root) as proof:
        path = history.MAIN_PATH
        before, current = proof["first_loss_before"][path], proof["current"][path]
        check(before == proof["after"][path], "immutable469 after is the immediate476 predecessor")
        check(proof["first_loss_after"][path] == current, "actual current is the pinned476 source")
        check(history.first_loss_inverse(before, current) == before, "exact line plus EOF inverse")
        check(history.first_loss_predecessor(current, root) == before, "public actual to pre476")
        check(history.main_predecessor(current, root) == proof["before"][path], "old pre469 API meaning retained")
        check(len(history.PRODUCT_PATHS) == 7 and history.RAW_SHA256[path][1] == history._sha(before),
              "original seven-product pin population retained")
        for label, raw in (("rollback", before), ("pre469", proof["before"][path]),
                           ("whitespace", current + b"\n"), ("nonbytes", current.decode()),
                           ("mutable bytes", bytearray(current))):
            reject(lambda r=raw: history.first_loss_predecessor(r, root), "actual raw rejects " + label)
        for path_alias in ("./" + path, "autoloads/GameState.gd", path + ".other"):
            reject(lambda p=path_alias: history.first_loss_inverse(before, current, p), "path rejects " + path_alias)
        mutants = (
            ("retained branch", current.replace(b"return daeun_id", b"return unattached_id", 1)),
            ("gate removed", current.replace(history.FIRST_LOSS_NEW_LINE, history.FIRST_LOSS_OLD_LINE, 1)),
            ("quantity default", current.replace(b'holding.get("quantity", null)', b'holding.get("quantity", 1)', 1)),
            ("price fallback", current.replace(b"GameState.market_prices[asset_id]", b"GameState.get_asset_price(asset_id)", 1)),
            ("loss equality", current.replace(b"float(price) < float(average)", b"float(price) <= float(average)", 1)),
            ("finite guard", current.replace(b"not is_finite(float(value))", b"false", 1)),
            ("extra UI", current + b'\nfunc _unowned():\n\treturn _tr("x", "y")\n'),
            ("duplicate helper", current + history.FIRST_LOSS_APPEND),
            ("neighbor newline", current + b"\n"),
        )
        for label, raw in mutants:
            check(raw != current, "independent mutant exists: " + label)
            with mock.patch.object(history, "FIRST_LOSS_RAW_SHA256", (history._sha(before), history._sha(raw))):
                reject(lambda r=raw: history.first_loss_inverse(before, r), "rehashed ownership: " + label)
    check(history._ACTIVE.get() is outer, "outer proof identity restored")

    real_git = history._git

    def broken_git(kind):
        def call(root, *args, **kwargs):
            value = real_git(root, *args, **kwargs)
            if args[:2] == ("cat-file", "--batch"):
                if kind == "missing object":
                    return b"missing missing\n"
                if kind == "typed object":
                    return value.replace(b" commit ", b" blob ", 1)
                if kind == "object bytes":
                    return value[:-2] + b"X\n"
                if kind == "trailing object":
                    return value + b"x"
            if (args[:3] == ("diff", "--name-status", "-z")
                    and args[3:5] == (history.FIRST_LOSS_PARENT, history.FIRST_LOSS_COMMIT)
                    and kind == "extra path"):
                return value + b"M\0content/meta/full_game_localization.json\0"
            return value
        return call

    for kind in ("missing object", "typed object", "object bytes", "trailing object", "extra path"):
        with mock.patch.object(history, "_git", broken_git(kind)):
            reject(lambda: history._read_proof(root), "fresh proof " + kind)
    with mock.patch.object(history, "FIRST_LOSS_PARENT", history.PRODUCT_COMMIT):
        reject(lambda: history._read_proof(root), "wrong actual direct parent")
    with mock.patch.object(history, "FIRST_LOSS_COMMIT", None):
        reject(lambda: history._read_proof(root), "unbound successor")
    reject(lambda: history.first_loss_predecessor(current, root / "tools"), "wrong repository")

    def warm_failure(kind):
        with history.fresh_validation_proof(root):
            if kind == "object":
                with mock.patch.object(history, "_git", broken_git("missing object")):
                    history.first_loss_predecessor(current, root)
            elif kind == "configuration":
                with mock.patch.object(history, "FIRST_LOSS_PREDECESSOR_CENSUS", "0" * 64):
                    history.first_loss_predecessor(current, root)
            else:
                read = history._disk_bytes
                def changed_disk(path):
                    value = read(path)
                    return value + b"\n" if path == root / history.MAIN_PATH else value
                with mock.patch.object(history, "_disk_bytes", changed_disk):
                    history.first_loss_predecessor(current, root)
    for kind in ("object", "configuration", "disk"):
        reject(lambda k=kind: warm_failure(k), "warm proof rejects " + kind)
        check(history._ACTIVE.get() is outer, "failed nested proof restores outer: " + kind)

    if inventory is None:
        from full_game_localization import collect
        inventory = collect(root)
    original = copy.deepcopy(inventory)
    compared = history.source_predecessor_inventory(root, inventory)
    check(compared["source_manifest_sha256"] == history.PR31_SOURCE_MANIFEST_SHA256,
          "actual complete census reaches immutable e300")
    check(inventory == original, "current collector payload is never replaced by historical data")
    check(inventory["source_hashes"][history.MAIN_PATH] == history.FIRST_LOSS_RAW_SHA256[1]
          and compared["source_hashes"][history.MAIN_PATH] == history.RAW_SHA256[history.MAIN_PATH][0],
          "current Main and historical comparison stay separate")
    for label, path, value in (("Main rollback", history.MAIN_PATH, history.FIRST_LOSS_RAW_SHA256[0]),
                               ("Main forged", history.MAIN_PATH, "0" * 64),
                               ("neighbor", "systems/RelationshipSystem.gd", "0" * 64),
                               ("receipt intrusion", "content/meta/full_game_localization.json", "0" * 64)):
        mutant = copy.deepcopy(inventory)
        mutant["source_hashes"][path] = value
        mutant["source_manifest_sha256"] = history._digest(mutant["source_hashes"])
        reject(lambda v=mutant: history.source_predecessor_inventory(root, v), "independently rehashed census " + label)
    reject(lambda: history.source_predecessor_inventory(root, compared), "historical census cannot claim actual")
    check(history._ACTIVE.get() is outer, "no cross-invocation proof cache")
    return failures, cases


def main():
    first_loss_only = sys.argv[1:] == ["--first-loss-only"]
    failures, cases = run_first_loss_checks() if first_loss_only else run()
    for message in failures:
        print(message, file=sys.stderr)
    label = "ORDER476_FIRST_LOSS_SOURCE" if first_loss_only else "ORDER469_SOURCE_COMPAT"
    print(f"{label}_{'FAIL' if failures else 'OK'} cases={cases} retired=6 receipts=0")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
