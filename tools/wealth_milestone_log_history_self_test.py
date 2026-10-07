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


def run_one_billion_checks(root=history.ROOT, inventory=None, ui=None):
    """Bounded482 only. Optional inventories must come from the real collector."""
    import asset_one_billion_log_history as successor
    import ja_translation_pipeline as pipeline
    import zh_translation_audit as zh
    from dataclasses import replace
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER482: " + label)
    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)
    def repinned(before, after, path):
        a, b = before.splitlines(True), after.splitlines(True)
        patches = tuple((tag, x, z, y, end, successor._sha(b"".join(a[x:z])), successor._sha(b"".join(b[y:end])))
                        for tag, x, z, y, end in difflib.SequenceMatcher(None, a, b).get_opcodes() if tag != "equal")
        with mock.patch.dict(successor.RAW_SHA256, {path: (successor._sha(before), successor._sha(after))}), \
                mock.patch.dict(successor.RAW_PATCHES, {path: patches}):
            return successor.product_inverse(before, after, path)
    active = successor._ACTIVE.get()
    with successor.fresh_validation_proof(root) as proof:
        before, source, current = (proof[key] for key in ("before", "source", "current"))
        check({p for p in before if before[p] != source[p]} == set(successor.SOURCE_PATHS), "exact source4")
        check(before[successor.LEDGER_PATH] == source[successor.LEDGER_PATH], "source4 receipt0")
        for path in successor.SOURCE_PATHS:
            check(successor.product_inverse(before[path], source[path], path) == before[path], "literal/raw inverse " + path)
            for label, raw in (("rollback", before[path]), ("neighbor", source[path] + b"\n"),
                               ("type", bytearray(source[path]))):
                reject(lambda p=path, r=raw: successor.product_inverse(before[p], r, p), label + path)
            reject(lambda p=path: repinned(before[p], source[p] + b"\n", p), "independently rehashed layout " + path)
        for ui_path in successor.UI_PATHS:
            document = successor._Document(source[ui_path])
            a, z = document.spans[(successor.NEW_KEY,)]
            changed = (document.text[:a] + json.dumps("forged") + document.text[z:]).encode()
            reject(lambda p=ui_path, r=changed: repinned(before[p], r, p), "independently repinned translated leaf " + ui_path)
        ja_path = successor.UI_PATHS[0]
        document = successor._Document(source[ja_path])
        a, z = document.spans[(successor.OLD_KEY,)]
        changed = (document.text[:a] + json.dumps("forged") + document.text[z:]).encode()
        reject(lambda: repinned(before[ja_path], changed, ja_path), "independently repinned retained old JA leaf")
        path = successor.GAME_STATE_PATH
        raw = current[path]
        reject(lambda: successor.product_inverse(before[path], raw, successor.LEDGER_PATH), "wrong owned source path")
        check(successor.game_state_inverse(raw) == before[path], "pure GameState post480 inverse")
        check(successor.game_state_predecessor(raw, root) == before[path], "fresh actual GameState comparison")
        for label, mutated in (("old", before[path]), ("neighbor", raw + b"\n"), ("type", bytearray(raw))):
            reject(lambda r=mutated: successor.game_state_predecessor(r, root), "actual API " + label)
        for label, mutated in (("threshold", raw.replace(b"total_now >= 1_000_000_000", b"total_now >= 1_000_000_001", 1)),
                               ("flag", raw.replace(b'flags["asset_1b_reached"] = true', b'flags["asset_1b_reached"] = false', 1)),
                               ("KO", raw.replace(successor.NEW_KEY.encode(), successor.OLD_KEY.encode(), 1)),
                               ("English", raw.replace(successor.NEW_ENGLISH.encode(), successor.OLD_ENGLISH.encode(), 1))):
            check(mutated != raw, "actual changed semantic mutant " + label)
            reject(lambda r=mutated: repinned(before[path], r, path), "independently repinned semantic " + label)
        actual4 = {p: current[p] for p in successor.SOURCE_PATHS}
        old4 = {p: before[p] for p in successor.SOURCE_PATHS}
        check(successor.source_predecessor(actual4, root) == old4, "source4 exact comparison API")
        returned = successor.source_predecessor(actual4, root)
        returned[path] = b"forged"
        check(successor.source_predecessor(actual4, root) == old4, "comparison copy never aliases live proof")
        for label, rows in (("old", old4), ("missing", {p: r for p, r in actual4.items() if p != path}),
                            ("extra", {**actual4, "extra": b"x"}), ("type", {**actual4, path: bytearray(raw)}),
                            ("mixed", {**actual4, path: before[path]}), ("neighbor", {**actual4, path: raw + b"\n"})):
            reject(lambda r=rows: successor.source_predecessor(r, root), "source4 API " + label)
        ui4 = {p: current[p] for p in successor.CURRENT_UI_PATHS}
        check(successor.ui_predecessor(ui4, root) == {p: before[p] for p in ui4}, "UI3/ledger exact comparison API")
        receipts = proof["receipts"]
        if receipts is None:
            check(current == source and successor.RECEIPT_COMMIT is None, "unbound receipt is only source4")
            reject(lambda: successor._receipt_semantics(source, source), "no invented receipt")
        else:
            check({p for p in source if source[p] != receipts[p]} == {successor.LEDGER_PATH}, "separate ledger1")
            check(successor._receipt_semantics(source, receipts) == successor.RECEIPT_PARENT, "actual official first3 export revision")
            check(successor._ledger_inverse(source[successor.LEDGER_PATH], receipts[successor.LEDGER_PATH]) == source[successor.LEDGER_PATH],
                  "old277 raw prefix and41852 receipts exact")
            reject(lambda: successor._receipt_semantics(source, source), "receipt rollback")
            ledger = successor._loads(receipts[successor.LEDGER_PATH])
            for label in ("old receipt", "target", "old key", "native", "prefix"):
                mutated = copy.deepcopy(ledger)
                if label == "old receipt":
                    key = next(k for k in mutated["accepted"]["ja"] if k != successor.RECEIPT_ID)
                    mutated["accepted"]["ja"][key]["target_sha256"] = "0" * 64
                elif label == "target":
                    mutated["accepted"]["ja"][successor.RECEIPT_ID]["target_sha256"] = "0" * 64
                elif label == "old key":
                    mutated["accepted"]["ja"][successor.OLD_RECEIPT_ID] = mutated["accepted"]["ja"][successor.RECEIPT_ID]
                elif label == "native":
                    mutated["native_review"] = "PASS"
                else:
                    mutated["batches"][0]["order"] = "forged"
                mutated["accepted_sha256"] = successor._digest(mutated["accepted"])
                changed = (json.dumps(mutated, ensure_ascii=False, indent=2) + "\n").encode()
                with mock.patch.object(successor, "RECEIPT_RAW_SHA256", (successor._sha(source[successor.LEDGER_PATH]), successor._sha(changed))):
                    reject(lambda r=changed: successor._receipt_semantics(source, {**receipts, successor.LEDGER_PATH: r}),
                           "independently rehashed receipt " + label)
        previous_calls, actual_calls = pipeline._asset_one_billion_raw_call_views(before[path], raw)
        check(len(previous_calls) == len(actual_calls)
              and sum(c.korean == successor.NEW_KEY for c in actual_calls) == 1
              and not any(c.korean == successor.OLD_KEY for c in actual_calls), "pure JA actual old1/new1 call views")
        for label, mutated in (("old", before[path]), ("neighbor", raw + b"\n"), ("type", bytearray(raw))):
            reject(lambda r=mutated: pipeline._asset_one_billion_raw_call_views(before[path], r), "JA raw calls " + label)
        before470, _ = successor._snapshot(root, pipeline.STORY_FACT_PIPELINE_BEFORE_COMMIT, (path,))
        historical, live = pipeline._story_fact_call_views(path, before470[path], raw)
        check(live == actual_calls and historical != live, "actual JA consumer returns482 not historical payload")
        reject(lambda: pipeline._story_fact_call_views(path, before470[path], before[path]), "JA current claim cannot rollback")
        pipeline_raw = successor._disk_bytes(Path(root) / "tools/ja_translation_pipeline.py")
        prior_pipeline = pipeline.asset_one_billion_pipeline_predecessor(pipeline_raw)
        check(successor._sha(prior_pipeline) == pipeline.ASSET_ONE_BILLION_PIPELINE_BEFORE_SHA, "exact prior whole pipeline seal")
        for label, mutated in (("prior", prior_pipeline), ("appendix", pipeline_raw.replace(b"one-billion GameState inverse differs", b"forged-billion GameState inverse differs", 1)),
                               ("prefix", pipeline_raw.replace(b"from __future__ import annotations", b"from __future__ import annotations # forged", 1))):
            reject(lambda r=mutated: pipeline.asset_one_billion_pipeline_predecessor(r), "JA seal " + label)
        original_git, original_disk, original_inverse = successor._git, successor._disk_bytes, successor.product_inverse
        for kind in ("Git", "config", "function", "disk", "HEAD"):
            if kind == "Git":
                patch = mock.patch.object(successor, "_git", side_effect=ValueError("missing object"))
            elif kind == "config":
                patch = mock.patch.object(successor, "PRODUCT_PARENT", successor.PRODUCT_COMMIT)
            elif kind == "function":
                patch = mock.patch.object(successor, "product_inverse", lambda *args: original_inverse(*args))
            elif kind == "disk":
                patch = mock.patch.object(successor, "_disk_bytes", side_effect=lambda p:
                                          original_disk(p) + b"\n" if p == Path(root) / path else original_disk(p))
            else:
                patch = mock.patch.object(successor, "_git", side_effect=lambda r, *args, **kwargs:
                                          (successor.PRODUCT_PARENT + "\n").encode() if args[0] == "rev-parse"
                                          else original_git(r, *args, **kwargs))
            with patch:
                reject(lambda: successor.game_state_predecessor(raw, root), "warm actual boundary " + kind)
        proof["current"][path] = before[path]
        check(successor.game_state_predecessor(raw, root) == before[path], "yielded proof alias cannot forge live evidence")
        token = successor._ACTIVE.set(copy.deepcopy(proof))
        try:
            reject(lambda: successor.game_state_predecessor(raw, root), "forged active proof cannot admit current")
        finally:
            successor._ACTIVE.reset(token)
    check(successor._ACTIVE.get() is active, "normal scope restores prior identity")
    for response in (b"missing missing\n", b"0" * 40 + b" blob 0\n\n"):
        with mock.patch.object(successor, "_git", return_value=response):
            reject(lambda: successor._objects(root, [(successor.PRODUCT_COMMIT, successor.PRODUCT_COMMIT, "commit")]), "typed object identity/type")
    for label, name, value in (("parent", "PRODUCT_PARENT", successor.PRODUCT_COMMIT),
                               ("commit", "PRODUCT_COMMIT", None), ("population", "SOURCE_PATHS", (path,))):
        with mock.patch.object(successor, name, value):
            reject(lambda: successor._read_proof(root), "finite source rejects " + label)
    reject(lambda: successor._read_proof(Path(root) / "tools"), "foreign root")
    try:
        with successor.fresh_validation_proof(root):
            raise RuntimeError("ORDER482 consumer exception")
    except RuntimeError as error:
        check(error.args == ("ORDER482 consumer exception",) and successor._ACTIVE.get() is active,
              "consumer exception exit restores prior identity")
    for exceptional in (False, True):
        original_read, armed, entered, caught = successor._disk_bytes, [False], False, None
        def read(p):
            value = original_read(p)
            return value + b"\n" if armed[0] and p == Path(root) / path else value
        token = successor._ACTIVE.set(None)
        try:
            try:
                with mock.patch.object(successor, "_disk_bytes", read):
                    with successor.fresh_validation_proof(root):
                        entered, armed[0] = True, True
                        if exceptional:
                            raise RuntimeError("consumer exception cannot hide changed physical source")
            except Exception as error:
                caught = error
            check(entered and armed[0], "late mutation enters actual proof " + str(exceptional))
            check(type(caught) is ValueError and caught.args == ("ORDER-482: actual current Git/disk differs",),
                  "late mutation has exact guard failure " + str(exceptional))
            check(successor._ACTIVE.get() is None, "late failed invocation clears own scope " + str(exceptional))
        finally:
            successor._ACTIVE.reset(token)
        check(successor._ACTIVE.get() is active, "late failure restores caller identity " + str(exceptional))
    for locale in ("zh-CN", "zh-TW"):
        target = successor.TARGETS[locale]
        check(zh.validate_text(locale, successor.RECEIPT_ID, successor.NEW_KEY, target) == [], "original Chinese validator normal " + locale)
        masked = zh._ui_asset_one_billion_fraction_numbers(locale, successor.RECEIPT_ID, successor.NEW_KEY, target)
        check(masked is not None and not masked[2] and "10" in masked[0] and "30" in masked[0]
              and "10" in masked[1] and "30" in masked[1] and "三分之一" not in masked[1], "mask only verified fraction " + locale)
        for label, mutated in (("denominator", target.replace("三分之一", "四分之一")),
                               ("numerator", target.replace("三分之一", "三分之二")),
                               ("missing fraction", target.replace("三分之一", "")),
                               ("duplicate fraction", target.replace("三分之一", "三分之一三分之一")),
                               ("first amount", target.replace("10", "11", 1)),
                               ("goal amount", target.replace("30", "31", 1)),
                               ("reversed amounts", target.replace("10", "TMP").replace("30", "10").replace("TMP", "30")),
                               ("negative", target.replace("10", "-10", 1)), ("positive", target.replace("10", "+10", 1)),
                               ("decimal", target.replace("10", "10.5", 1)), ("percent", target.replace("10", "10%", 1)),
                               ("minutes", target.replace("三分之一", "三分钟" if locale == "zh-CN" else "三分鐘")),
                               ("monthly", target + "每月"), ("extra quantity", target + " 两次"),
                               ("extra time", target + " 2:00"), ("currency", target.replace("韩元", "美元").replace("韓元", "美元")),
                               ("fraction role", target.replace("10", "三分之一", 1)),
                               ("promise", target + ("现在开始加速。" if locale == "zh-CN" else "現在開始加速。")),
                               ("token", target + "%s"), ("LF", target + "\n")):
            check(bool(zh.validate_text(locale, successor.RECEIPT_ID, successor.NEW_KEY, mutated)), "original Chinese rejects " + locale + " " + label)
        for key, source_text in ((successor.RECEIPT_ID + " ", successor.NEW_KEY),
                                 (successor.RECEIPT_ID, successor.NEW_KEY + " "), ("ui:unowned:/unowned", successor.NEW_KEY)):
            check(zh._ui_asset_one_billion_fraction_numbers(locale, key, source_text, target) is None,
                  "fraction contract is OFF for different key/source " + locale)
            check(bool(zh.validate_text(locale, key, source_text, target)), "original generic validator not bypassed " + locale)
    check(zh._ui_asset_one_billion_fraction_numbers("ja", successor.RECEIPT_ID, successor.NEW_KEY, successor.TARGETS["ja"]) is None,
          "Chinese fraction contract OFF for Japanese")
    if inventory is not None:
        original = copy.deepcopy(inventory)
        previous = successor.source_predecessor_inventory(root, inventory)
        check(previous["source_manifest_sha256"] == successor.PREDECESSOR_SOURCE_MANIFEST_SHA256, "whole actual213 -> immutable480 census")
        check(inventory == original, "actual inventory never becomes historical payload")
        for label, p, value in (("rollback", path, successor.RAW_SHA256[path][0]),
                                ("neighbor", "systems/RelationshipSystem.gd", "0" * 64), ("extra", successor.LEDGER_PATH, "0" * 64)):
            changed = copy.deepcopy(inventory)
            changed["source_hashes"][p] = value
            changed["source_manifest_sha256"] = successor._digest(changed["source_hashes"])
            reject(lambda r=changed: successor.source_predecessor_inventory(root, r), "rehashed whole census " + label)
        reject(lambda: successor.source_predecessor_inventory(root, previous), "historical census cannot claim current")
    if ui is not None:
        import ja_translation_audit as ja
        actual = successor._loads(successor._disk_bytes(Path(root) / successor.UI_PATHS[0]))
        entries, errors = ja.asset_one_billion_retained_ja_entries(ui, actual)
        check(not errors and set(entries) == {successor.OLD_KEY}, "actual supplied UI proves exact retained10B key")
        for key in (successor.OLD_KEY, successor.NEW_KEY):
            entries, errors = ja.asset_one_billion_retained_ja_entries(ui, {**actual, key: "forged"})
            check(bool(errors) and not entries, "retained rejects supplied target " + key)
        for label, calls in (("old", tuple(replace(c, korean=successor.OLD_KEY, english=successor.OLD_ENGLISH)
                                            if c.path == path and c.korean == successor.NEW_KEY else c for c in ui.calls)),
                             ("missing", tuple(c for c in ui.calls if not (c.path == path and c.korean == successor.NEW_KEY))),
                             ("coordinate", tuple(replace(c, line=c.line + 1) if c.path == path and c.korean == successor.NEW_KEY else c for c in ui.calls))):
            entries, errors = ja.asset_one_billion_retained_ja_entries(replace(ui, calls=calls), actual)
            check(bool(errors) and not entries, "retained rejects actual-call claim " + label)
    return failures, cases


