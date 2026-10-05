#!/usr/bin/env python3
"""Exact two-line decision risk width successor and current collector/manifest faults.

Historical tests are not rerun or rewritten. Git doubles below are explicitly
negative controls; actual immutable object admission and normal CLI are separate.
"""
import copy
from dataclasses import replace
import hashlib
import json
from pathlib import Path
import subprocess
import sys
sys.dont_write_bytecode = True
from unittest import mock
import ui_translation_append as append

ROOT = Path(__file__).resolve().parents[1]

def decision_risk_width_self_test() -> tuple[list[str], int]:
    """Current423 only: real immutable admission plus scoped fault controls."""
    import main_game_locale_history as history
    import ja_translation_pipeline as ja
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("decision risk width: " + label)
    def reject(action, label, message=None):
        try:
            action()
        except (ValueError, OSError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
            check(message is None or message in str(exc), label)
        else:
            check(False, label)
    sha = lambda value: hashlib.sha256(value).hexdigest()
    path = history.MAIN_GAME_PATH
    before_commit = "8e6608fb90791acc86561bc24fb2790b17fd38ed"
    after_commit = "2321723be023bcc342f6afd2424bb0da1e8094b3"
    check((history.DECISION_RISK_BEFORE_COMMIT, history.DECISION_RISK_AFTER_COMMIT) == (before_commit, after_commit),
          "independent MainGame-only checkpoint pair")
    protected = (path, "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/ui_translation_append_self_test.py", "tools/decision_risk_width_self_test.py", "tools/audit_scope.json",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py", *append.CURRENT_PATHS)
    observed = {p: sha((ROOT / p).read_bytes()) for p in protected}
    raw = (ROOT / path).read_bytes()
    prefixes = ("MODAL", "JOB_STATUS", "INVESTMENT", "TUTORIAL", "PAD_HINT", "PEOPLE_CARD",
                "PEOPLE_CARD_REPAIR", "AXIS_BADGE", "PROMOTION", "TENURE", "GIFT_PRICE", "REACTION_FONT", "DECISION_RISK")
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
        predecessors = history._decision_risk_width_proof(raw, ROOT)
    prior, old = predecessors[0], predecessors[-1]
    check(tuple(sha(value) for value in (raw, *predecessors)) == (
        "3682f25888c78ab0bcc5a10c61d4d0701f8fd49b95dc9dc780be1e18a050f2cf",
        "3f5d667883960d5defe8c3c3af326d077f8957d8703e0e1928ec327b97c2770b",
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
        "current and eleven independent predecessor raw pins")
    expected_requests = []
    for before, after, trees, _blobs, _hashes in stages:
        expected_requests.extend((before, after, *trees, before + ":" + path, after + ":" + path))
    check([data for args, data in trace if args == ("cat-file", "--batch")]
          == [("\n".join(expected_requests) + "\n").encode()], "all seventy-eight immutable objects requested once")
    check([args for args, _ in trace if args[:1] == ("diff",)] == [
          ("diff", "--name-status", "-z", before, after) for before, after, *_ in stages], "thirteen exact MainGame path populations")
    ancestry = [("merge-base", "--is-ancestor", stages[i - 1][1], stages[i][0]) for i in range(1, 13)]
    ancestry.append(("merge-base", "--is-ancestor", after_commit, "HEAD"))
    check([args for args, _ in trace if args[:1] == ("merge-base",)] == ancestry, "twelve stage links and current HEAD ancestry")
    check([args for args, _ in trace if args[:1] == ("rev-parse",)] == [("rev-parse", "HEAD:" + path)], "actual HEAD blob checked")
    for index, name in enumerate(("decision_risk_width", "reaction_body_font", "gift_price_badge", "career_tenure", "promotion_review", "axis_badge_fit", "people_card_height",
                                  "pad_hint_font", "tutorial_copy", "investment_footer", "modal_font")):
        check(getattr(history, name + "_predecessor")(raw, ROOT) == predecessors[index], "public predecessor " + name)
    reject(lambda: history._reaction_body_font_proof(raw, ROOT), "unchanged417 proof rejects new current raw")
    for code, marker, digest in (
            ("tools/main_game_locale_history.py", b"# BEGIN_DECISION_RISK_WIDTH_HISTORY_423", "d698077625f03648cc17a65bebf092bcd0a40cfce6cfd970ec98329e6343ca72"),
            ("tools/ui_translation_append.py", b"# BEGIN_DECISION_RISK_WIDTH_MANIFEST_423", "31b00d5632cf36e94065f7bd246eab3f0a16115dfcf31816bed85b8daf1df966")):
        previous = append._git(ROOT, "show", before_commit + ":" + code)
        check(sha(previous) == digest, "independent old module hash " + code)
        current = (ROOT / code).read_bytes()
        check(current.splitlines().count(marker) == 1 and current.startswith(previous)
              and not current[len(previous):current.index(marker)].strip(), "all old bodies/pins preserved " + code)
    check(sha((ROOT / "tools/ui_translation_append_self_test.py").read_bytes()) ==
          "f4d54b0ec63efaa17487af6ae1b3be0dd602646aee4c4ba66fa6f4b5aac68cc2", "old complete self-test unchanged")
    for code, digest in (("tools/reaction_body_font_self_test.py", "0d12f60e054b66597a8d39f07eecc0731a8db83174a8eb7912ba6385af55564f"),
                         ("tools/ja_translation_pipeline.py", "55a3b65670765fdf8aedb75e78fbbd94b0306e97f873c5e4a8580b9e171e9e27"),
                         ("tools/ja_translation_audit.py", "9212613d345be575ce262fd8f5aefac180d3280b9629c513ad33e0702ac591b4")):
        check((ROOT / code).read_bytes() == append._git(ROOT, "show", before_commit + ":" + code)
              and sha((ROOT / code).read_bytes()) == digest, "unchanged whole collector/audit " + code)
    check(history._decision_risk_width_inverse(raw, prior) == prior, "pure exact inverse recovers actual pre423")
    old_anchor, new_anchor = (part.encode() for part in history.DECISION_RISK_REPLACEMENT)
    addition = b'\tvar risk_width := risk_label.get_theme_font("font").get_string_size(risk_text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, risk_label.get_theme_font_size("font_size")).x\n\trisk_label.custom_minimum_size.x = ceilf(risk_width) + 2.0\n'
    check(raw.count(addition) == 1 and raw.replace(addition, b"", 1) == prior, "independent exact two-line inverse")
    for label, mutant in (("partial", raw.replace(new_anchor, new_anchor[:-2], 1)), ("rollback", prior),
                          ("duplicate", raw + new_anchor), ("moved", raw.replace(new_anchor, old_anchor, 1) + new_anchor),
                          ("whitespace", raw + b"\n"), ("invalid type", None)):
        reject(lambda value=mutant: history._decision_risk_width_inverse(value, prior), "pure boundary " + label)
    body = ja._gd_function_source(raw.decode(), "_make_demo_decision_card").encode()
    for label, before, after in (
            ("wrong target", b'risk_label.custom_minimum_size.x', b'ap_label.custom_minimum_size.x'),
            ("no uppercase", b'risk_text.to_upper()', b'risk_text'),
            ("fixed font size", b'risk_label.get_theme_font_size("font_size")', b'9'),
            ("wrong font role", b'risk_label.get_theme_font("font")', b'_font_bold'),
            ("fixed width", b'ceilf(risk_width) + 2.0', b'48.0'),
            ("no safety margin", b'ceilf(risk_width) + 2.0', b'ceilf(risk_width)'),
            ("clip changed", b'risk_label.clip_text = true', b'risk_label.clip_text = false')):
        check(body.count(before) == 1 and raw.count(body) == 1, "exact mutation location " + label)
        reject(lambda a=before, b=after: history._decision_risk_width_inverse(raw.replace(body, body.replace(a, b, 1), 1), prior), "unowned " + label)
    # Scoped Git-output doubles below test control flow; above is actual object admission.
    batch = batches[0]
    offsets, cursor = [], 0
    for _ in range(78):
        end = batch.index(b"\n", cursor)
        size = int(batch[cursor:end].split()[2])
        offsets.append(end + 1)
        cursor = end + 2 + size
    check(cursor == len(batch), "seventy-eight actual objects decoded exactly")
    for stage, prefix in enumerate(prefixes):
        offset = offsets[stage * 6 + 1]
        mutant = batch[:offset] + bytes([batch[offset] ^ 1]) + batch[offset + 1:]
        with mock.patch.object(history, "_modal_git", side_effect=lambda where, *args, altered=mutant, **kw:
                               altered if args == ("cat-file", "--batch") else real_git(where, *args, **kw)):
            reject(lambda: history._decision_risk_width_proof(raw, ROOT), "immutable stage " + prefix, "forged immutable object")
    for label, target, replacement in (
            ("missing object", ("cat-file", "--batch"), lambda value: b"missing\n"),
            ("trailing proof", ("cat-file", "--batch"), lambda value: value + b"extra"),
            ("path population", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
            ("HEAD rollback", ("rev-parse",), lambda value: history.DECISION_RISK_BLOBS[0].encode() + b"\n")):
        def altered(where, *args, **kwargs):
            value = real_git(where, *args, **kwargs)
            return replacement(value) if args[:len(target)] == target else value
        with mock.patch.object(history, "_modal_git", side_effect=altered):
            reject(lambda: history.decision_risk_width_predecessor(raw, ROOT), label)
    for target in ancestry:
        def unavailable(where, *args, **kwargs):
            if args == target:
                raise ValueError("synthetic unavailable ancestor")
            return real_git(where, *args, **kwargs)
        with mock.patch.object(history, "_modal_git", side_effect=unavailable):
            reject(lambda: history.decision_risk_width_predecessor(raw, ROOT), "ancestor " + target[-1], "unavailable ancestor")
    with mock.patch.object(history, "DECISION_RISK_TREES", tuple(reversed(history.DECISION_RISK_TREES))):
        reject(lambda: history.decision_risk_width_predecessor(raw, ROOT), "valid objects wrong tree", "immutable tree differs")
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
    with mock.patch.object(history, "DECISION_RISK_AFTER_COMMIT", forged_oid), mock.patch.object(history, "_modal_git", side_effect=resigned_parent):
        reject(lambda: history.decision_risk_width_predecessor(raw, ROOT), "re-signed wrong parent", "direct parent differs")
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
    check(sum(len(rows) for rows in ledger["accepted"].values()) == 41442 and len(ledger["batches"]) == 195
          and ledger["accepted_sha256"] == append.exchange.digest(ledger["accepted"]), "accepted41442/batches195 and checksum preserved")
    hashes = {path: sha(raw), append.ARUBA_FONT_PATH: sha((ROOT / append.ARUBA_FONT_PATH).read_bytes()), "unchanged.json": "1" * 64}
    source = {"source_hashes": hashes, "source_manifest_sha256": append.exchange.digest(hashes)}
    preserved = copy.deepcopy(source)
    views = [hashes, *({**hashes, path: sha(value)} for value in predecessors),
             {**hashes, path: sha(old), append.ARUBA_FONT_PATH: append.ARUBA_FONT_BEFORE_SHA256}]
    check(len(views) == len({append.exchange.digest(view) for view in views}) == 13, "exact thirteen manifest views")
    real_proof = history._decision_risk_width_proof
    for index, view in enumerate(views):
        with mock.patch.object(history, "_decision_risk_width_proof", wraps=real_proof) as proof:
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
        return history.DECISION_RISK_BLOBS[0].encode() + b"\n" if args == ("rev-parse", "HEAD:" + path) else real_git(where, *args, **kwargs)
    def raw_fault(file):
        value = real_read(file)
        return value + b"\n" if file == ROOT / path else value
    for label, fault in (("Git", mock.patch.object(history, "_modal_git", side_effect=OSError("lost after success"))),
                         ("HEAD", mock.patch.object(history, "_modal_git", side_effect=head_fault)),
                         ("raw", mock.patch.object(Path, "read_bytes", raw_fault))):
        with mock.patch.object(history, "_decision_risk_width_proof", wraps=real_proof) as proof:
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " first success")
            with fault:
                reject(lambda: append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)), label + " next fresh failure")
            check(append._source_manifest_matches(ROOT, source, append.exchange.digest(hashes)) and proof.call_count == 3, label + " recovery without cross-call cache")
    check(all(sha((ROOT / p).read_bytes()) == value for p, value in observed.items()), "all observed source/dictionary/receipt bytes unchanged")
    return failures, cases

if __name__ == "__main__":
    errors, cases = decision_risk_width_self_test()
    for error in errors:
        print("DECISION_RISK_WIDTH_ERROR " + error)
    print(f"DECISION_RISK_WIDTH_{'FAIL' if errors else 'OK'} cases={cases} historical_cases=0")
    raise SystemExit(int(bool(errors)))

