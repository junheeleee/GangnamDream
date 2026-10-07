#!/usr/bin/env python3
"""Two first-win result facts, not full-scene or release approval."""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

from pr31_intake_history import _Document
import order470_source_compat as successor

ROOT = Path(__file__).resolve().parents[1]
BASE = "5ec492da9a1007f6cc6b10c7ac1d22135e47b356"
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
IDS = ("arc_first_real_win", "arc_first_real_win_father_passed")
COST = {"ko": ("5천원짜리", "15,000원짜리"),
        "en": ("5,000-won", "15,000-won"), "ja": ("5000ウォン", "15000ウォン"),
        "zh-CN": ("5000韩元", "15000韩元"), "zh-TW": ("5千韓元", "1萬5千韓元")}
TOKEN = re.compile(r"\{[^{}]+\}|%(?:\d+\$)?[-+0 #]*\d*(?:\.\d+)?[sdif]|\[/?[A-Za-z][^\]]*\]")


def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"


def selected(document):
    result = {}
    for index, row in enumerate(document.value):
        if row["id"] in IDS:
            result[row["id"]] = (row["choices"][0]["result_text"],
                                  (index, "choices", 0, "result_text"))
    if tuple(result) != IDS:
        raise ValueError("exact ordered two first-win results required")
    return result


def masked(document, leaves):
    text = document.text
    for start, end in sorted((document.spans[key] for _, key in leaves.values()), reverse=True):
        text = text[:start] + '"__FIRST_WIN_RESULT__"' + text[end:]
    return text


def errors(before, after):
    failures = []
    for locale in LOCALES:
        old, new = _Document(before[locale]), _Document(after[locale])
        old_leaves, new_leaves = selected(old), selected(new)
        if masked(old, old_leaves) != masked(new, new_leaves):
            failures.append(locale + ": outside owned two results raw/gameplay changed")
        source = old_leaves[IDS[0]][0]
        old_cost, new_cost = COST[locale]
        if source.count(old_cost) != 1:
            failures.append(locale + ": original one cost absent/repeated")
        expected = source.replace(old_cost, new_cost, 1)
        for event_id in IDS:
            text = new_leaves[event_id][0]
            previous = old_leaves[event_id][0]
            if text != expected:
                failures.append(locale + ":" + event_id + ": exact cost/home repair drift")
            if TOKEN.findall(previous) != TOKEN.findall(text) or previous.count("\n") != text.count("\n"):
                failures.append(locale + ":" + event_id + ": token/line drift")
    ko = _Document(after["ko"])
    for row in ko.value:
        if row["id"] in IDS:
            choice = row["choices"][0]
            if choice["effects"] != {"mental": 12, "money": -15000} \
                    or choice["flags"] != ["arc_first_real_win_seen"] \
                    or row["background"] != "current_housing":
                failures.append(row["id"] + ": original actual spending/state/background drift")
    return failures


def mutate_leaf(raw, event_id, change):
    doc = _Document(raw)
    value, key = selected(doc)[event_id]
    start, end = doc.spans[key]
    return (doc.text[:start] + json.dumps(change(value), ensure_ascii=False) + doc.text[end:]).encode()


def self_test(before, after):
    cases = 0
    for label, locale, event_id, change in (
        ("old cost", "ko", IDS[0], lambda s: s.replace("15,000원짜리", "5천원짜리")),
        ("old stairs", "en", IDS[1], lambda s: s.replace("Back home,", "On the goshiwon stairs,")),
        ("token", "ja", IDS[0], lambda s: s.replace("{name}", "Minjun")),
        ("line", "zh-CN", IDS[0], lambda s: s + "\n"),
        ("unrelated prose", "zh-TW", IDS[0], lambda s: s + "。"),
    ):
        changed = copy.deepcopy(after)
        changed[locale] = mutate_leaf(changed[locale], event_id, change)
        assert errors(before, changed), label + " accepted"
        cases += 1
    changed = dict(after)
    changed["ko"] += b"\n"
    assert errors(before, changed), "outside raw whitespace accepted"
    cases += 1
    assert errors(before, before), "unfixed original prose accepted"
    cases += 1
    print("FIRST_WIN_FACT_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    before = {locale: subprocess.check_output(
        ["git", "--no-replace-objects", "show", BASE + ":" + path(locale)], cwd=ROOT)
        for locale in LOCALES}
    current = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    # Shared-file successor is validated against physical current bytes and a
    # finite typed Git edge BEFORE its immutable pre-night comparison is used.
    # This is solely a historical fact-check view, never a runtime payload.
    with successor.fresh_validation_proof():
        after = successor.historical_first_win_comparison(current, ROOT)
        if args.self_test:
            negatives = []
            changed = dict(current)
            changed["ko"] += b"\n"
            negatives.append(changed)
            changed = dict(current)
            changed["en"] = mutate_leaf(changed["en"], IDS[0], lambda s: s.replace("15,000-won", "5,000-won"))
            negatives.append(changed)
            changed = dict(current)
            changed["ko"] = after["ko"]
            negatives.append(changed)
            negatives.append({locale: current[locale] for locale in LOCALES[:-1]})
            negatives.append(after)
            for changed in negatives:
                try:
                    successor.historical_first_win_comparison(changed, ROOT)
                except ValueError:
                    pass
                else:
                    raise AssertionError("unbound current/historical/mixed raw accepted")
            print("FIRST_WIN_COMPARISON_SELF_TEST_OK cases=" + str(len(negatives)))
    failures = errors(before, after)
    for failure in failures:
        print("FIRST_WIN_FACT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(before, after)
    population = [(locale, path(locale), event_id, ["choices", 0, "result_text"])
                  for locale in LOCALES for event_id in IDS]
    digest = hashlib.sha256(json.dumps(population, ensure_ascii=False, separators=(",", ":")).encode()).hexdigest()
    print("FIRST_WIN_FACT_OK locales=5 leaves=10 outside_owned_raw=unchanged population_sha256=" + digest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