def run_one_billion_consumer_checks(root=history.ROOT):
    """Original changed fresh contexts once each; no collector or old tests."""
    import asset_one_billion_log_history as successor
    import market_cycle_label_history as market
    import order470_source_compat as facts
    import pr31_intake_history as intake
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER482 consumer: " + label)
    prior = tuple(module._ACTIVE.get() for module in (successor, history, market, facts, intake))
    with successor.fresh_validation_proof(root) as latest, history.fresh_validation_proof(root) as wealth, \
            market.fresh_validation_proof(root) as market_proof, facts.fresh_validation_proof(root) as fact, \
            intake.fresh_validation_proof(root) as pr31:
        check(all(proof["head"] == latest["head"] for proof in (wealth, market_proof, fact, pr31)), "all original admissions same actual HEAD")
        check(wealth["receipts"] == latest["before"] == wealth["one_billion_before"], "immutable480 receipt endpoint")
        for label, proof, paths in (("wealth", wealth, successor.PATHS),
                                     ("market", market_proof, successor.CURRENT_UI_PATHS),
                                     ("facts", fact, (successor.GAME_STATE_PATH, successor.LEDGER_PATH)),
                                     ("PR31", pr31, successor.CURRENT_UI_PATHS)):
            check(all(proof["current"][path] == latest["current"][path] for path in paths), label + " actual482 payload")
        check(successor.GAME_STATE_PATH not in pr31["current"]
              and {path for path in pr31["current"] if pr31["pre_one_billion_successor"][path]
                   != pr31["one_billion_source"][path]} == set(successor.UI_PATHS), "PR31 original population and exact UI3 source delta")
    check(all(module._ACTIVE.get() is value for module, value in
              zip((successor, history, market, facts, intake), prior)),
          "all original admission exits restore prior scopes")
    return failures, cases


def one_billion_main():
    failures, cases = run_one_billion_checks()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"ORDER482_ONE_BILLION_{'FAIL' if failures else 'OK'} cases={cases} native_review=OPEN")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(one_billion_main() if sys.argv[1:] == ["--one-billion-only"] else main())
