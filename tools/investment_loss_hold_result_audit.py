#!/usr/bin/env python3
"""Exact five holding-result facts; not trading, native, or release approval."""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

from pr31_intake_history import _Document

ROOT = Path(__file__).resolve().parents[1]
BASE = "70ceeebdb67c4e3ab66dc2bd08cb21cf2598a343"
SOURCE = "04ed119c6f0e31306ed89d62f2951ef6cc5490e5"
FIXTURE = "tools/InvestmentLossHoldResultCheck.gd"
SCENE = "tools/InvestmentLossHoldResultCheck.tscn"
FIXTURE_SHA = "adbd0679f392c3321ae78344ab16089424b319014ed91c44f52a865e23d7a214"
SCENE_SHA = "ed09099ab0c93903bc458caff79f3497a3f46cf8a24c4983ce0f35fde6127b61"
EVENT = "arc_invest_first_loss"
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
TEXT_SHA = {
    "ko": "8acb738e5c6b65a8d9fe525c1f931b8cdfc08e83119b12b88d314c91aec877e5",
    "en": "25e0c73c16bf84ebb11456499bdd1a0d710f09a2d752f016f9b4c94c553d381d",
    "ja": "fa753cfe0f8c1c3618e9504fed60bf1ac981cf906b8200de2edf157d9322c540",
    "zh-CN": "fce7d2223ec1305043354261d492cfa5c6ce8252e6d555290c78463dad9ca7ab",
    "zh-TW": "8ab2d0be38093cce262affeccb13909ade2c1fda421062e4298bb6c584a2d44c",
}

def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"

def selected(document):
    rows = [i for i, row in enumerate(document.value) if row["id"] == EVENT]
    if len(rows) != 1:
        raise ValueError("exact one holding-result event required")
    key = (rows[0], "choices", 1, "result_text")
    return document.value[rows[0]]["choices"][1]["result_text"], key

def replace(raw, text):
    doc = _Document(raw)
    _, key = selected(doc)
    start, end = doc.spans[key]
    return (doc.text[:start] + json.dumps(text, ensure_ascii=False) + doc.text[end:]).encode()

def errors(before, after):
    failures = []
    if set(before) != set(LOCALES) or set(after) != set(LOCALES):
        return ["exact five locale population required"]
    for locale in LOCALES:
        old, new = _Document(before[locale]), _Document(after[locale])
        previous, old_key = selected(old)
        current, new_key = selected(new)
        a, z = old.spans[old_key]
        b, y = new.spans[new_key]
        if old.text[:a] + '"__HOLD_RESULT__"' + old.text[z:] \
                != new.text[:b] + '"__HOLD_RESULT__"' + new.text[y:]:
            failures.append(locale + ": outside owned result raw/gameplay changed")
        if hashlib.sha256(current.encode()).hexdigest() != TEXT_SHA[locale]:
            failures.append(locale + ": reviewed uncertain result changed")
        if current.count("{name}") != 1 or current.count("\n") != previous.count("\n") \
                or len(current.split("\n\n")) != 3 or current.split("\n\n")[-1] != previous.split("\n\n")[-1]:
            failures.append(locale + ": token/paragraph/holding ending changed")
    event = next(row for row in _Document(after["ko"]).value if row["id"] == EVENT)
    choice = event["choices"][1]
    if choice["effects"] != {"investment_skill": 3, "mental": -3} \
            or choice["flags"] != ["arc_invest_first_loss_seen", "held_through_loss"]:
        failures.append("actual unchanged hold effects/producer drift")
    return failures

def fixture_errors(script, scene):
    return [label + ": independently read consumer40 wiring changed"
            for label, raw, expected in ((FIXTURE, script, FIXTURE_SHA), (SCENE, scene, SCENE_SHA))
            if hashlib.sha256(raw).hexdigest() != expected]

def self_test(before, after, script, scene):
    count = 0
    for locale in LOCALES:
        current, _ = selected(_Document(after[locale]))
        previous, _ = selected(_Document(before[locale]))
        for label, value in [("old recovery", previous), ("token", current.replace("{name}", "Minjun")),
                             ("paragraph", current + "\n\n"), ("unreviewed addition", current + "!")]:
            changed = dict(after)
            changed[locale] = replace(changed[locale], value)
            assert errors(before, changed), locale + ":" + label + " accepted"
            count += 1
        changed = dict(after)
        changed[locale] += b"\n"
        assert errors(before, changed), locale + ": unowned bytes accepted"
        count += 1
    assert errors(before, before), "old source accepted"
    assert errors(before, {key: value for key, value in after.items() if key != "ja"}), "missing locale accepted"
    assert errors(before, {**after, "extra": after["en"]}), "extra locale accepted"
    for mutated_script, mutated_scene in ((script + b"\n", scene), (script, scene + b"\n"),
                                         (script.replace(b"GameState.apply_choice", b"GameState.skip_choice", 1), scene),
                                         (script, scene.replace(b"HoldResultCheck.gd", b"GateCheck.gd", 1))):
        assert fixture_errors(mutated_script, mutated_scene), "consumer/scene drift accepted"
        count += 1
    print("INVESTMENT_LOSS_HOLD_SELF_TEST_OK cases=" + str(count + 3))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    def git(*parts):
        return subprocess.check_output(["git", "--no-replace-objects", *parts], cwd=ROOT)
    if git("rev-parse", SOURCE + "^").decode().strip() != BASE:
        raise ValueError("typed source direct parent changed")
    changed = set(git("diff", "--name-only", BASE, SOURCE).decode().splitlines())
    if changed != {path(locale) for locale in LOCALES}:
        raise ValueError("typed source is not exact five product files")
    git("merge-base", "--is-ancestor", SOURCE, "HEAD")
    before = {locale: git("show", BASE + ":" + path(locale)) for locale in LOCALES}
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    script, scene = ((ROOT / value).read_bytes() for value in (FIXTURE, SCENE))
    failures = errors(before, after) + fixture_errors(script, scene)
    for failure in failures:
        print("INVESTMENT_LOSS_HOLD_AUDIT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(before, after, script, scene)
    print("INVESTMENT_LOSS_HOLD_AUDIT_OK locales=5 leaves=5 outside_owned_raw=unchanged")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
