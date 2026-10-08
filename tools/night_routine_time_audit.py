#!/usr/bin/env python3
"""Current night-routine relative chronology; not native or release approval."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from ui_translation_append import _Document

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
EVENT_ID = "arc_night_routine"
FIELDS = ("result_text", "bridge_summary")
REPAIRS = {
    "ko": (("12시에 잤다.", "더 공부하지 않고 바로 잤다."),
           ("자정 전에", "공부를 일찍 마치고")),
    "en": (("Asleep by midnight.", "Went straight to bed without studying any more."),
           ("turned off his own light before midnight", "finished studying early and turned off his own light")),
    "ja": (("12時に寝た。", "それ以上勉強せず、すぐに寝た。"),
           ("日付が変わる前に", "勉強を早めに切り上げて")),
    "zh-CN": (("12点睡了。", "没再学习，直接睡了。"),
              ("在午夜前", "提早结束学习，")),
    "zh-TW": (("午夜12點睡了。", "沒再讀下去，直接睡了。"),
              ("在午夜前", "提早結束讀書，")),
}
ABSOLUTE_CLOCK = re.compile(
    r"\d+\s*(?:시|時|点|點|o.clock|a\\.m\\.|p\\.m\\.)|\d{1,2}:\d{2}|"
    r"midnight|noon|자정|정오|午夜|日付が変わる", re.I
)


def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"


def selected(document):
    indices = [i for i, event in enumerate(document.value) if event["id"] == EVENT_ID]
    if len(indices) != 1:
        raise ValueError("one current night routine required")
    index = indices[0]
    return {field: (document.value[index]["choices"][1][field], (index, "choices", 1, field))
            for field in FIELDS}


def errors(after):
    if set(after) != set(LOCALES):
        return ["exact five night-routine locales required"]
    failures = []
    for locale in LOCALES:
        current = selected(_Document(after[locale]))
        for field, (old_phrase, current_phrase) in zip(FIELDS, REPAIRS[locale]):
            text = current[field][0]
            if not isinstance(text, str) or text.count(current_phrase) != 1 \
                    or old_phrase in text or ABSOLUTE_CLOCK.search(text):
                failures.append(locale + ":" + field + ": relative chronology differs")
    event = next(row for row in _Document(after["ko"]).value if row["id"] == EVENT_ID)
    choice = event["choices"][1]
    if choice.get("effects") != {"mental": 6} \
            or any(type(value) not in (int, float) for value in choice.get("effects", {}).values()) \
            or choice.get("flags") != ["arc_night_routine_seen", "slept_early"]:
        failures.append("night-routine sleep choice effects/flags differ")
    return failures


def mutate(raw, field, change):
    document = _Document(raw)
    value, key = selected(document)[field]
    start, end = document.spans[key]
    return (document.text[:start] + json.dumps(change(value), ensure_ascii=False)
            + document.text[end:]).encode()


def self_test(after):
    cases = 0
    for locale in LOCALES:
        for field, (old_phrase, current_phrase) in zip(FIELDS, REPAIRS[locale]):
            changed = dict(after)
            changed[locale] = mutate(changed[locale], field,
                                     lambda text: text.replace(current_phrase, old_phrase, 1))
            assert errors(changed), locale + ": old absolute clock accepted " + field
            cases += 1
    changed = dict(after)
    changed["ko"] = mutate(changed["ko"], "result_text", lambda text: text + " 새벽 3시에 깼다.")
    assert errors(changed), "new absolute clock accepted"
    cases += 1
    assert errors({locale: raw for locale, raw in after.items() if locale != "ja"})
    cases += 1
    assert not errors({locale: raw + b"\n" for locale, raw in after.items()})
    cases += 1
    print("NIGHT_ROUTINE_TIME_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    failures = errors(after)
    for failure in failures:
        print("NIGHT_ROUTINE_TIME_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(after)
    print("NIGHT_ROUTINE_TIME_OK locales=5 relative_chronology=current leaves=10")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
