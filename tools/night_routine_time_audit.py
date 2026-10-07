#!/usr/bin/env python3
"""Exact night-routine chronology repair; not scene, native, or release approval."""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

from pr31_intake_history import _Document

ROOT = Path(__file__).resolve().parents[1]
BASE = "d58583aaf7bb9dc53c249f7ad28def492e51e6aa"  # Declared, before source5.
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
TOKEN = re.compile(r"\{[^{}]+\}|%(?:\d+\$)?[-+0 #]*\d*(?:\.\d+)?[sdif]|\[/?[A-Za-z][^\]]*\]")


def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"


def selected(document):
    indices = [i for i, event in enumerate(document.value) if event["id"] == EVENT_ID]
    if len(indices) != 1:
        raise ValueError("exact one night routine required")
    index = indices[0]
    return {field: (document.value[index]["choices"][1][field], (index, "choices", 1, field))
            for field in FIELDS}


def masked(document, leaves):
    text = document.text
    for start, end in sorted((document.spans[key] for _, key in leaves.values()), reverse=True):
        text = text[:start] + '"__NIGHT_TIME__"' + text[end:]
    return text


def errors(before, after):
    failures = []
    for locale in LOCALES:
        old, new = _Document(before[locale]), _Document(after[locale])
        previous, current = selected(old), selected(new)
        if masked(old, previous) != masked(new, current):
            failures.append(locale + ": unowned raw/structure/gameplay changed")
        for field, (old_phrase, new_phrase) in zip(FIELDS, REPAIRS[locale]):
            source, target = previous[field][0], current[field][0]
            if source.count(old_phrase) != 1 or target != source.replace(old_phrase, new_phrase, 1):
                failures.append(locale + ":" + field + ": exact relative chronology repair drift")
            if TOKEN.findall(source) != TOKEN.findall(target) or source.count("\n") != target.count("\n"):
                failures.append(locale + ":" + field + ": token/line drift")
    return failures


def mutate(raw, field, change):
    document = _Document(raw)
    value, key = selected(document)[field]
    start, end = document.spans[key]
    return (document.text[:start] + json.dumps(change(value), ensure_ascii=False)
            + document.text[end:]).encode()


def self_test(before, after):
    cases = 0
    for locale in LOCALES:
        for field, (old_phrase, new_phrase) in zip(FIELDS, REPAIRS[locale]):
            changed = dict(after)
            changed[locale] = mutate(changed[locale], field, lambda s: s.replace(new_phrase, old_phrase, 1))
            assert errors(before, changed), locale + ": old clock accepted " + field
            cases += 1
    for label, locale, field, change in (
        ("new absolute clock", "ko", "result_text", lambda s: s + " 새벽 3시에 깼다."),
        ("invented token", "en", "bridge_summary", lambda s: s + " {name}"),
        ("paragraph", "ja", "result_text", lambda s: s + "\n\n"),
        ("unrelated ending", "zh-TW", "result_text", lambda s: s + "。"),
    ):
        changed = copy.deepcopy(after)
        changed[locale] = mutate(changed[locale], field, change)
        assert errors(before, changed), label + " accepted"
        cases += 1
    changed = dict(after)
    changed["ko"] += b"\n"
    assert errors(before, changed), "outside raw whitespace accepted"
    cases += 1
    assert errors(before, before), "unfixed original chronology accepted"
    cases += 1
    print("NIGHT_ROUTINE_TIME_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    before = {locale: subprocess.check_output(
        ["git", "--no-replace-objects", "show", BASE + ":" + path(locale)], cwd=ROOT)
        for locale in LOCALES}
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    failures = errors(before, after)
    for failure in failures:
        print("NIGHT_ROUTINE_TIME_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(before, after)
    population = [{"file": path(locale), "event_id": EVENT_ID, "path": ["choices", 1, field]}
                  for locale in LOCALES for field in FIELDS]
    digest = hashlib.sha256(json.dumps(population, ensure_ascii=False, sort_keys=True,
                                      separators=(",", ":")).encode()).hexdigest()
    print("NIGHT_ROUTINE_TIME_OK locales=5 leaves=10 outside_owned_raw=unchanged population_sha256=" + digest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
