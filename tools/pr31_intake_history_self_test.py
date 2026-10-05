#!/usr/bin/env python3
"""Bounded actual-Git intake proof and negative delta controls; no game run."""
from __future__ import annotations

import copy
import hashlib
import json
import sys
from unittest import mock

import pr31_intake_history as history


def _changed(raw, path, value):
    parsed = json.loads(raw)
    row = parsed
    for key in path[:-1]:
        row = row[key]
    row[path[-1]] = value
    return (json.dumps(parsed, ensure_ascii=False, indent=2) + "\n").encode()


def inventory_cases(module):
    failures, cases = [], 0

    def check(value, name):
        nonlocal cases
        cases += 1
        if not value:
            failures.append("PR31 inventory delta: " + name)

    with history.fresh_validation_proof() as proof:
        path = history.INVENTORY_PATH
        before, after = proof["before"][path], proof["current"][path]
        target = module.ORDER156_AUDITED_SOURCE_FILE_TRANSITIONS[path][1]
        observed = history._sha(after)
        result, errors = module._order363_inventory_observation(path, observed, after, current_admitted=True)
        check(not errors and result == target, "real current -> pre-intake ->362->360->156")
        for label, raw, claim, admitted in (
                ("rollback", before, history._sha(before), True),
                ("leading whitespace", b" " + after, history._sha(b" " + after), True),
                ("trailing whitespace", after + b"\n", history._sha(after + b"\n"), True),
                ("wrong hash", after, "0" * 64, True),
                ("failed current admission", after, observed, False),
                ("nonbytes", after.decode(), observed, True)):
            result, errors = module._order363_inventory_observation(path, claim, raw, current_admitted=admitted)
            check(result == claim and bool(errors), label)
        document = json.loads(after)
        mutations = (
            (("public_story_demo_package_contract", "package_source_commit"), "0" * 40),
            (("corpus_contract", "ko_events"), -1),
            (("content_axes", 0, "candidate_scan", "expected_event_count"), -1),
            (("content_axes", 0, "candidate_scan", "expected_content_sha256"), "0" * 64),
            (("content_axes",), list(reversed(document["content_axes"]))),
        )
        for keys, value in mutations:
            raw = _changed(after, keys, value)
            result, errors = module._order363_inventory_observation(path, history._sha(raw), raw, current_admitted=True)
            check(result == history._sha(raw) and bool(errors), "changed current " + repr(keys))
            try:
                history.inventory_inverse(before, raw)
            except (ValueError, KeyError, IndexError, TypeError):
                check(True, "literal inverse rejects " + repr(keys))
            else:
                check(False, "literal inverse rejects " + repr(keys))
        for path in ("./" + history.INVENTORY_PATH, history.INVENTORY_PATH + ".other"):
            result, errors = module._order363_inventory_observation(path, observed, after, current_admitted=False)
            check(result == observed and not errors, "other path does not project " + path)
    return failures, cases


