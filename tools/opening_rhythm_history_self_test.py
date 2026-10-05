#!/usr/bin/env python3
"""One real six-object Opening proof; bounded replay, inverse and adapter faults.

Only the small Opening collector runs here. Full-body owns the actual current
whole-source census/receipt admission; replay is not another actual Git proof.
"""
from __future__ import annotations

from contextlib import ExitStack
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import re
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
import opening_rhythm_history as history
import ui_translation_append as append
import demo_localization_scope as demo

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = "5bf7a8ebf53cf00c44b96a9741b42edaa79c079b"
PREFIX_SHA = "58b9d7347d4cf85eacbebab3aad878cc58c59052ad9db366ee60ba2be6b42588"
CASES, REPLAYS = [], []
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def check(label, value):
    if not value:
        raise AssertionError(label)
    CASES.append(label)


def rejects(label, function):
    try:
        function()
    except (ValueError, TypeError, OSError):
        CASES.append(label)
        return
    raise AssertionError(label + ": unexpectedly accepted")


def packet_rows(packet):
    rows, offset = [], 0
    while offset < len(packet):
        end = packet.index(b"\n", offset)
        oid, kind, size = packet[offset:end].split()
        raw = packet[end + 1:end + 1 + int(size)]
        check("independent typed Git object", len(raw) == int(size)
              and hashlib.sha1(kind + b" " + size + b"\0" + raw).hexdigest().encode() == oid
              and packet[end + 1 + int(size):end + 2 + int(size)] == b"\n")
        rows.append((oid, kind, raw)); offset = end + 2 + int(size)
    return rows


def replay(trace, current, *, outputs=None, disk=None, pins=None):
    replies = [row[2] for row in trace]
    for index, value in (outputs or {}).items():
        replies[index] = value
    calls = []
    def git(_root, *args, input=None):
        index = len(calls); calls.append((args, input))
        assert args[:2] == trace[index][0][:2], "unexpected replay operation"
        value = replies[index]
        if isinstance(value, Exception):
            raise value
        return value
    reads = iter(disk or (current, current))
    original_read = Path.read_bytes
    def read(path):
        return next(reads) if path == ROOT / history.OPENING_PATH else original_read(path)
    with ExitStack() as stack:
        stack.enter_context(patch.object(history, "_git", git))
        stack.enter_context(patch.object(Path, "read_bytes", read))
        for key, value in (pins or {}).items():
            stack.enter_context(patch.object(history, key, value))
        REPLAYS.append(1)
        return history.opening_rhythm_predecessor(current, ROOT)


def collector(before, current):
    def literals(raw):
        values = {}
        for field, language, literal in re.findall(
                r'"(title|body)_(ko|en)"\s*:\s*("(?:\\.|[^"\\])*")', raw.decode()):
            values.setdefault((field, language), []).append(json.loads(literal))
        assert set(values) == {(f, lang) for f in ("title", "body") for lang in ("ko", "en")}
        assert all(len(v) == 3 for v in values.values())
        return sorted((f"{history.OPENING_PATH}::BEATS[{i}].{f}", values[f, "ko"][i],
                       values[f, "en"][i]) for f in ("title", "body") for i in range(3))
    expected = literals(before)
    rows, errors = demo.collect_opening_pairs()  # Exactly one small actual collector.
    check("six literal pairs unchanged and actual collector", not errors and len(rows) == 6
          and expected == literals(current) == [(r.source_id, r.korean, r.english) for r in rows])
    for _, ko, _ in expected:
        leaf = append.exchange.Leaf("ui", ko, "runtime:demo_dynamic", (ko,), ko, "ui_demo_dynamic")
        check("dynamic Leaf identity", leaf.id == "ui:" + ko + ":/" + ko.replace("~", "~0").replace("/", "~1"))


def adapter(before, current):
    inventory = {"source_hashes": {history.OPENING_PATH: sha(current), "other": "f" * 64}}
    inventory["source_manifest_sha256"] = append.exchange.digest(inventory["source_hashes"])
    original, calls = deepcopy(inventory), []
    def delegate(root, inv, expected):
        calls.append((root, inv, expected)); return expected != "rejected"
    with patch.object(history, "opening_rhythm_predecessor", return_value=before), \
            patch.object(append, "_OPENING_RHYTHM_OLD_MANIFEST_MATCHES", delegate):
        check("current manifest projected", append._source_manifest_matches(ROOT, inventory, inventory["source_manifest_sha256"]))
        projected = {**inventory["source_hashes"], history.OPENING_PATH: sha(before)}
        check("old delegate exact projection", calls[-1][1]["source_hashes"] == projected
              and calls[-1][2] == append.exchange.digest(projected) and inventory == original)
        check("historical accepted", append._source_manifest_matches(ROOT, inventory, "historical") and calls[-1][2] == "historical")
        check("historical rejection retained", not append._source_manifest_matches(ROOT, inventory, "rejected"))
        for field in ("source_manifest_sha256", "source_hashes"):
            bad = deepcopy(inventory)
            if field == "source_hashes":
                bad[field][history.OPENING_PATH] = sha(before)
                bad["source_manifest_sha256"] = append.exchange.digest(bad[field])
            else:
                bad[field] = "0" * 64
            rejects("mixed current census " + field, lambda: append._source_manifest_matches(ROOT, bad, "historical"))
        with patch.object(history, "opening_rhythm_predecessor", side_effect=AssertionError("legacy did I/O")):
            check("legacy passthrough", append._source_manifest_matches(ROOT, {}, "historical"))
    binding = ("1" * 40, "2" * 40, history.BLOBS[1])
    result = {**inventory, "evidence": {"head": binding[0]}}
    with patch.object(history, "opening_rhythm_predecessor", return_value=before), \
            patch.object(history, "_current_binding", return_value=binding), \
            patch.object(append, "_OPENING_RHYTHM_OLD_CURRENT_PROOF", return_value=result):
        check("current delegate identity", append.current_proof(ROOT, "baseline", {}) is result)
        for field in ("source_manifest_sha256", "source_hashes", "evidence"):
            bad = deepcopy(result); bad[field] = {"head": "0" * 40} if field == "evidence" else ({} if field == "source_hashes" else "0" * 64)
            with patch.object(append, "_OPENING_RHYTHM_OLD_CURRENT_PROOF", return_value=bad):
                rejects("current proof stale " + field, lambda: append.current_proof(ROOT, "baseline", {}))
        with patch.object(history, "_current_binding", side_effect=(binding, ("3" * 40, *binding[1:]))):
            rejects("current proof HEAD drift", lambda: append.current_proof(ROOT, "baseline", {}))


