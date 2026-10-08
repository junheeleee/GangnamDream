#!/usr/bin/env python3
"""Current gift caption, fallback and localization-consumer regression tests."""
from __future__ import annotations

from collections import Counter
from dataclasses import replace
import json
from pathlib import Path

import ja_translation_pipeline as pipeline

ROOT = Path(__file__).resolve().parents[1]
MAIN = "scenes/MainGame.gd"
OLD_KO = "선물 — 사람 메뉴에서 전달"
CAPTION = (MAIN, "_render_sidebars", "legacy", "선물", "Gift", "")
FALLBACK = (MAIN, "_gift_display_name", "legacy", "선물", "Gift", "")


def selector(call):
    return call.path, call.function, call.api, call.korean, call.english, call.context_id


def gift_errors(calls):
    owned = [c for c in calls if c.korean == "선물" or c.english == "Gift" or c.korean == OLD_KO]
    errors = []
    if Counter(map(selector, owned)) != Counter((CAPTION, FALLBACK)):
        errors.append("gift caption/fallback owner, API, context or text differs")
    if any(c.korean == OLD_KO for c in calls):
        errors.append("retired misleading gift delivery caption is still displayed")
    if any(pipeline.PLACEHOLDER.findall(c.korean) or pipeline.PLACEHOLDER.findall(c.english)
           for c in owned):
        errors.append("gift caption unexpectedly formats an argument")
    return errors


def run_self_test():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    source = (ROOT / MAIN).read_text(encoding="utf-8")
    calls, parse_errors = pipeline.parse_ui_calls(MAIN, source)
    inventory = pipeline.collect_ui_inventory()
    direct = [c for c in inventory.calls if c.path == MAIN]
    check(not parse_errors and not inventory.errors, "current source/collector is clean")
    check(Counter(map(selector, calls)) == Counter(map(selector, direct)),
          "direct collector retains actual MainGame calls")
    check(not gift_errors(calls), "current caption and shared fallback")
    for locale, wanted in (("ja", "贈り物"), ("zh-CN", "礼物"), ("zh-TW", "禮物")):
        table = json.loads((ROOT / f"locale/ui_{locale}.json").read_text(encoding="utf-8"))
        check(table.get("선물") == wanted and OLD_KO not in table,
              f"{locale} gift means a present, not a futures contract")

    index = next(i for i, c in enumerate(calls) if selector(c) == CAPTION)
    for field, value in (
        ("path", "scenes/Other.gd"), ("function", "_gift_display_name"),
        ("api", "context"), ("context_id", "unexpected.gift"),
        ("korean", "선물 안내"), ("english", "Present"),
        ("korean", "선물 %s"),
    ):
        changed = list(calls)
        changed[index] = replace(changed[index], **{field: value})
        check(bool(gift_errors(changed)), f"reject changed gift {field}")
    check(bool(gift_errors([c for i, c in enumerate(calls) if i != index])),
          "reject missing gift caption")
    check(bool(gift_errors([*calls, calls[index]])), "reject duplicated gift caption")
    check(bool(gift_errors([c for c in calls if selector(c) != FALLBACK])),
          "reject missing shared fallback")
    shifted = [replace(c, line=c.line + 31) for c in reversed(calls)]
    check(not gift_errors(shifted), "line changes and call ordering do not change gift meaning")
    whitespace_calls, whitespace_errors = pipeline.parse_ui_calls(MAIN, source + "\n")
    check(not whitespace_errors and not gift_errors(whitespace_calls),
          "unrelated source whitespace is not a product failure")
    return failures, cases


def main():
    try:
        failures, cases = run_self_test()
    except Exception as exc:
        failures, cases = [f"{type(exc).__name__}: {exc}"], 0
    for failure in failures:
        print("ERROR gift caption locale: " + failure)
    print(f"GIFT_CAPTION_SOURCE_SELF_TEST_{'FAIL' if failures else 'OK'} cases={cases}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