def run():
    failures, cases = [], 0

    def check(value, name):
        nonlocal cases
        cases += 1
        if not value:
            failures.append("PR31 intake delta: " + name)

    def reject(function, name):
        try:
            function()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, name)
        else:
            check(False, name)

    with history.fresh_validation_proof() as proof:
        check(len(history.CONTENT_PATHS) == 71 and len(set(history.CONTENT_PATHS)) == 71, "exact71 content files")
        check(all(proof["pre_source_successor"][p] == proof["before"][p] for p in history.PROTECTED_PATHS),
              "PR31 protected raw population before exact source-only successor")
        check(all(proof["pre_fact_successor"][p] == proof["pre_source_successor"][p]
                  for p in proof["pre_fact_successor"] if p not in history.source_successor.PRODUCT_PATHS),
              "source-only successor preserves all prose and receipts")
        check(all(proof["fact_current"][p] == proof["pre_fact_successor"][p]
                  for p in proof["fact_current"] if p not in (*history.fact_successor.PRODUCT_PATHS,
                                                              history.LEDGER_PATH)),
              "fact successor preserves every unrelated PR31 product")
        for path in history.fact_successor.ARC_PATHS:
            check(not history.source_errors(proof["current"][path], path), "actual fact source admitted " + path)
            check(bool(history.source_errors(proof["pre_fact_successor"][path], path)),
                  "pre470 comparison is not current admission " + path)
            check(bool(history.source_errors(proof["current"][path] + b"\n", path)),
                  "fact source raw mutation " + path)
        check(all(not history.source_errors(proof["current"][p], p) for p in history.CONTENT_PATHS), "all71 current raw admitted")
        for path in history.CONTENT_PATHS:
            check(bool(history.source_errors(proof["current"][path] + b"\n", path)), "current raw mutation " + path)
            if path in history.HISTORY_CONTENT_PATHS:
                check(history.project_bytes(proof["current"][path], path)
                      == history.previous.project_bytes(proof["before"][path], path), "composed history " + path)
                check(bool(history.source_errors(proof["before"][path], path)), "rollback not current " + path)
                check(history.project_bytes(proof["before"][path], path)
                      == history.previous.project_bytes(proof["before"][path], path),
                      "explicit historical comparison remains idempotent " + path)
        check(len(history.ENDING_PATHS) == 5, "exact5 endings hash-only comparison paths")
        for path in history.ENDING_PATHS:
            raw = proof["current"][path]
            expected = history.previous.project_byte_hash(history._sha(proof["before"][path]), path)
            observed, errors = history.observed_byte_hash(path, history._sha(raw), raw)
            check(observed == expected and not errors, "ending actual hash-only predecessor " + path)
            check(history.project_byte_hash("0" * 64, path) == "0" * 64,
                  "ending unapproved hash cannot borrow predecessor " + path)
            observed, errors = history.observed_byte_hash(path, "0" * 64, raw)
            check(observed == "0" * 64 and bool(errors), "ending hash/raw mismatch fails closed " + path)
            altered = raw + b"\n"
            observed, errors = history.observed_byte_hash(path, history._sha(altered), altered)
            check(observed == history._sha(altered) and bool(errors), "ending changed raw fails closed " + path)
            check(history.project_bytes(raw, path) == history.previous.project_bytes(raw, path),
                  "ending payload is never replaced with historical prose " + path)
        transitions = history.receipt_transitions(history.ROOT, {})
        check(len(transitions) == 1 + bool(history.REPAIR_COMMIT) + bool(history.SECOND_COMMIT)
              + bool(history.THIRD_LEDGER_COMMIT) + bool(history.FOURTH_COMMIT)
              + bool(history.fact_successor.RECEIPT_COMMIT),
              "exact product/repair receipt transitions")
        for commit, before, after, delta, inverse in transitions:
            check(inverse(after, before, after) == before, "exact4 raw receipt inverse " + commit)
            altered = dict(after)
            altered[history.LEDGER_PATH] += b"\n"
            reject(lambda: inverse(altered, before, after), "receipt raw mutation " + commit)
            check((not delta["source_manifests"] if commit == history.INTAKE_COMMIT else bool(delta["source_manifests"]))
                  and delta["receipts"] == delta["batches"] == 0,
                  "comparison is not UI coverage/receipt reissue " + commit)
            check(delta["first_receipts"] == (9 if commit == history.INTAKE_COMMIT
                                               else 6 if commit in (history.FOURTH_COMMIT,
                                                                      history.fact_successor.RECEIPT_COMMIT) else 0)
                  and delta["corrections"] == (678 if commit == history.INTAKE_COMMIT
                                                else 24 if commit == history.REPAIR_COMMIT
                                                else 9 if commit == history.SECOND_COMMIT
                                                else 72 if commit == history.THIRD_LEDGER_COMMIT
                                                else 36 if commit == history.fact_successor.RECEIPT_COMMIT else 0),
                  "honest first/replaced receipt census " + commit)
        # Pure whole-union negatives exercise the same exact reviewed objects,
        # not a guessed normalized source or rewritten Git history.
        base, _ = history._snapshot(history.ROOT, history.MERGE_BASE, (history.LEDGER_PATH,))
        args = [base[history.LEDGER_PATH], proof["before"][history.LEDGER_PATH],
                proof["branch"][history.LEDGER_PATH], proof["after"][history.LEDGER_PATH]]
        forged = json.loads(args[3])
        key = next(iter(forged["accepted"]["ja"]))
        forged["accepted"]["ja"][key]["target_sha256"] = "0" * 64
        forged["accepted_sha256"] = history._digest(forged["accepted"])
        reject(lambda: history._ledger_union(*args[:3], json.dumps(forged, ensure_ascii=False).encode()),
               "forged old receipt with recalculated accepted digest")
        reject(lambda: history._ledger_union(*args[:3], args[1]), "omitted PR union")
        # Mixed source manifests cannot borrow an approved current raw hash.
        hashes = {path: history._sha(proof["current"][path]) for path in history.SOURCE_PATHS}
        inventory = {"source_hashes": hashes, "source_manifest_sha256": history._digest(hashes)}
        result = history.source_predecessor_inventory(history.ROOT, inventory)
        check(result["source_hashes"] == {path: history._sha(proof["before"][path]) for path in history.SOURCE_PATHS},
              "source comparison exact15 current predecessors")
        forged = copy.deepcopy(inventory)
        forged["source_hashes"][history.SOURCE_PATHS[0]] = "0" * 64
        forged["source_manifest_sha256"] = history._digest(forged["source_hashes"])
        reject(lambda: history.source_predecessor_inventory(history.ROOT, forged), "rehashed fake source census")
        # Collect once, in the real test invocation, instead of preserving a
        # private fixture or copying the collector's entire source grammar.
        from full_game_localization import collect
        full_inventory = collect(history.ROOT)
        stages = history.source_stage_manifest_digests(history.ROOT, full_inventory)
        source_only_predecessor = history.source_successor.source_predecessor_inventory(history.ROOT, full_inventory)
        expected_stages = {
            history._digest({**source_only_predecessor["source_hashes"],
                             **{path: history._sha(proof[stage][path]) for path in history.SOURCE_PATHS}})
            for stage in ("before", "after", "second", "third_source") if proof[stage] is not None
        }
        expected_stages.add(full_inventory["source_manifest_sha256"])
        expected_stages.add(history.fact_successor.PREDECESSOR_SOURCE_MANIFEST_SHA256)
        if proof["person_source"] is not None:
            expected_stages.add(history.fact_successor.RECEIPT_SOURCE_MANIFEST_SHA256)
        if proof["prose_source"] is not None:
            expected_stages.add(history.fact_successor.PERSON_RECEIPT_SOURCE_MANIFEST_SHA256)
        check(stages == expected_stages and history.CURRENT_SOURCE_MANIFEST_SHA256 in stages,
              "exact immutable source stages preserve e300 and actual source-only successor")
        check(len(stages) == 5 + int(proof["person_source"] is not None) + int(proof["prose_source"] is not None),
              "before/intake/corrected plus separately proven469/470/471 source populations")
        check(history.source_stage_manifest_digests(history.ROOT, full_inventory) is stages,
              "same-invocation source proof is reused only after actual verification")
        for label, path, value in (
                ("fake changed source", history.SOURCE_PATHS[0], "0" * 64),
                ("non-source metadata", history.LEDGER_PATH, history._sha(proof["current"][history.LEDGER_PATH])),
                ("target UI inserted", history.UI_PATHS[0], history._sha(proof["current"][history.UI_PATHS[0]])),
                ("Main mutation", "scenes/MainGame.gd", "0" * 64),
                ("unchanged runtime mutation", "systems/RelationshipSystem.gd", "0" * 64)):
            forged = {"source_hashes": {**full_inventory["source_hashes"], path: value}}
            forged["source_manifest_sha256"] = history._digest(forged["source_hashes"])
            reject(lambda d=forged: history.source_stage_manifest_digests(history.ROOT, d),
                   "stage manifest rejects rehashed " + label)
        forged = {"source_hashes": {k: v for k, v in full_inventory["source_hashes"].items()
                                    if k != "scenes/MainGame.gd"}}
        forged["source_manifest_sha256"] = history._digest(forged["source_hashes"])
        reject(lambda: history.source_stage_manifest_digests(history.ROOT, forged),
               "stage manifest rejects omitted actual Main source")
        old_inventory = history.source_predecessor_inventory(history.ROOT, full_inventory)
        reject(lambda: history.source_stage_manifest_digests(history.ROOT, old_inventory),
               "comparison-only predecessor cannot claim current source admission")
        if proof["repair"] is not None:
            history._validate_repair(proof["after"], proof["repair"])
            check(True, "actual24 stale corrections with3 official receipt rows")
            original = json.loads(proof["repair"][history.LEDGER_PATH])

            def repair_candidate(document):
                return {**proof["repair"], history.LEDGER_PATH:
                        (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()}

            forged = copy.deepcopy(original)
            forged["accepted"]["ja"][history.REPAIR_IDS[0]]["target_sha256"] = "0" * 64
            forged["accepted_sha256"] = history._digest(forged["accepted"])
            reject(lambda: history._validate_repair(proof["after"], repair_candidate(forged)),
                   "forged recovered target with rehashed accepted digest")
            for label, document in (("dropped old batch", {**original, "batches": original["batches"][1:]}),
                                    ("extra recovery batch", {**original, "batches": [*original["batches"], original["batches"][-1]]})):
                reject(lambda d=document: history._validate_repair(proof["after"], repair_candidate(d)), label)
            forged = copy.deepcopy(original)
            batch = forged["batches"][-1]
            locale = next(iter(batch["official_receipt_headers_by_locale"]))
            batch["native_review"] = "PASS"
            reject(lambda: history._validate_repair(proof["after"], repair_candidate(forged)),
                   "cannot relabel official machine receipt as native approval")
            with mock.patch.object(history, "REPAIR_BATCH_SHA256",
                                   {**history.REPAIR_BATCH_SHA256, locale: history._digest(batch)}):
                reject(lambda: history._validate_repair(proof["after"], repair_candidate(forged)),
                       "semantic OPEN boundary survives forged row pin")
        if proof["second"] is not None:
            before, after = proof["repair"], proof["second"]
            history._validate_second_successor(before, after)
            check(True, "actual conditional9 receipts and3 final sentences")
            for path in history.SECOND_TARGET_PATHS:
                check(history.second_overlay_inverse(before[path], after[path], path) == before[path],
                      "conditional final sentence raw inverse " + path)
                check(bool(history.source_errors(before[path], path)), "prior target is no longer current " + path)
                reject(lambda p=path: history.second_overlay_inverse(before[p], after[p] + b"\n", p),
                       "conditional target whitespace mutation " + path)
                reject(lambda p=path: history.second_overlay_inverse(before[p], before[p], p),
                       "conditional target rollback " + path)
                neighbor = json.loads(after[path])
                neighbor[0]["title"] += " changed neighbor"
                raw = (json.dumps(neighbor, ensure_ascii=False, indent=2) + "\n").encode()
                reject(lambda p=path, r=raw: history.second_overlay_inverse(before[p], r, p),
                       "conditional target neighbor mutation " + path)
            document = json.loads(after[history.LEDGER_PATH])
            document["accepted"]["ja"][history.SECOND_IDS[0]]["source_sha256"] = "0" * 64
            document["accepted_sha256"] = history._digest(document["accepted"])
            forged = {**after, history.LEDGER_PATH:
                      (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()}
            reject(lambda: history._validate_second_successor(before, forged),
                   "conditional receipt forged source with recalculated checksum")
            forged = {**after, history.SOURCE_PATHS[0]: after[history.SOURCE_PATHS[0]] + b"\n"}
            reject(lambda: history._validate_second_successor(before, forged), "conditional repair cannot change Korean")
        if proof["third_source"] is not None:
            before, after = proof["second"], proof["third_source"]
            history._validate_third_source(before, after)
            check(True, "actual authored120 prose leaves and exact generated metadata")
            for path in history.THIRD_PRODUCT_SHA256:
                check(history.third_product_inverse(before[path], after[path], path) == before[path],
                      "third source whole-raw inverse " + path)
                reject(lambda p=path: history.third_product_inverse(before[p], after[p] + b"\n", p),
                       "third source whitespace " + path)
                reject(lambda p=path: history.third_product_inverse(before[p], before[p], p),
                       "third source rollback " + path)
                if path in history.THIRD_CONTENT_PATHS:
                    check(bool(history.source_errors(before[path], path)), "pre-third prose is not current " + path)
                    neighbor = json.loads(after[path])
                    neighbor[0]["title"] += " unowned neighbor"
                    raw = (json.dumps(neighbor, ensure_ascii=False, indent=2) + "\n").encode()
                    # Independent selector guard still rejects a new neighbor
                    # even when a fixture deliberately recomputes raw pins.
                    with mock.patch.dict(history.THIRD_PRODUCT_SHA256,
                                         {path: (history._sha(before[path]), history._sha(raw))}):
                        reject(lambda p=path, r=raw: history.third_product_inverse(before[p], r, p),
                               "third source selector survives rehashed neighbor " + path)
            forged = {**after, history.LEDGER_PATH: after[history.LEDGER_PATH] + b"\n"}
            reject(lambda: history._validate_third_source(before, forged), "source-only stage cannot change receipts")
            path = history.INVENTORY_PATH
            check(history.release_inventory_predecessor(proof["current"][path]) == proof["before"][path],
                  "source-only inventory -> third -> intake -> original raw")
            reject(lambda: history.release_inventory_predecessor(after[path]),
                   "pre-retirement inventory cannot claim current admission")
            for locale in history.LOCALES:
                receipt = history._leaf_receipt(after, locale, history.THIRD_ENDING_IDS[0])
                row = history._rows(after["content/endings.json"])["stable_success"]
                target = history._rows(after["content/endings_" + locale + ".json"])["stable_success"]
                check(receipt == {"source_sha256": history._digest({"path": "content/endings.json",
                                      "field": ("description",), "ko": row["description"]}),
                                  "target_sha256": history._digest(target["description"])},
                      "ending receipt binds actual source/target " + locale)
            reject(lambda: history._leaf_receipt(after, "ja", "catalog:stable_success:/description"),
                   "recovery does not widen to arbitrary groups")
        if proof["third_receipts"] is not None:
            before, after = proof["third_source"], proof["third_receipts"]
            history._validate_third_receipts(before, after)
            check(True, "actual72 existing receipt corrections and6 official group/locale rows")
            original = json.loads(after[history.LEDGER_PATH])

            def third_candidate(document):
                return {**after, history.LEDGER_PATH:
                        (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()}

            for field in ("source_sha256", "target_sha256"):
                forged = copy.deepcopy(original)
                forged["accepted"]["ja"][history.THIRD_ENDING_IDS[0]][field] = "0" * 64
                forged["accepted_sha256"] = history._digest(forged["accepted"])
                reject(lambda d=forged: history._validate_third_receipts(before, third_candidate(d)),
                       "third forged ending receipt with rehashed checksum " + field)
            for label, batches in (
                    ("dropped original batch", original["batches"][1:]),
                    ("missing group row", original["batches"][:-1]),
                    ("duplicated group row", [*original["batches"], original["batches"][-1]])):
                reject(lambda b=batches: history._validate_third_receipts(before, third_candidate({**original, "batches": b})),
                       "third " + label)
            forged = copy.deepcopy(original)
            batch = forged["batches"][-1]
            locale = next(iter(batch["official_receipt_headers_by_locale"]))
            batch["native_review"] = "PASS"
            with mock.patch.dict(history.THIRD_BATCH_SHA256, {(batch["group"], locale): history._digest(batch)}):
                reject(lambda: history._validate_third_receipts(before, third_candidate(forged)),
                       "third native boundary survives rehashed official row pin")
            forged = {**after, history.THIRD_CONTENT_PATHS[0]: after[history.THIRD_CONTENT_PATHS[0]] + b"\n"}
            reject(lambda: history._validate_third_receipts(before, forged), "third receipt-only stage cannot change prose")
        if proof["fourth"] is not None:
            before, after = proof["third_receipts"], proof["fourth"]
            history._validate_fourth_first_receipts(before, after)
            check(True, "actual6 first receipts with3 official rows and no prose changes")
            original = json.loads(after[history.LEDGER_PATH])
            old = json.loads(before[history.LEDGER_PATH])
            check(sum(map(len, original["accepted"].values())) == sum(map(len, old["accepted"].values())) + 6,
                  "fourth first receipts add exactly6 accepted values")

            def fourth_candidate(document):
                return {**after, history.LEDGER_PATH:
                        (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode()}

            for label, edit in (
                    ("missing new leaf", lambda d: d["accepted"]["ja"].pop(history.FOURTH_IDS[0])),
                    ("extra new leaf", lambda d: d["accepted"]["ja"].update({"events:unowned:/description":
                        d["accepted"]["ja"][history.FOURTH_IDS[0]]})),
                    ("existing receipt changed", lambda d: d["accepted"]["ja"][history.REPAIR_IDS[0]].update(
                        {"target_sha256": "0" * 64})),
                    ("new source drift", lambda d: d["accepted"]["ja"][history.FOURTH_IDS[0]].update(
                        {"source_sha256": "0" * 64})),
                    ("new target drift", lambda d: d["accepted"]["ja"][history.FOURTH_IDS[0]].update(
                        {"target_sha256": "0" * 64}))):
                forged = copy.deepcopy(original)
                edit(forged)
                forged["accepted_sha256"] = history._digest(forged["accepted"])
                reject(lambda d=forged: history._validate_fourth_first_receipts(before, fourth_candidate(d)),
                       "fourth rejects rehashed " + label)
            for label, batches in (("missing locale row", original["batches"][:-1]),
                                    ("extra row", [*original["batches"], original["batches"][-1]]),
                                    ("old prefix deletion", original["batches"][1:])):
                reject(lambda b=batches: history._validate_fourth_first_receipts(
                    before, fourth_candidate({**original, "batches": b})), "fourth " + label)
            forged = copy.deepcopy(original)
            batch = forged["batches"][-1]
            locale = next(iter(batch["official_receipt_headers_by_locale"]))
            batch["native_review"] = "PASS"
            with mock.patch.dict(history.FOURTH_BATCH_SHA256, {locale: history._digest(batch)}):
                reject(lambda: history._validate_fourth_first_receipts(before, fourth_candidate(forged)),
                       "fourth native boundary survives rehashed official row pin")
            for path in ("content/events/arc_new_characters.json", "content/events_ja/arc_new_characters.json"):
                forged = {**after, path: after[path] + b"\n"}
                reject(lambda d=forged: history._validate_fourth_first_receipts(before, d),
                       "fourth source/target prose remains unchanged " + path)
            already = copy.deepcopy(old)
            already["accepted"]["ja"][history.FOURTH_IDS[0]] = original["accepted"]["ja"][history.FOURTH_IDS[0]]
            already["accepted_sha256"] = history._digest(already["accepted"])
            invalid_before = {**before, history.LEDGER_PATH: json.dumps(already, ensure_ascii=False).encode()}
            reject(lambda: history._validate_fourth_first_receipts(invalid_before, after),
                   "fourth cannot reuse first-receipt authority for existing receipts")
    check(history._ACTIVE.get() is None, "proof scope cleared")
    # Warm-success followed by an unavailable actual object must fail. No
    # cached verdict from the successful scope above may substitute for Git.
    real_git = history._git

    def missing(root, *args, **kwargs):
        if args[:2] == ("cat-file", "--batch"):
            return (history.INTAKE_PARENT + " missing\n").encode()
        return real_git(root, *args, **kwargs)

    with mock.patch.object(history, "_git", missing):
        reject(lambda: history.current_content_raw(), "missing object after prior success")
    check(history._ACTIVE.get() is None, "failed proof did not leak context")
    # A scoped success cannot outlive an observed HEAD/disk change either.
    changed = False

    def changed_head(root, *args, **kwargs):
        if changed and args == ("rev-parse", "--verify", "HEAD^{commit}"):
            return ("0" * 40 + "\n").encode()
        return real_git(root, *args, **kwargs)

    def change_inside_scope():
        nonlocal changed
        with history.fresh_validation_proof():
            changed = True

    with mock.patch.object(history, "_git", changed_head):
        reject(change_inside_scope, "scope exit rereads HEAD")
    check(history._ACTIVE.get() is None, "changed HEAD did not leak context")
    return failures, cases


def run_person_checks():
    """471 current admission/projection and distinct42/18 receipt endpoints."""
    failures, cases = [], 0

    def check(value, name):
        nonlocal cases
        cases += 1
        if not value:
            failures.append("PR31 person-deal successor: " + name)

    with history.fresh_validation_proof() as proof, history.previous.fresh_validation_proof():
        successor = history.fact_successor
        check(proof["person_source"] is not None, "actual person source stage is present")
        if proof["person_source"] is None:
            return failures, cases
        changed = set(successor.PERSON_PATHS) | {history.LEDGER_PATH}
        check(all(proof["person_current"][path] == proof["fact_current"][path]
                  for path in proof["person_current"] if path not in changed),
              "only person themes and later receipts follow immutable470")
        check(proof["person_source"][history.LEDGER_PATH] == proof["fact_current"][history.LEDGER_PATH],
              "source stage contributes no acceptance")
        for path in successor.PERSON_PATHS:
            raw = proof["current"][path]
            check(not history.source_errors(raw, path), "actual theme admitted " + path)
            check(bool(history.source_errors(proof["fact_current"][path], path)), "pre471 raw is not current " + path)
            check(bool(history.source_errors(raw + b"\n", path)), "theme neighboring raw rejected " + path)
        for path in successor.PERSON_PATHS[:2]:
            before, after = history.historical_blobs(path)
            check(after == proof["current"][path], "historical API retains actual current bytes " + path)
            check("description_if_known" not in history._rows(before)[successor.PERSON_EVENT_ID],
                  "comparison restores predecessor without new DIK " + path)
            check(set(successor.PERSON_TEXT_LEAVES) <= set(history.HISTORICAL_JSON_LEAVES[path]),
                  "exact six person selectors are accounted " + path)
            row = history._rows(after)[successor.PERSON_EVENT_ID]
            expected = history.previous.project_payload(
                [history._rows(proof["before"][path])[successor.PERSON_EVENT_ID]], path)
            check(history.project_payload([row], path) == expected, "exact current row projects " + path)
            mutated = copy.deepcopy(row)
            mutated["title"] += " unowned"
            check(history.project_payload([mutated], path) == [mutated], "neighbor cannot borrow projection " + path)
        hashes = {path: history._sha(proof["current"][path]) for path in history.SOURCE_PATHS}
        partial = {"source_hashes": hashes, "source_manifest_sha256": history._digest(hashes)}
        projected = history.source_predecessor_inventory(history.ROOT, partial)
        check(projected["source_hashes"] == {path: history._sha(proof["before"][path])
                                            for path in history.SOURCE_PATHS}, "original partial15 comparison stays exact")
        if successor.PERSON_RECEIPT_COMMIT is not None:
            transitions = history.receipt_transitions(history.ROOT, {})
            fact = next(row for row in transitions if row[0] == successor.RECEIPT_COMMIT)
            person = next(row for row in transitions if row[0] == successor.PERSON_RECEIPT_COMMIT)
            check(fact[0] == successor.RECEIPT_COMMIT and fact[2][history.LEDGER_PATH]
                  == proof["fact_current"][history.LEDGER_PATH], "original42 endpoint remains exact470 R4")
            check((fact[3]["first_receipts"], fact[3]["corrections"]) == (6, 36),
                  "original470 acceptance remains42, not merged60")
            check(person[0] == successor.PERSON_RECEIPT_COMMIT
                  and person[1][history.LEDGER_PATH] == proof["person_source"][history.LEDGER_PATH]
                  and person[2][history.LEDGER_PATH] == proof["person_current"][history.LEDGER_PATH],
                  "person18 transition binds source/accepted ledger separately")
            check((person[3]["first_receipts"], person[3]["corrections"], person[3]["correction_batches"]) == (6, 12, 3),
                  "person acceptance is six first and twelve corrected")
            check(all(row[3]["receipts"] == row[3]["batches"] == 0
                      and not any(row[3]["ui_by_locale"].values()) for row in (fact, person)),
                  "text receipts never become UI coverage")
    return failures, cases


def run_prose_checks():
    """472 current25/projection10 and three immutable receipt endpoints."""
    failures, cases = [], 0

    def check(value, name):
        nonlocal cases
        cases += 1
        if not value:
            failures.append("PR31 recall successor: " + name)

    with history.fresh_validation_proof() as proof, history.previous.fresh_validation_proof():
        successor = history.fact_successor
        check(proof["prose_source"] is not None, "actual recall source stage is present")
        if proof["prose_source"] is None:
            return failures, cases
        check(len(history.CONTENT_PATHS) == 71 and len(history.SOURCE_PATHS) == 15,
              "immutable intake71 and partial-source15 populations remain original")
        check(all(proof["prose_current"][path] == proof["person_current"][path]
                  for path in proof["prose_current"] if path not in (*successor.PROSE_PATHS, history.LEDGER_PATH)),
              "only declared recall paths/receipts follow immutable471")
        check(proof["prose_source"][history.LEDGER_PATH] == proof["person_current"][history.LEDGER_PATH],
              "source10 adds zero receipts")
        for path in successor.PROSE_PATHS:
            raw = proof["current"][path]
            check(not history.source_errors(raw, path), "actual source/target raw admitted " + path)
            check(bool(history.source_errors(raw + b"\n", path)), "neighbor raw rejected " + path)
            if raw != proof["person_current"][path]:
                check(bool(history.source_errors(proof["person_current"][path], path)),
                      "pre472 comparison is not current " + path)
        historical = history.HISTORICAL_JSON_LEAVES
        for path in successor.PROSE_PRODUCT_PATHS:
            before, after = history.historical_blobs(path)
            check(after == proof["current"][path]
                  and before == history.previous.project_bytes(proof["before"][path], path),
                  "actual current and composed comparison stay separate " + path)
            check(set(successor.prose_selectors(path)) <= set(historical[path]), "all owned leaves accounted " + path)
            check(history.project_bytes(after, path) == before, "exact raw projection " + path)
            claim, errors = history.observed_byte_hash(path, "0" * 64, after)
            check(claim == "0" * 64 and bool(errors), "forged read claim rejected " + path)
        hashes = {path: history._sha(proof["current"][path]) for path in history.SOURCE_PATHS}
        partial = {"source_hashes": hashes, "source_manifest_sha256": history._digest(hashes)}
        check(history.source_predecessor_inventory(history.ROOT, partial)["source_hashes"]
              == {path: history._sha(proof["before"][path]) for path in history.SOURCE_PATHS},
              "partial15 inverse does not invent Hyunsu census membership")
        transitions = {row[0]: row for row in history.receipt_transitions(history.ROOT, {})}
        for commit, stage, counts in ((successor.RECEIPT_COMMIT, "fact_current", (6, 36)),
                                     (successor.PERSON_RECEIPT_COMMIT, "person_current", (6, 12)),
                                     (successor.PROSE_RECEIPT_COMMIT, "prose_current", (0, 120))):
            if commit is None:
                continue
            row = transitions[commit]
            check(row[2][history.LEDGER_PATH] == proof[stage][history.LEDGER_PATH]
                  and (row[3]["first_receipts"], row[3]["corrections"]) == counts,
                  "separate immutable receipt endpoint " + stage)
            check(row[3]["receipts"] == row[3]["batches"] == 0 and not any(row[3]["ui_by_locale"].values()),
                  "prose acceptance cannot extend UI coverage " + stage)
    return failures, cases


def run_prose_metadata_checks():
    """The current metadata observation still reaches the original inventory."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("PR31 recall metadata: " + label)

    with history.fresh_validation_proof() as proof:
        successor, path = history.fact_successor, history.INVENTORY_PATH
        check(proof["current"][path] != proof["prose_current"][path], "actual metadata is separate from receipt endpoint")
        check(all(proof["current"][p] == proof["prose_current"][p] for p in proof["current"]
                  if p not in successor.PROSE_METADATA_PATHS), "only exact two metadata files follow120")
        check(history.release_inventory_predecessor(proof["current"][path]) == proof["before"][path],
              "actual metadata composes through470/469/PR31 original inventory inverse")
        for label, raw in (("rollback", proof["prose_current"][path]),
                           ("neighbor", proof["current"][path] + b"\n")):
            try:
                history.release_inventory_predecessor(raw)
            except (ValueError, TypeError, KeyError, IndexError, OSError):
                check(True, label)
            else:
                check(False, label)
        rows = history.receipt_transitions(history.ROOT, {})
        receipt = next(row for row in rows if row[0] == successor.PROSE_RECEIPT_COMMIT)
        check(receipt[2][history.LEDGER_PATH] == proof["prose_current"][history.LEDGER_PATH]
              and (receipt[3]["first_receipts"], receipt[3]["corrections"]) == (0, 120),
              "metadata does not create or extend the120 receipt transition")
    return failures, cases


def main():
    person_only = sys.argv[1:] == ["--person-self-test"]
    prose_only = sys.argv[1:] == ["--prose-self-test"]
    metadata_only = sys.argv[1:] == ["--prose-metadata-self-test"]
    failures, cases = (run_prose_metadata_checks() if metadata_only else run_prose_checks() if prose_only
                       else run_person_checks() if person_only else run())
    for error in failures:
        print(error, file=sys.stderr)
    label = ("PR31_PROSE_METADATA" if metadata_only else "PR31_PROSE_SUCCESSOR" if prose_only
             else "PR31_PERSON_SUCCESSOR" if person_only else "PR31_INTAKE_HISTORY")
    print(f"{label}_{'FAIL' if failures else 'OK'} cases={cases} current_files=71 native_review=OPEN")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
