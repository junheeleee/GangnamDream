#!/usr/bin/env python3
"""Bounded log-font bridge checks; no collector, old suite, engine or writes.

One real fourteen-stage Main proof supplies the raw predecessors. Later Git
faults replay those captured responses. Manifest tests use real source hashes
in a small synthetic census, not a claim of whole-repository collection.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import sys
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import main_game_locale_history as history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
MAIN = history.MAIN_GAME_PATH
SCALP = bridge.SCALPING_PHASE_PATH
CASES: list[str] = []
BEFORE = "807fb8296f6c03ae7c0f8c6ceed105c3a23128ae"
AFTER = "732394c73e67feef5752fe867ad32c67c2ee73e5"
MAIN_HASHES = (
    "d06af65bdc278220bbcd862a343584422dbd73f09f2630b64199442ded9a7054",
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
    "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def rejects(name, operation, message=None):
    try:
        operation()
    except (ValueError, OSError) as error:
        if message is not None and message not in str(error):
            raise AssertionError(f"{name}: unexpected rejection {error}") from error
    else:
        raise AssertionError(name + ": unexpectedly admitted")
    CASES.append(name)


def inventory(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def main():
    protected = (MAIN, SCALP, bridge.ARUBA_FONT_PATH, *bridge.CURRENT_PATHS,
                 "tools/main_game_locale_history.py", "tools/ui_translation_append.py",
                 "tools/log_body_font_receipt_check.py", "tools/audit_scope.json",
                 "tools/scalping_phase_focus_receipt_check.py", "tools/reaction_body_font_self_test.py",
                 "tools/decision_risk_width_self_test.py", "tools/ui_translation_append_self_test.py",
                 "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py")
    observed = {path: sha((ROOT / path).read_bytes()) for path in protected}
    raw = (ROOT / MAIN).read_bytes()
    check("independent product commit pins", (history.LOG_BODY_FONT_BEFORE_COMMIT,
          history.LOG_BODY_FONT_AFTER_COMMIT) == (BEFORE, AFTER))
    check("independent product tree pins", history.LOG_BODY_FONT_TREES == (
        "17f28437b651790e7b3e3689008ea749dcf60556", "127046505d810e59233076e0f26a1f2751da449a"))
    check("independent product blob pins", history.LOG_BODY_FONT_BLOBS == (
        "4feb1e52e951e946dd5ef898979468ee7e233d61", "41cac5e35d12b2ec4f37e8e7aa55bd0413276022"))
    check("independent product raw pins", history.LOG_BODY_FONT_HASHES == (MAIN_HASHES[1], MAIN_HASHES[0]))
    prefixes = ("MODAL", "JOB_STATUS", "INVESTMENT", "TUTORIAL", "PAD_HINT", "PEOPLE_CARD",
                "PEOPLE_CARD_REPAIR", "AXIS_BADGE", "PROMOTION", "TENURE", "GIFT_PRICE",
                "REACTION_FONT", "DECISION_RISK", "LOG_BODY_FONT")
    stages = [tuple(getattr(history, prefix + suffix) for suffix in
                    ("_BEFORE_COMMIT", "_AFTER_COMMIT", "_TREES", "_BLOBS", "_HASHES")) for prefix in prefixes]
    real_git = history._modal_git
    trace, responses = [], {}

    def traced(where, *args, **kwargs):
        value = real_git(where, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key)
        responses[key] = value
        return value

    with patch.object(history, "_modal_git", side_effect=traced):
        predecessors = history._log_body_font_proof(raw, ROOT)
    check("real current and twelve predecessor raw pins", isinstance(predecessors, tuple)
          and tuple(sha(value) for value in (raw, *predecessors)) == MAIN_HASHES)
    prior = predecessors[0]
    requests = []
    for before, after, trees, _blobs, _hashes in stages:
        requests.extend((before, after, *trees, before + ":" + MAIN, after + ":" + MAIN))
    batch_input = ("\n".join(requests) + "\n").encode()
    check("real eighty-four objects requested in one batch", [data for args, data in trace
          if args == ("cat-file", "--batch")] == [batch_input])
    check("real fourteen exact product path populations", [args for args, _ in trace if args[:1] == ("diff",)]
          == [("diff", "--name-status", "-z", before, after) for before, after, *_ in stages])
    ancestry = [("merge-base", "--is-ancestor", stages[i - 1][1], stages[i][0]) for i in range(1, 14)]
    ancestry.append(("merge-base", "--is-ancestor", AFTER, "HEAD"))
    check("real thirteen history links and HEAD ancestry", [args for args, _ in trace
          if args[:1] == ("merge-base",)] == ancestry)
    check("real HEAD Main blob check", [args for args, _ in trace if args[:1] == ("rev-parse",)]
          == [("rev-parse", "HEAD:" + MAIN)])

    for path, marker, digest in (
        ("tools/main_game_locale_history.py", b"# BEGIN_LOG_BODY_FONT_HISTORY_432",
         "97bacaf4bcf23763bb82a3f9794411fdcafa774d36f69ec17c1cfee3d153e5fa"),
        ("tools/ui_translation_append.py", b"# BEGIN_LOG_BODY_FONT_MANIFEST_432",
         "e33fb5081042899ed7ace55218b579c039e325e601449746201ef2cdb743c390"),
    ):
        original = bridge._git(ROOT, "show", BEFORE + ":" + path)
        current = (ROOT / path).read_bytes()
        check("independent original module pin " + path, sha(original) == digest)
        check("whole old module and pins preserved " + path, current.startswith(original)
              and current.splitlines().count(marker) == 1
              and not current[len(original):current.index(marker)].strip())
    addition = b'\tlog_box.add_theme_font_override("normal_font", _font_regular)\n'
    check("independent one-line log-only delta", raw.count(addition) == 1
          and raw.replace(addition, b"", 1) == prior)
    check("pure inverse", history._log_body_font_inverse(raw, prior) == prior)
    old, new = (value.encode() for value in history.LOG_BODY_FONT_REPLACEMENT)
    for label, mutant in (
        ("extra edit", raw + b"\n"), ("duplicate", raw + new), ("deleted", raw.replace(addition, b"", 1)),
        ("moved", raw.replace(new, old, 1) + new), ("mutable raw", bytearray(raw)),
        ("wrong font role", raw.replace(addition, addition.replace(b"_font_regular", b"_font_bold"), 1)),
    ):
        rejects("pure inverse rejects " + label, lambda value=mutant: history._log_body_font_inverse(value, prior))

    # Replayed responses below are synthetic control-flow evidence, not new Git observations.
    def replay(where, *args, **kwargs):
        if where != ROOT or set(kwargs) - {"input"}:
            raise AssertionError("unexpected replay request")
        return responses[(args, kwargs.get("input"))]

    for label, target, replacement in (
        ("missing immutable object", ("cat-file", "--batch"), lambda value: b"missing\n"),
        ("trailing immutable bytes", ("cat-file", "--batch"), lambda value: value + b"extra"),
        ("extra product path", ("diff", "--name-status"), lambda value: value + b"M\0neighbor.gd\0"),
        ("HEAD rollback", ("rev-parse",), lambda value: history.LOG_BODY_FONT_BLOBS[0].encode() + b"\n"),
    ):
        def fault(where, *args, prefix=target, mutate=replacement, **kwargs):
            value = replay(where, *args, **kwargs)
            return mutate(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_modal_git", side_effect=fault):
            rejects("replayed Git " + label, lambda: history._log_body_font_proof(raw, ROOT))
    with patch.object(history, "_modal_git", side_effect=OSError("synthetic next-call Git unavailable")):
        rejects("fresh call after real success cannot reuse Git", lambda: history._log_body_font_proof(raw, ROOT), "next-call Git")
    with patch.object(history, "_modal_git", side_effect=replay):
        check("replayed recovery after Git failure", history._log_body_font_proof(raw, ROOT) == predecessors)
    with patch.object(history, "_log_body_font_proof", return_value=predecessors):
        names = ("log_body_font", "decision_risk_width", "reaction_body_font", "gift_price_badge",
                 "career_tenure", "promotion_review", "axis_badge_fit", "people_card_height",
                 "pad_hint_font", "tutorial_copy", "investment_footer", "modal_font")
        for index, name in enumerate(names):
            check("public predecessor index " + name,
                  getattr(history, name + "_predecessor")(raw, ROOT) == predecessors[index])

    scalp_raw = (ROOT / SCALP).read_bytes()
    scalp_before = bridge.scalping_phase_predecessor(ROOT, scalp_raw)
    font_raw = (ROOT / bridge.ARUBA_FONT_PATH).read_bytes()
    font_before = bridge.aruba_font_predecessor(ROOT, font_raw)
    hashes = {MAIN: sha(raw), SCALP: sha(scalp_raw), bridge.ARUBA_FONT_PATH: sha(font_raw), "unowned.gd": "fixed"}
    source = inventory(hashes)
    preserved = copy.deepcopy(source)
    views = [hashes, {**hashes, MAIN: sha(prior)}]
    views += [{**hashes, MAIN: sha(value), SCALP: sha(scalp_before)} for value in predecessors]
    views += [{**views[-1], bridge.ARUBA_FONT_PATH: sha(font_before)}]
    allowed = {bridge.exchange.digest(view) for view in views}
    check("exact fifteen actual-source hash combinations", len(views) == len(allowed) == 15)

    def main_proof(where_raw, where=None):
        if where != ROOT or where_raw != raw:
            raise ValueError("synthetic Main raw proof mismatch")
        return predecessors

    def scalp_proof(where, where_raw):
        if where != ROOT or where_raw != scalp_raw:
            raise ValueError("synthetic Scalp raw proof mismatch")
        return scalp_before

    def font_proof(where, where_raw):
        if where != ROOT or where_raw != font_raw:
            raise ValueError("synthetic Aruba raw proof mismatch")
        return font_before

    with patch.object(history, "_log_body_font_proof", side_effect=main_proof) as fresh, \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=scalp_proof), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=font_proof):
        for index, view in enumerate(views):
            check("allowed hash combination " + str(index), bridge._source_manifest_matches(ROOT, source, bridge.exchange.digest(view)))
        phantoms = set()
        for main_hash, scalp_hash, font_hash in itertools.product(MAIN_HASHES,
                (sha(scalp_raw), sha(scalp_before)), (sha(font_raw), sha(font_before))):
            digest = bridge.exchange.digest({**hashes, MAIN: main_hash, SCALP: scalp_hash, bridge.ARUBA_FONT_PATH: font_hash})
            if digest not in allowed:
                phantoms.add(digest)
        check("all thirty-seven Cartesian phantom combinations", len(phantoms) == 37)
        for index, digest in enumerate(sorted(phantoms)):
            check("rejected phantom combination " + str(index), not bridge._source_manifest_matches(ROOT, source, digest))
        check("each manifest re-enters Main proof", fresh.call_count == 52)
        for scalp_hash, font_hash in itertools.product((sha(scalp_raw), sha(scalp_before)), (sha(font_raw), sha(font_before))):
            failed = {**hashes, MAIN: history.PEOPLE_CARD_HASHES[1], SCALP: scalp_hash, bridge.ARUBA_FONT_PATH: font_hash}
            check("failed402 remains excluded " + scalp_hash + font_hash,
                  not bridge._source_manifest_matches(ROOT, source, bridge.exchange.digest(failed)))
        check("unknown expected manifest rejected", not bridge._source_manifest_matches(ROOT, source, "0" * 64))
        changed = inventory({**hashes, "unowned.gd": "changed"})
        check("unowned source not exempted", not bridge._source_manifest_matches(ROOT, changed, source["source_manifest_sha256"]))
        rejects("forged current checksum", lambda: bridge._source_manifest_matches(ROOT,
                {**source, "source_manifest_sha256": "0" * 64}, source["source_manifest_sha256"]))
        for path, previous in ((MAIN, sha(prior)), (SCALP, sha(scalp_before)), (bridge.ARUBA_FONT_PATH, sha(font_before))):
            forged = inventory({**hashes, path: previous})
            rejects("historical census masquerading as current " + path,
                    lambda value=forged: bridge._source_manifest_matches(ROOT, value, value["source_manifest_sha256"]))
    check("manifest source census never rewritten", source == preserved)

    # Exercise the unchanged Main/Scalp current_proof wrappers, replacing only the
    # expensive collector/history core and source proofs with labelled doubles.
    head = "f" * 40
    result = {**source, "evidence": {"head": head}, "kept": "synthetic core result"}

    def admission(value=None, main_reads=None, heads=None):
        reads = iter(main_reads if main_reads is not None else (raw, raw))

        def read_bytes(path):
            if path == ROOT / MAIN:
                return next(reads)
            if path == ROOT / SCALP:
                return scalp_raw
            raise AssertionError("unexpected admission read " + str(path))

        with patch.object(Path, "read_bytes", read_bytes), \
                patch.object(bridge, "_git", side_effect=heads if heads is not None else (head.encode(), head.encode())), \
                patch.object(history, "_log_body_font_proof", side_effect=main_proof), \
                patch.object(bridge, "scalping_phase_predecessor", side_effect=scalp_proof), \
                patch.object(bridge, "_MODAL_OLD_CURRENT_PROOF", return_value=result if value is None else value):
            return bridge.current_proof(ROOT, "synthetic-baseline", {})

    check("current wrappers return unchanged actual-shaped census", admission() is result)
    for path, previous in ((MAIN, sha(prior)), (SCALP, sha(scalp_before))):
        bad = copy.deepcopy(result)
        bad["source_hashes"][path] = previous
        bad["source_manifest_sha256"] = bridge.exchange.digest(bad["source_hashes"])
        rejects("returned historical census " + path, lambda value=bad: admission(value), "source changed during")
    rejects("returned invalid census digest", lambda: admission({**result, "source_manifest_sha256": "bad"}), "source changed during")
    rejects("Main changes during current admission", lambda: admission(main_reads=(raw, raw + b"\n")), "source changed during")
    rejects("outer HEAD changes", lambda: admission(heads=(head.encode(), b"0" * 40)), "Git candidate changed")
    rejects("inner HEAD differs", lambda: admission({**result, "evidence": {"head": "0" * 40}}), "Git candidate changed")
    with patch.object(history, "_log_body_font_proof", side_effect=(predecessors, ValueError("synthetic next-call failure"), predecessors)) as fresh, \
            patch.object(bridge, "scalping_phase_predecessor", side_effect=scalp_proof), \
            patch.object(bridge, "aruba_font_predecessor", side_effect=font_proof):
        check("manifest success before fresh fault", bridge._source_manifest_matches(ROOT, source, source["source_manifest_sha256"]))
        rejects("next manifest cannot reuse success", lambda: bridge._source_manifest_matches(ROOT, source, source["source_manifest_sha256"]), "next-call failure")
        check("manifest recovery after fresh fault", bridge._source_manifest_matches(ROOT, source, source["source_manifest_sha256"]))
        check("three independent manifest proof entries", fresh.call_count == 3)
    check("observed product dictionaries receipts and tools unchanged",
          all(sha((ROOT / path).read_bytes()) == digest for path, digest in observed.items()))
    check("no duplicate case names", len(CASES) == len(set(CASES)))
    print(f"LOG_BODY_FONT_RECEIPT_CHECK_OK cases={len(CASES)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
