#!/usr/bin/env python3
"""Focused ORDER-467 evidence; read-only Git, no engine or full-365 admission.

The default run collects the actual current UI once.  The comparison inventory
used for pure negative cases is explicitly reconstructed, not another observed
collector result.  --source-only omits current admission and has a different
success marker.  An outer caller may share the existing fresh proof contexts.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import subprocess
import sys
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
BEFORE = "1d742c758f413f7a77b9bb3b4093afc80f47e406"
AFTER = "621f559734787a3ef9f2d6d1fb204f4e143a096e"
MAIN = "scenes/MainGame.gd"
RAW4 = ("locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json",
        "content/meta/full_game_localization.json")
INPUTS = (MAIN, *RAW4, "tools/main_game_locale_history.py",
          "tools/ui_translation_append.py", "tools/ja_translation_pipeline.py",
          "tools/ja_translation_audit.py", "tools/order469_source_compat.py",
          "tools/order470_source_compat.py", "tools/InvestmentAPCopyCheck.gd",
          "tools/InvestmentAPCopyCheck.tscn", "tools/investment_ap_copy_self_test.py",
          "systems/InvestmentSystem.gd", "tools/market_cycle_label_history.py")


def _git(*args: str) -> bytes:
    return subprocess.check_output(
        ("git", "--no-optional-locks", "--no-replace-objects", *args),
        cwd=ROOT, stderr=subprocess.PIPE, timeout=30)


def _sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _snapshot() -> dict:
    return {"head": _git("rev-parse", "HEAD").decode().strip(),
            "tree": _git("rev-parse", "HEAD^{tree}").decode().strip(),
            "status": _git("status", "--porcelain=v1", "-z").hex(),
            "sha256": {path: _sha((ROOT / path).read_bytes()) for path in INPUTS}}


def _owner_edit(raw: bytes, owner: str, old: bytes, new: bytes) -> bytes:
    """Construct one test mutation; never used as the acceptance oracle."""
    spans = list(re.finditer(rb"(?m)^func ([A-Za-z_][A-Za-z_0-9]*)\(", raw))
    matches = [(i, row) for i, row in enumerate(spans) if row.group(1) == owner.encode()]
    if len(matches) != 1:
        raise AssertionError("test mutation owner is not exact1")
    index, row = matches[0]
    end = spans[index + 1].start() if index + 1 < len(spans) else len(raw)
    body = raw[row.start():end]
    if body.count(old) != 1:
        raise AssertionError("test mutation source is not exact1")
    return raw[:row.start()] + body.replace(old, new, 1) + raw[end:]


def run_self_test(*, include_current: bool = True) -> tuple[list[str], int]:
    import full_game_localization as exchange
    import ja_translation_audit as audit
    import ja_translation_pipeline as pipeline
    import main_game_locale_history as history

    failures, labels = [], set()

    def check(ok, label):
        if label in labels:
            raise AssertionError("duplicate test label: " + label)
        labels.add(label)
        if not ok:
            failures.append(label)
        print("INVESTMENT_AP_COPY_CASE " + json.dumps(
            {"id": label, "passed": bool(ok)}, ensure_ascii=False), flush=True)

    def reject(action, label):
        try:
            action()
        except ValueError:
            check(True, label)
        else:
            check(False, label)

    initial = _snapshot()
    print("INVESTMENT_AP_COPY_INPUT " + json.dumps(initial, sort_keys=True), flush=True)
    try:
        before, after = (_git("show", commit + ":" + MAIN) for commit in (BEFORE, AFTER))
        check((history.AP_COPY_BEFORE_COMMIT, history.AP_COPY_AFTER_COMMIT) == (BEFORE, AFTER),
              "immutable.commit-pins")
        check(tuple(_sha(raw) for raw in (before, after)) == history.AP_COPY_HASHES,
              "immutable.whole-main-hashes")
        check(_git("diff", "--name-status", "-z", BEFORE, AFTER) == b"M\0scenes/MainGame.gd\0",
              "immutable.exact-one-product-path")
        check(_git("show", "-s", "--format=%P", AFTER).decode().strip() == BEFORE,
              "immutable.direct-parent")
        check(history.investment_ap_inverse(after, before) == before, "inverse.exact-three")
        old, new = (value.encode() for value in history.AP_COPY_REPLACEMENT)
        owners = ("_on_leverage_buy", "_on_buy_asset", "_on_sell_asset")
        check(history.AP_COPY_OWNERS == pipeline.AP_COPY_OWNERS == owners, "inverse.owner-population")
        for owner in owners:
            mutations = {
                "missing": old,
                "duplicate": new + new,
                "wrong-ko": new.replace("행동력이 없습니다".encode(), "행동력이 부족합니다".encode()),
                "wrong-en": new.replace(b"No Action Points", b"No trading this week"),
            }
            for label, replacement in mutations.items():
                bad = _owner_edit(after, owner, new, replacement)
                reject(lambda b=bad: history.investment_ap_inverse(b, before), owner + "." + label)
            bad = after.replace(("func " + owner + "(").encode(),
                                ("func " + owner + "_unowned(").encode(), 1)
            reject(lambda b=bad: history.investment_ap_inverse(b, before), owner + ".wrong-function")
        for label, raw in (("unowned-byte", after + b"\n"), ("rollback", before)):
            reject(lambda r=raw: history.investment_ap_inverse(r, before), "inverse." + label)
        reject(lambda: history.investment_ap_inverse(after.decode(), before), "inverse.nonbytes-current")
        reject(lambda: history.investment_ap_inverse(after, before.decode()), "inverse.nonbytes-before")
        bad_before = before.replace(b"func _on_buy_asset(", b"func _on_buy_asset_unowned(", 1)
        bad_after = after.replace(b"func _on_buy_asset(", b"func _on_buy_asset_unowned(", 1)
        reject(lambda: history.investment_ap_inverse(bad_after, bad_before), "inverse.missing-owner-in-both")

        historical = {path: _git("show", BEFORE + ":" + path) for path in RAW4}
        for path in RAW4:
            check(_git("show", AFTER + ":" + path) == historical[path], "immutable.raw4." + path)
        prior_ledger = json.loads(historical[RAW4[-1]])
        ledger = json.loads((ROOT / RAW4[-1]).read_bytes())
        short, retired = pipeline.AP_COPY_NEW_PAIR[0], pipeline.AP_COPY_OLD_PAIR[0]
        leaf = "ui:" + short + ":/" + short
        retired_leaf = "ui:" + retired + ":/" + retired
        for locale, path in zip(("ja", "zh-CN", "zh-TW"), RAW4):
            previous = json.loads(historical[path])
            current = json.loads((ROOT / path).read_bytes())
            check(isinstance(current.get(short), str) and current[short] == previous[short],
                  "current.existing-short-target." + locale)
            rows, prior_rows = ledger["accepted"][locale], prior_ledger["accepted"][locale]
            check((leaf not in rows and leaf not in prior_rows) if locale == "ja" else
                  (leaf in rows and rows[leaf] == prior_rows[leaf]
                   and rows[leaf]["target_sha256"] == exchange.digest(current[short])),
                  "current.existing-short-receipt." + locale)
            check(retired_leaf not in rows, "current.no-retired-receipt." + locale)

        raw_pipeline = (ROOT / "tools/ja_translation_pipeline.py").read_bytes()
        ap_pipeline = pipeline.ending_father_pipeline_predecessor(
            pipeline.chapter_four_pipeline_predecessor(pipeline.story_fact_pipeline_predecessor(
                pipeline.first_loss_pipeline_predecessor(pipeline.market_cycle_pipeline_predecessor(raw_pipeline)))))
        check(pipeline.investment_ap_pipeline_predecessor(ap_pipeline)
              == _git("show", BEFORE + ":tools/ja_translation_pipeline.py"), "collector.immutable-whole-prefix")
        reject(lambda: pipeline.investment_ap_pipeline_predecessor(ap_pipeline + b"\n"),
               "collector.unowned-prefix-suffix")
        bad = ap_pipeline.replace(b"def investment_ap_rebind_inventory(",
                                  b"def investment_ap_rebind_inventory_bad(", 1)
        reject(lambda: pipeline.investment_ap_pipeline_predecessor(bad), "collector.appendix-mutation")
        with patch.object(pipeline, "AP_COPY_PIPELINE_BEFORE_BLOB", "0" * 40):
            reject(lambda: pipeline.investment_ap_pipeline_predecessor(ap_pipeline), "collector.wrong-blob-pin")

        if include_current:
            import order469_source_compat as chapter
            import order470_source_compat as facts
            with facts.fresh_validation_proof(ROOT), chapter.fresh_validation_proof(ROOT), \
                    history.fresh_main_validation_proof(ROOT):
                actual_raw = (ROOT / MAIN).read_bytes()
                predecessors = history._investment_ap_proof(actual_raw, ROOT)
                check(len(predecessors) == 13 and predecessors[0] == before, "current.actual-git-predecessor")
                inventory = pipeline.collect_ui_inventory()
                check(not inventory.errors and bool(inventory.calls), "current.actual-collector-once")
                if inventory.errors:
                    raise ValueError("actual UI collector failed: " + repr(inventory.errors))
                _, retained, actual = pipeline._investment_ap_stage_call_views(actual_raw)
                check(tuple(c for c in inventory.calls if c.path == MAIN) == actual,
                      "current.all-main-calls-and-coordinates")
                check(not any(c.korean == retired for c in inventory.calls)
                      and retired not in inventory.blueprint and short in inventory.blueprint,
                      "current.retired-zero-short-existing")
                for owner in owners:
                    calls = [c for c in actual if c.function == owner and c.korean == short]
                    check(len(calls) == 1 and calls[0].english == pipeline.AP_COPY_NEW_PAIR[1]
                          and calls[0].api == "legacy", "current.selector." + owner)

                # The old comparison view is built from actual peer calls plus
                # the independently proved pre467 Main. It is not a new census.
                iterator = iter(retained)
                old_calls = tuple(next(iterator) if c.path == MAIN else c for c in inventory.calls)
                previous = pipeline._gift_caption_inventory_view(inventory, old_calls)
                rebound = pipeline._investment_ap_rebind(previous, retained, actual)
                check(rebound.calls == inventory.calls
                      and rebound.stats["legacy_keys"] == previous.stats["legacy_keys"] - 1
                      and len(rebound.calls) == len(previous.calls), "rebind.actual-calls-minus-one-key")
                old_entries = {e.source: e for e in previous.legacy_entries}
                check(all(replace(e, context=old_entries[e.source].context) == old_entries[e.source]
                          for e in rebound.legacy_entries), "rebind.surviving-entry-ids-and-hashes")
                check(rebound.planned_context_entries == previous.planned_context_entries
                      and rebound.observed_context_entries == previous.observed_context_entries
                      and rebound.planned_context_blueprint == previous.planned_context_blueprint
                      and rebound.observed_context_blueprint == previous.observed_context_blueprint,
                      "rebind.context-layers-unchanged")
                target_index = next(i for i, c in enumerate(old_calls)
                                    if c.path == MAIN and c.function == owners[0] and c.korean == retired)
                target = old_calls[target_index]
                mutations = {
                    "missing": old_calls[:target_index] + old_calls[target_index + 1:],
                    "duplicate": old_calls[:target_index] + (target,) + old_calls[target_index:],
                }
                for field, value in (("korean", short), ("english", "wrong English"),
                                     ("function", "_unowned"), ("line", target.line + 1)):
                    mutations["wrong-" + field] = (old_calls[:target_index]
                        + (replace(target, **{field: value}),) + old_calls[target_index + 1:])
                peer = next(i for i, c in enumerate(old_calls) if c.path == MAIN and c.korean != retired)
                mutations["unowned-main-call"] = (old_calls[:peer]
                    + (replace(old_calls[peer], english="unowned mutation"),) + old_calls[peer + 1:])
                for label, calls in mutations.items():
                    reject(lambda c=calls: pipeline._investment_ap_rebind(
                        replace(previous, calls=c), retained, actual), "rebind." + label)
                reject(lambda: pipeline._investment_ap_rebind(inventory, retained, actual),
                       "rebind.current-is-not-predecessor")

                japanese = json.loads((ROOT / RAW4[0]).read_bytes())
                entries, errors = audit.investment_ap_retained_ja_entries(inventory, japanese)
                check(not errors and set(entries) == {retired}
                      and entries[retired].key == "retained-ui::investment-ap", "retained.actual-ja-exact-one")
                # These are leaf-guard tests supplied the already proved current
                # call tuple. Normal admission above is deliberately not mocked.
                with patch.object(pipeline, "_investment_ap_call_views", return_value=((), actual)):
                    for label, value in (("missing", None), ("wrong-value", "改変")):
                        changed = dict(japanese)
                        if value is None:
                            changed.pop(retired)
                        else:
                            changed[retired] = value
                        result, errors = audit.investment_ap_retained_ja_entries(inventory, changed)
                        check(not result and bool(errors), "retained." + label)
                    changed_ledger = copy.deepcopy(ledger)
                    changed_ledger["accepted"]["ja"][retired_leaf] = {"forged": True}
                    with patch.object(audit, "read_json", return_value=changed_ledger):
                        result, errors = audit.investment_ap_retained_ja_entries(inventory, japanese)
                        check(not result and bool(errors), "retained.forged-retired-receipt")
                    poisoned = replace(inventory, legacy_blueprint={**inventory.legacy_blueprint,
                                                                   retired: {"$entry": "forged"}})
                    result, errors = audit.investment_ap_retained_ja_entries(poisoned, japanese)
                    check(not result and bool(errors), "retained.current-retired-key")

                # Warm public API still rejects changed authority, and restores
                # every monkeypatch before the real context exit reproves Git.
                pins = {"AP_COPY_BEFORE_COMMIT": "0" * 40, "AP_COPY_AFTER_COMMIT": "0" * 40,
                        "AP_COPY_TREES": ("0" * 40,) * 2, "AP_COPY_BLOBS": ("0" * 40,) * 2,
                        "AP_COPY_HASHES": ("0" * 64,) * 2}
                for name, value in pins.items():
                    with patch.object(history, name, value):
                        reject(lambda: history._investment_ap_proof(actual_raw, ROOT), "pin.warm-" + name)
                reject(lambda: history._investment_ap_proof(actual_raw + b"\n", ROOT), "pin.warm-current-raw")

                # Faults affect only the Git response for the exact AP before
                # blob; original typed proof, current disk and other objects run.
                original_git = history._modal_git
                wanted = history.AP_COPY_BLOBS[0].encode()
                for fault in ("missing", "type", "bytes"):
                    hit = []

                    def corrupt(root, *args, input=None):
                        output = original_git(root, *args, input=input)
                        if args != ("cat-file", "--batch"):
                            return output
                        cursor = 0
                        while cursor < len(output):
                            end = output.index(b"\n", cursor)
                            oid, kind, size_raw = output[cursor:end].split()
                            size = int(size_raw)
                            stop = end + 2 + size
                            if oid == wanted:
                                hit.append(True)
                                if fault == "missing":
                                    return output[:cursor] + oid + b" missing\n" + output[stop:]
                                if fault == "type":
                                    return output[:cursor] + oid + b" tree " + size_raw + output[end:]
                                value = output[end + 1:end + 1 + size]
                                return output[:end + 1] + bytes((value[0] ^ 1,)) + value[1:] + output[end + 1 + size:]
                            cursor = stop
                        raise AssertionError("AP blob fault did not reach its exact target")

                    with patch.object(history, "_modal_git", corrupt):
                        reject(lambda: history._MAIN_SCOPE_ORIGINAL_PROOF(actual_raw, ROOT), "git-object." + fault)
                    check(len(hit) == 1, "git-object." + fault + ".target-reached")
            check(True, "current.all-fresh-contexts-exited")
    finally:
        final = _snapshot()
        print("INVESTMENT_AP_COPY_OUTPUT " + json.dumps(final, sort_keys=True), flush=True)
        check(final == initial, "preservation.inputs-head-tree-status")
    return failures, len(labels)


def run_market_cycle_only() -> tuple[list[str], int]:
    """Direct478 -> unchanged476/470/469/468/467 seals, not another collector."""
    import ja_translation_pipeline as pipeline
    import market_cycle_label_history as market
    failures, labels = [], set()

    def check(ok, label):
        if label in labels:
            raise AssertionError("duplicate market/AP case: " + label)
        labels.add(label)
        if not ok:
            failures.append(label)
        print("INVESTMENT_AP_MARKET_CYCLE_CASE " + json.dumps(
            {"id": label, "passed": bool(ok)}, ensure_ascii=False), flush=True)

    def reject(action, label):
        try:
            action()
        except (ValueError, TypeError, KeyError):
            check(True, label)
        else:
            check(False, label)

    initial = _snapshot()
    print("INVESTMENT_AP_MARKET_CYCLE_INPUT " + json.dumps(initial, sort_keys=True), flush=True)
    try:
        with market.fresh_validation_proof(ROOT):
            raw = (ROOT / "tools/ja_translation_pipeline.py").read_bytes()
            previous = pipeline.market_cycle_pipeline_predecessor(raw)
            check(previous == _git("show", market.PRODUCT_COMMIT + ":tools/ja_translation_pipeline.py"),
                  "sealed478.whole-immutable-predecessor")
            stripped = pipeline.ending_father_pipeline_predecessor(
                pipeline.chapter_four_pipeline_predecessor(pipeline.story_fact_pipeline_predecessor(
                    pipeline.first_loss_pipeline_predecessor(previous))))
            check(pipeline.investment_ap_pipeline_predecessor(stripped)
                  == _git("show", BEFORE + ":tools/ja_translation_pipeline.py"),
                  "sealed478.original467-whole-prefix-and-intermediate-seals")
            for label, value in (("prefix", b" " + raw), ("suffix", raw + b"\n"),
                                  ("nonbytes", raw.decode()),
                                  ("appendix", raw.replace(b"def _market_cycle_rebind(",
                                                            b"def _market_cycle_rebind_forged(", 1))):
                reject(lambda value=value: pipeline.market_cycle_pipeline_predecessor(value),
                       "sealed478.reject-" + label)
            for field, value in (("MARKET_CYCLE_PIPELINE_BEFORE_SHA", "0" * 64),
                                  ("MARKET_CYCLE_PIPELINE_BEFORE_BLOB", "0" * 40),
                                  ("MARKET_CYCLE_PIPELINE_BEFORE_COMMIT", "0" * 40),
                                  ("MARKET_CYCLE_PIPELINE_APPEND_SHA", "0" * 64)):
                with patch.object(pipeline, field, value):
                    reject(lambda: pipeline.market_cycle_pipeline_predecessor(raw), "sealed478.pin-" + field)
            actual4 = {p: (ROOT / p).read_bytes() for p in RAW4}
            comparison4 = market.ui_predecessor(actual4, ROOT)
            check(comparison4 == {p: _git("show", market.PRODUCT_PARENT + ":" + p) for p in RAW4},
                  "raw4.exact-pre478-comparison-not-runtime")
            short = pipeline.AP_COPY_NEW_PAIR[0]
            leaf = "ui:" + short + ":/" + short
            old_ledger, ledger = (json.loads(rows[RAW4[-1]]) for rows in (comparison4, actual4))
            for locale, path in zip(("ja", "zh-CN", "zh-TW"), RAW4):
                check(json.loads(actual4[path])[short] == json.loads(comparison4[path])[short]
                      and ledger["accepted"][locale].get(leaf) == old_ledger["accepted"][locale].get(leaf),
                      "actual.existing-AP-target-and-receipt-unchanged." + locale)
            check(json.loads(actual4[RAW4[0]])["횡보장"] == "横ばい相場"
                  and json.loads(comparison4[RAW4[0]])["횡보장"] == "横歩場",
                  "actual.JA-correction-not-replaced-by-comparison")
            for path in RAW4:
                reject(lambda p=path: market.ui_predecessor({**actual4, p: actual4[p] + b"\n"}, ROOT),
                       "raw4.unowned-byte." + path)
            check(pipeline.market_cycle_pipeline_predecessor(raw) == previous,
                  "sealed478.final-fresh-original-prefix")
    finally:
        final = _snapshot()
        print("INVESTMENT_AP_MARKET_CYCLE_OUTPUT " + json.dumps(final, sort_keys=True), flush=True)
        check(initial == final, "preservation.inputs-head-tree-status")
    return failures, len(labels)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-only", action="store_true", help="omit actual current collector/JA admission")
    parser.add_argument("--market-cycle-only", action="store_true",
                        help="only ORDER478 direct AP seals/raw4 controls, no collector")
    args = parser.parse_args(argv)
    if args.source_only and args.market_cycle_only:
        parser.error("choose at most one targeted scope")
    try:
        failures, cases = (run_market_cycle_only() if args.market_cycle_only else
                           run_self_test(include_current=not args.source_only))
    except Exception as exc:
        print("INVESTMENT_AP_COPY_SELF_TEST_FAIL exception=" + repr(exc), file=sys.stderr)
        return 1
    marker = ("INVESTMENT_AP_MARKET_CYCLE_SELF_TEST" if args.market_cycle_only else
              "INVESTMENT_AP_COPY_SOURCE_ONLY" if args.source_only else "INVESTMENT_AP_COPY_SELF_TEST")
    print(f"{marker}_{'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)} "
          f"actual_collectors={int(not args.source_only and not args.market_cycle_only)}", flush=True)
    for failure in failures:
        print("ERROR " + failure, file=sys.stderr)
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