def main():
    paths = [history.OPENING_PATH, "project.godot", "content/meta/full_game_localization.json",
             *("locale/ui_" + locale + ".json" for locale in ("ja", "zh-CN", "zh-TW"))]
    protected = {p: sha((ROOT / p).read_bytes()) for p in paths}
    try:
        prefix = history._git(ROOT, "show", REFERENCE + ":tools/ui_translation_append.py")
        check("old receipt verifier byte prefix", sha(prefix) == PREFIX_SHA and (ROOT / "tools/ui_translation_append.py").read_bytes().startswith(prefix))
        current, trace, real_git = (ROOT / history.OPENING_PATH).read_bytes(), [], history._git
        def capture(root, *args, input=None):
            output = real_git(root, *args, input=input); trace.append((args, input, output)); return output
        with patch.object(history, "_git", capture):
            before = history.opening_rhythm_predecessor(current, ROOT)  # Real proof once.
        check("real proof call population", len(trace) == 9 and trace[3][0] == ("cat-file", "--batch"))
        rows = packet_rows(trace[3][2])
        check("six immutable objects and whole inverse", [r[1] for r in rows] == [b"commit"] * 2 + [b"tree"] * 2 + [b"blob"] * 2
              and rows[4][2] == before and rows[5][2] == current and history.opening_rhythm_inverse(current, before) == before)
        collector(before, current)
        for i, (old, new) in enumerate(history.REPLACEMENTS):
            rejects("missing reviewed edit " + str(i), lambda old=old, new=new: history.opening_rhythm_inverse(current.replace(new.encode(), old.encode(), 1), before))
        rejects("unowned raw drift", lambda: history.opening_rhythm_inverse(current + b"\n", before))
        packet = trace[3][2]
        for name, changed in (("type", packet.replace(b" commit ", b" blob ", 1)), ("truncated", packet[:-1]), ("trailing", packet + b"x"), ("forged oid", b"0" * 40 + packet[40:])):
            rejects("typed packet " + name, lambda changed=changed: replay(trace, current, outputs={3: changed}))
        for name, output, disk, pins in (
                ("pathset", {4: b"M\0other\0"}, None, None), ("ancestor", {5: ValueError("not ancestor")}, None, None),
                ("initial blob", {2: b"0" * 40 + b"\n"}, None, None), ("HEAD drift", {6: b"0" * 40 + b"\n"}, None, None),
                ("tree drift", {7: b"0" * 40 + b"\n"}, None, None), ("disk stale", {}, (before,), None),
                ("disk drift", {}, (current, before), None), ("pending", {}, None, {"BEFORE_COMMIT": None})):
            rejects(name, lambda output=output, disk=disk, pins=pins: replay(trace, current, outputs=output, disk=disk, pins=pins))
        for field in (b"parent", b"tree"):
            altered = list(rows)
            raw = re.sub(rb"(?m)^" + field + rb" [0-9a-f]{40}$", field + b" " + b"0" * 40, rows[1][2])
            oid = hashlib.sha1(b"commit " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
            altered[1] = (oid.encode(), b"commit", raw)
            forged = b"".join(o + b" " + k + b" " + str(len(v)).encode() + b"\n" + v + b"\n" for o, k, v in altered)
            rejects("valid hash wrong " + field.decode(), lambda: replay(trace, current, outputs={3: forged}, pins={"AFTER_COMMIT": oid}))
        check("fresh recovery replay", replay(trace, current) == before)
        adapter(before, current)
    finally:
        check("protected inputs unchanged", protected == {p: sha((ROOT / p).read_bytes()) for p in paths})
    print(f"OPENING_RHYTHM_HISTORY_SELF_TEST_OK cases={len(CASES)} actual_git_proofs=1 actual_objects=6 opening_collectors=1 synthetic_replays={len(REPLAYS)} historical_cases=0")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"OPENING_RHYTHM_HISTORY_SELF_TEST_FAIL cases={len(CASES)} {type(exc).__name__}: {exc}")
        sys.exit(1)
