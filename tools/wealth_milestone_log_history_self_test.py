#!/usr/bin/env python3
"""Bounded480 actual-source/first-three-receipt controls; no old suite."""
from __future__ import annotations

import copy
import difflib
import json
import sys
from pathlib import Path
from unittest import mock

import wealth_milestone_log_history as history


def run_wealth_milestone_checks(root=history.ROOT, inventory=None, ui_inventory=None):
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER480 wealth history: " + label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    def rehashed_inverse(before, changed, path):
        # Both independent whole hashes and every hunk hash/coordinate are
        # rebuilt, so the semantic negative cannot pass on a stale checksum.
        old, new = before.splitlines(True), changed.splitlines(True)
        patches = tuple((tag, a, z, b, end, history._sha(b"".join(old[a:z])),
                         history._sha(b"".join(new[b:end])))
                        for tag, a, z, b, end in difflib.SequenceMatcher(None, old, new).get_opcodes()
                        if tag != "equal")
        with mock.patch.dict(history.RAW_SHA256, {path: (history._sha(before), history._sha(changed))}), \
                mock.patch.dict(history.RAW_PATCHES, {path: patches}):
            return history.product_inverse(before, changed, path)

    active = history._ACTIVE.get()
    with history.fresh_validation_proof(root) as proof:
        before, source, current = (proof[k] for k in ("before", "source", "current"))
        check({p for p in before if before[p] != source[p]} == set(history.SOURCE_PATHS), "exact source4")
        for path in history.SOURCE_PATHS:
            check(history.product_inverse(before[path], source[path], path) == before[path], "exact inverse " + path)
            for label, raw in (("rollback", before[path]), ("neighbor", source[path] + b"\n"),
                               ("nonbytes", bytearray(source[path]))):
                reject(lambda r=raw, p=path: history.product_inverse(before[p], r, p), label + " " + path)
        reject(lambda: history.product_inverse(before[history.GAME_STATE_PATH], source[history.GAME_STATE_PATH],
               history.LEDGER_PATH), "wrong owned path")
        game_state = source[history.GAME_STATE_PATH]
        for label, raw in (("old KO", game_state.replace(history.NEW_KEY.encode(), history.OLD_KEY.encode(), 1)),
                           ("old EN", game_state.replace(history.NEW_ENGLISH.encode(), history.OLD_ENGLISH.encode(), 1)),
                           ("threshold", game_state.replace(b"total_now >= 2_000_000_000", b"total_now >= 3_000_000_000", 1)),
                           ("flag", game_state.replace(b'flags["asset_2b_reached"] = true', b'flags["asset_2b_reached"] = false', 1)),
                           ("neighbor", game_state + b"\n")):
            reject(lambda r=raw: rehashed_inverse(before[history.GAME_STATE_PATH], r, history.GAME_STATE_PATH),
                   "independently repinned " + label)
        for path in history.UI_PATHS:
            doc = history._Document(source[path])
            for key, text in ((history.NEW_KEY, "wrong"), (next(k for k in doc.value if k != history.NEW_KEY), "neighbor")):
                a, z = doc.spans[(key,)]
                raw = (doc.text[:a] + json.dumps(text, ensure_ascii=False) + doc.text[z:]).encode()
                reject(lambda r=raw, p=path: rehashed_inverse(before[p], r, p), "repinned UI " + path + key)
            reject(lambda p=path: rehashed_inverse(before[p], source[p] + b"\n", p), "repinned layout " + path)
        check(history.game_state_predecessor(game_state, root) == before[history.GAME_STATE_PATH], "public actual GameState inverse")
        for label, raw in (("old", before[history.GAME_STATE_PATH]), ("neighbor", game_state + b"\n"),
                           ("type", bytearray(game_state)), ("wrong file", source[history.UI_PATHS[0]])):
            reject(lambda r=raw: history.game_state_predecessor(r, root), "public GameState " + label)
        actual4 = {p: current[p] for p in history.CURRENT_UI_PATHS}
        old4 = {p: before[p] for p in history.CURRENT_UI_PATHS}
        result = history.ui_predecessor(actual4, root)
        check(result == old4 and actual4 == {p: current[p] for p in actual4}, "actual four-raw inverse without mutation")
        result[history.UI_PATHS[0]] = b"forged"
        check(history.ui_predecessor(actual4, root) == old4, "returned comparison has no mutable alias")
        for label, rows in (("old", old4), ("missing", {k: v for k, v in actual4.items() if k != history.UI_PATHS[0]}),
                            ("extra", {**actual4, "extra": b"x"}), ("neighbor", {**actual4, history.UI_PATHS[0]: actual4[history.UI_PATHS[0]] + b"\n"}),
                            ("nonbytes", {**actual4, history.UI_PATHS[0]: bytearray(actual4[history.UI_PATHS[0]])})):
            reject(lambda r=rows: history.ui_predecessor(r, root), "four-raw " + label)
        source4 = {p: source[p] for p in history.CURRENT_UI_PATHS}
        check(history.ui_comparison(source4, old4, source4) == old4, "source-only UI seam")
        reject(lambda: history.ui_comparison(old4, old4, source4), "seam rejects historical claim")
        check(source[history.LEDGER_PATH] == before[history.LEDGER_PATH], "source4 means zero acceptance")
        receipts = proof["receipts"]
        if receipts is None:
            check(current == source and history.RECEIPT_COMMIT is None, "unbound receipt remains source-only")
            reject(lambda: history._receipt_semantics(source, source), "unbound acceptance cannot pass")
        else:
            check({p for p in source if source[p] != receipts[p]} == {history.LEDGER_PATH}, "separate ledger1 stage")
            check(history._receipt_semantics(source, receipts) == history.RECEIPT_PARENT, "exact official first3")
            check(history._ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH]) == source[history.LEDGER_PATH],
                  "old274 raw prefix and41849 accepted records remain")
            check(history.ui_comparison(actual4, source4, actual4) == source4, "first receipt UI seam")
            reject(lambda: history._receipt_semantics(source, source), "receipt rollback")
            reject(lambda: history._ledger_inverse(source[history.LEDGER_PATH], receipts[history.LEDGER_PATH] + b"\n"),
                   "receipt neighboring raw")
            ledger = history._loads(receipts[history.LEDGER_PATH])
            for label in ("existing receipt", "wrong target", "extra key", "native approval", "old prefix"):
                mutant = copy.deepcopy(ledger)
                if label == "existing receipt":
                    key = next(k for k in mutant["accepted"]["ja"] if k != history.RECEIPT_ID)
                    mutant["accepted"]["ja"][key]["target_sha256"] = "0" * 64
                elif label == "wrong target":
                    mutant["accepted"]["ja"][history.RECEIPT_ID]["target_sha256"] = "0" * 64
                elif label == "extra key":
                    mutant["accepted"]["ja"]["ui:extra:/extra"] = mutant["accepted"]["ja"][history.RECEIPT_ID]
                elif label == "native approval":
                    mutant["native_review"] = "PASS"
                else:
                    mutant["batches"][0]["order"] = "forged"
                mutant["accepted_sha256"] = history._digest(mutant["accepted"])
                raw = (json.dumps(mutant, ensure_ascii=False, indent=2) + "\n").encode()
                pairs = (history._sha(source[history.LEDGER_PATH]), history._sha(raw))
                with mock.patch.object(history, "RECEIPT_RAW_SHA256", pairs):
                    reject(lambda r=raw: history._receipt_semantics(source, {**receipts, history.LEDGER_PATH: r}),
                           "rehashed receipt " + label)
        # Editing the yielded dictionary cannot forge the hidden active proof.
        proof["current"][history.GAME_STATE_PATH] = before[history.GAME_STATE_PATH]
        check(history.game_state_predecessor(game_state, root) == before[history.GAME_STATE_PATH], "yielded proof copy cannot alter admission")
    check(history._ACTIVE.get() is active, "outer identity restored")

    for label, attr, value in (("parent", "PRODUCT_PARENT", history.PRODUCT_COMMIT),
                               ("unbound", "PRODUCT_COMMIT", None), ("paths", "SOURCE_PATHS", (history.GAME_STATE_PATH,))):
        with mock.patch.object(history, attr, value):
            reject(lambda: history._read_proof(root), "exact stage rejects " + label)
    for response in (b"missing missing\n", b"0" * 40 + b" blob 0\n\n"):
        with mock.patch.object(history, "_git", return_value=response):
            reject(lambda: history._objects(root, [(history.PRODUCT_COMMIT, history.PRODUCT_COMMIT, "commit")]),
                   "typed object identity/type")
    original_git = history._git
    def extra_path(r, *args, **kwargs):
        raw = original_git(r, *args, **kwargs)
        return raw + b"M\0unowned.json\0" if args[:3] == ("diff", "--name-status", "-z") else raw
    with mock.patch.object(history, "_git", extra_path):
        reject(lambda: history._read_proof(root), "global changed pathset cannot grow")
    reject(lambda: history._read_proof(Path(root) / "tools"), "wrong root")
    for kind in ("Git", "configuration", "disk", "function", "HEAD"):
        def warm():
            with history.fresh_validation_proof(root):
                if kind == "Git":
                    patch = mock.patch.object(history, "_git", side_effect=ValueError("missing typed object"))
                elif kind == "configuration":
                    patch = mock.patch.object(history, "PRODUCT_PARENT", history.PRODUCT_COMMIT)
                elif kind == "function":
                    original = history.product_inverse
                    patch = mock.patch.object(history, "product_inverse", lambda *a: original(*a))
                elif kind == "HEAD":
                    original = history._git
                    patch = mock.patch.object(history, "_git", side_effect=lambda r, *a, **kw:
                                              (history.PRODUCT_PARENT + "\n").encode() if a[0] == "rev-parse" else original(r, *a, **kw))
                else:
                    original = history._disk_bytes
                    patch = mock.patch.object(history, "_disk_bytes", side_effect=lambda p:
                                              original(p) + b"\n" if p == Path(root) / history.UI_PATHS[0] else original(p))
                with patch:
                    history.game_state_predecessor(game_state, root)
        reject(warm, "warm nested " + kind)
        check(history._ACTIVE.get() is active, "failed nested scope restores " + kind)
    with history.fresh_validation_proof(root) as real:
        forged = copy.deepcopy(real)
        forged["current"][history.GAME_STATE_PATH] = forged["before"][history.GAME_STATE_PATH]
        token = history._ACTIVE.set(forged)
        try:
            reject(lambda: history.game_state_predecessor(forged["current"][history.GAME_STATE_PATH], root), "forged cached proof")
        finally:
            history._ACTIVE.reset(token)
    try:
        with history.fresh_validation_proof(root):
            raise RuntimeError("consumer error")
    except RuntimeError:
        check(history._ACTIVE.get() is active, "consumer exception clears scope")
    for exceptional in (False, True):
        def late_change():
            original_read, armed = history._disk_bytes, [False]
            def read(path):
                raw = original_read(path)
                return raw + b"\n" if armed[0] and path == Path(root) / history.UI_PATHS[0] else raw
            # This control deliberately starts a separate invocation so an
            # enclosing runner's function binding cannot reject before entry.
            token = history._ACTIVE.set(None)
            try:
                with mock.patch.object(history, "_disk_bytes", read):
                    with history.fresh_validation_proof(root):
                        armed[0] = True
                        if exceptional:
                            raise RuntimeError("consumer exception cannot bypass exit guard")
            finally:
                history._ACTIVE.reset(token)
        reject(late_change, "late physical mutation on " + ("exception" if exceptional else "normal exit"))
        check(history._ACTIVE.get() is active, "late failure clears scope")
    if inventory is not None:
        unchanged = copy.deepcopy(inventory)
        compared = history.source_predecessor_inventory(root, inventory)
        check(compared["source_manifest_sha256"] == history.PREDECESSOR_SOURCE_MANIFEST_SHA256,
              "whole census exact478 predecessor")
        check(inventory == unchanged, "actual collector untouched")
        for label, path, value in (("rollback", history.GAME_STATE_PATH, history.RAW_SHA256[history.GAME_STATE_PATH][0]),
                                   ("neighbor", "systems/RelationshipSystem.gd", "0" * 64),
                                   ("extra", history.LEDGER_PATH, "0" * 64)):
            mutant = copy.deepcopy(inventory)
            mutant["source_hashes"][path] = value
            mutant["source_manifest_sha256"] = history._digest(mutant["source_hashes"])
            reject(lambda r=mutant: history.source_predecessor_inventory(root, r), "independently rehashed census " + label)
        reject(lambda: history.source_predecessor_inventory(root, compared), "comparison is never current")
    if ui_inventory is not None:
        import ja_translation_audit as ja_audit
        actual = history._loads(history._disk_bytes(Path(root) / history.UI_PATHS[0]))
        entries, errors = ja_audit.wealth_milestone_retained_ja_entries(ui_inventory, actual)
        check(not errors and set(entries) == {history.OLD_KEY}, "exact retained Japanese key")
        for label, mutated in (("old target", {**actual, history.OLD_KEY: "forged"}),
                               ("missing old", {k: v for k, v in actual.items() if k != history.OLD_KEY}),
                               ("new target", {**actual, history.NEW_KEY: "forged"}),
                               ("missing new", {k: v for k, v in actual.items() if k != history.NEW_KEY})):
            entries, errors = ja_audit.wealth_milestone_retained_ja_entries(ui_inventory, mutated)
            check(bool(errors) and not entries, "retained supplied dictionary " + label)
        forged = copy.deepcopy(ui_inventory)
        from dataclasses import replace
        # The actual new call is replaced by the old key, with its real source
        #coordinate retained; passing a dictionary alone cannot license it.
        forged = replace(forged, calls=tuple(replace(call, korean=history.OLD_KEY, english=history.OLD_ENGLISH)
                         if call.path == history.GAME_STATE_PATH and call.korean == history.NEW_KEY else call
                         for call in forged.calls))
        entries, errors = ja_audit.wealth_milestone_retained_ja_entries(forged, actual)
        check(bool(errors) and not entries, "retained rejects old live-call claim")
        calls = tuple(c for c in ui_inventory.calls if not
                      (c.path == history.GAME_STATE_PATH and c.korean == history.NEW_KEY))
        entries, errors = ja_audit.wealth_milestone_retained_ja_entries(replace(ui_inventory, calls=calls), actual)
        check(bool(errors) and not entries, "retained rejects missing actual call")
        calls = tuple(replace(c, line=c.line + 1) if c.path == history.GAME_STATE_PATH
                      and c.korean == history.NEW_KEY else c for c in ui_inventory.calls)
        entries, errors = ja_audit.wealth_milestone_retained_ja_entries(replace(ui_inventory, calls=calls), actual)
        check(bool(errors) and not entries, "retained rejects forged source coordinate")
        with history.fresh_validation_proof(root) as proof:
            forged_proof = copy.deepcopy(proof)
        ledger = history._loads(forged_proof["current"][history.LEDGER_PATH])
        ledger["accepted"]["ja"][history.OLD_RECEIPT_ID] = {"source_sha256": "0" * 64, "target_sha256": "0" * 64}
        ledger["accepted_sha256"] = history._digest(ledger["accepted"])
        forged_proof["current"][history.LEDGER_PATH] = json.dumps(ledger, ensure_ascii=False).encode()
        import contextlib
        @contextlib.contextmanager
        def fake(_root=history.ROOT):
            yield forged_proof
        with mock.patch.object(history, "fresh_validation_proof", fake):
            entries, errors = ja_audit.wealth_milestone_retained_ja_entries(ui_inventory, actual)
        check(bool(errors) and not entries, "retained independently rejects forged old acceptance")

        import ja_translation_pipeline as pipeline
        path = history.GAME_STATE_PATH
        with history.fresh_validation_proof(root) as exact:
            previous_raw, actual_raw = exact["before"][path], exact["current"][path]
            previous_calls, actual_calls = pipeline._wealth_milestone_raw_call_views(previous_raw, actual_raw)
            old_row = next(c for c in previous_calls if c.korean == history.OLD_KEY)
            new_row = replace(old_row, korean=history.NEW_KEY, english=history.NEW_ENGLISH)
            check(tuple(new_row if c == old_row else c for c in previous_calls) == actual_calls,
                  "pure480 call inverse changes only exact KO/EN pair")
            check(new_row in ui_inventory.calls and not any(c.korean == history.OLD_KEY for c in ui_inventory.calls),
                  "supplied actual inventory retains current payload")
            for label, raw in (("rollback", previous_raw), ("neighbor", actual_raw + b"\n"),
                               ("missing literal", actual_raw.replace(history.NEW_KEY.encode(), b"", 1)),
                               ("nonbytes", bytearray(actual_raw))):
                reject(lambda r=raw: pipeline._wealth_milestone_raw_call_views(previous_raw, r),
                       "pure480 raw boundary " + label)
            # Keep exact source raw and the real product inverse intact. These
            #independent parser-result faults exercise tuple guards, not hashes.
            parse = pipeline._WEALTH_MILESTONE_OLD_PARSE
            for label in ("missing", "old key", "English", "line", "owner", "parse error"):
                def altered_parse(relative, text, fault=label):
                    rows, errors = parse(relative, text)
                    if relative != path or text.encode() != actual_raw:
                        return rows, errors
                    if fault == "parse error":
                        return rows, [*errors, "injected parser error"]
                    changed = []
                    for call in rows:
                        if call.korean == history.NEW_KEY:
                            if fault == "missing":
                                continue
                            fields = {"old key": {"korean": history.OLD_KEY},
                                      "English": {"english": history.OLD_ENGLISH},
                                      "line": {"line": call.line + 1},
                                      "owner": {"function": "forged_owner"}}[fault]
                            call = replace(call, **fields)
                        changed.append(call)
                    return changed, errors
                with mock.patch.object(pipeline, "_WEALTH_MILESTONE_OLD_PARSE", altered_parse):
                    reject(lambda: pipeline._wealth_milestone_raw_call_views(previous_raw, actual_raw),
                           "pure480 independent parser " + label)

            before470, _ = history._snapshot(root, pipeline.STORY_FACT_PIPELINE_BEFORE_COMMIT, (path,))
            historical, returned = pipeline._story_fact_call_views(path, before470[path], actual_raw)
            expected_history, expected_previous = pipeline._WEALTH_MILESTONE_OLD_STORY_FACT_CALL_VIEWS(
                path, before470[path], previous_raw)
            check(historical == expected_history and expected_previous == previous_calls and returned == actual_calls,
                  "same-root original470 seam returns actual480 calls")
            for label, raw in (("pre480", previous_raw), ("neighbor", actual_raw + b"\n"),
                               ("nonbytes", bytearray(actual_raw))):
                reject(lambda r=raw: pipeline._story_fact_call_views(path, before470[path], r),
                       "story-fact current payload rejects " + label)
            with mock.patch.object(history, "_snapshot", side_effect=ValueError("missing actual480 object")):
                reject(lambda: pipeline._story_fact_call_views(path, before470[path], actual_raw),
                       "story-fact warm missing typed evidence")
            original_disk = history._disk_bytes
            with mock.patch.object(history, "_disk_bytes", side_effect=lambda p:
                                   original_disk(p) + b"\n" if p == Path(root) / path else original_disk(p)):
                reject(lambda: pipeline._story_fact_call_views(path, before470[path], actual_raw),
                       "story-fact actual disk differs")
            other = "autoloads/DataRegistry.gd"
            other_before, _ = history._snapshot(root, pipeline.STORY_FACT_PIPELINE_BEFORE_COMMIT, (other,))
            other_current, _ = history._snapshot(root, exact["head"], (other,))
            check(pipeline._story_fact_call_views(other, other_before[other], other_current[other]) ==
                  pipeline._WEALTH_MILESTONE_OLD_STORY_FACT_CALL_VIEWS(other, other_before[other], other_current[other]),
                  "non-GameState original470 delegate unchanged")

        pipeline_raw = history._disk_bytes(Path(root) / "tools/ja_translation_pipeline.py")
        prior_pipeline = pipeline.wealth_milestone_pipeline_predecessor(pipeline_raw)
        check(history._sha(prior_pipeline) == pipeline.WEALTH_MILESTONE_PIPELINE_BEFORE_SHA,
              "sealed480 returns whole immutable predecessor")
        check(pipeline.market_cycle_pipeline_predecessor(pipeline_raw) ==
              pipeline._WEALTH_MILESTONE_OLD_MARKET_PREDECESSOR(prior_pipeline), "old478 unwrap chain remains exact")
        for label, raw in (("old pipeline", prior_pipeline), ("nonbytes", bytearray(pipeline_raw)),
                           ("appendix", pipeline_raw.replace(b"wealth-milestone GameState inverse differs",
                                                              b"wealth-milestone forged inverse differs", 1)),
                           ("prefix", pipeline_raw.replace(b"from __future__ import annotations",
                                                            b"from __future__ import annotations # forged", 1))):
            reject(lambda r=raw: pipeline.wealth_milestone_pipeline_predecessor(r), "collector seal " + label)
    check(history._ACTIVE.get() is active, "no cross-invocation success cache")
    return failures, cases


def main():
    if sys.argv[1:] not in ([], ["--wealth-milestone-only"]):
        raise SystemExit("usage: wealth_milestone_log_history_self_test.py [--wealth-milestone-only]")
    failures, cases = run_wealth_milestone_checks()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"ORDER480_WEALTH_MILESTONE_{'FAIL' if failures else 'OK'} cases={cases} native_review=OPEN")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
