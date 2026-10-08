#!/usr/bin/env python3
"""Current first-win cost/home facts; not full-scene or release approval."""
from __future__ import annotations

import argparse
import copy
import json
import re
from pathlib import Path

from ui_translation_append import _Document

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
IDS = ("arc_first_real_win", "arc_first_real_win_father_passed")
COST = {"ko": ("5천원짜리", "15,000원짜리"),
        "en": ("5,000-won", "15,000-won"), "ja": ("5000ウォン", "15000ウォン"),
        "zh-CN": ("5000韩元", "15000韩元"), "zh-TW": ("5千韓元", "1萬5千韓元")}
HOME = {"ko": "집으로 돌아와", "en": "Back home,", "ja": "家に戻って",
        "zh-CN": "回到家", "zh-TW": "回到家"}


def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"


def selected(document):
    result = {}
    if not isinstance(document.value, list):
        raise ValueError("first-win event array required")
    ids = [row["id"] for row in document.value]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate first-win event ID")
    for index, row in enumerate(document.value):
        if row["id"] in IDS:
            text = row["choices"][0]["result_text"]
            if not isinstance(text, str):
                raise ValueError("first-win result must be text")
            result[row["id"]] = (text, (index, "choices", 0, "result_text"))
    if set(result) != set(IDS):
        raise ValueError("two current first-win results required")
    return result


def errors(after):
    if set(after) != set(LOCALES):
        return ["exact five locale population required"]
    failures = []
    for locale in LOCALES:
        document = _Document(after[locale])
        leaves = selected(document)
        old_cost, current_cost = COST[locale]
        for event_id, (text, _) in leaves.items():
            label = locale + ":" + event_id
            if text.count(current_cost) != 1 or re.search(
                r"(?<![0-9,萬万])" + re.escape(old_cost), text
            ):
                failures.append(label + ": 15,000-won purchase fact differs")
            if HOME[locale] not in text:
                failures.append(label + ": current home return absent")
            if text.count("{name}") != 1 or len(text.split("\n\n")) != 3:
                failures.append(label + ": name/three-beat result structure differs")
    for row in _Document(after["ko"]).value:
        if row["id"] in IDS:
            choice = row["choices"][0]
            effects = choice.get("effects", {})
            if effects != {"mental": 12, "money": -15000} \
                    or any(type(value) not in (int, float) for value in effects.values()) \
                    or choice.get("flags") != ["arc_first_real_win_seen"] \
                    or row.get("background") != "current_housing":
                failures.append(row["id"] + ": actual spending/state/background differs")
    return failures


def mutate_leaf(raw, event_id, change):
    document = _Document(raw)
    value, key = selected(document)[event_id]
    start, end = document.spans[key]
    return (document.text[:start] + json.dumps(change(value), ensure_ascii=False)
            + document.text[end:]).encode()


def self_test(after):
    cases = 0
    for locale in LOCALES:
        for label, change in (
            ("old cost", lambda text: text.replace(COST[locale][1], COST[locale][0])),
            ("wrong place", lambda text: text.replace(HOME[locale], "elsewhere")),
            ("name", lambda text: text.replace("{name}", "Minjun")),
        ):
            changed = dict(after)
            changed[locale] = mutate_leaf(changed[locale], IDS[0], change)
            assert errors(changed), locale + ":" + label + " accepted"
            cases += 1
    for field, value in (("effects", {"mental": 12, "money": -5000}),
                         ("flags", ["wrong_first_win"])):
        changed = dict(after)
        rows = copy.deepcopy(_Document(changed["ko"]).value)
        next(row for row in rows if row["id"] == IDS[0])["choices"][0][field] = value
        changed["ko"] = json.dumps(rows, ensure_ascii=False).encode()
        assert errors(changed), field + " accepted"
        cases += 1
    assert errors({locale: raw for locale, raw in after.items() if locale != "ja"})
    cases += 1
    # Harmless formatting and unrelated current prose are not old source seals.
    assert not errors({locale: raw + b"\n" for locale, raw in after.items()})
    cases += 1
    print("FIRST_WIN_FACT_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    failures = errors(after)
    for failure in failures:
        print("FIRST_WIN_FACT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(after)
    print("FIRST_WIN_FACT_OK locales=5 results=10 cost=15000 home=current_housing")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
