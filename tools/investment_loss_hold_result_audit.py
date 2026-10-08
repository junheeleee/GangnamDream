#!/usr/bin/env python3
"""Current five holding-result facts; not trading, native or release approval."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from ui_translation_append import _Document

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = "tools/InvestmentLossHoldResultCheck.gd"
SCENE = "tools/InvestmentLossHoldResultCheck.tscn"
EVENT = "arc_invest_first_loss"
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
UNCERTAIN = {
    "ko": "앱을 닫았다는 사실만으로 이번 판단이 옳았다고 말할 수는 없었다.",
    "en": "Closing the app was not enough to call his decision sound.",
    "ja": "アプリを閉じたというだけで、今回の判断が正しかったとは言えなかった。",
    "zh-CN": "仅仅关掉应用，并不能说明这次判断就是对的。",
    "zh-TW": "光是關掉App，並不能說這次的判斷就是對的。",
}
HOLDING = {
    "ko": "계속 팔지 않기로 선택하는 일이었다.",
    "en": "choosing not to sell over and over.",
    "ja": "売らないと選び続けることだった。",
    "zh-CN": "一直在选择不卖。",
    "zh-TW": "不斷選擇不賣。",
}


def path(locale):
    return "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"


def selected(document):
    rows = [i for i, row in enumerate(document.value) if row["id"] == EVENT]
    if len(rows) != 1:
        raise ValueError("one current holding-result event required")
    key = (rows[0], "choices", 1, "result_text")
    return document.value[rows[0]]["choices"][1]["result_text"], key


def replace(raw, text):
    document = _Document(raw)
    _, key = selected(document)
    start, end = document.spans[key]
    return (document.text[:start] + json.dumps(text, ensure_ascii=False)
            + document.text[end:]).encode()


def errors(after):
    if set(after) != set(LOCALES):
        return ["exact five holding-result locales required"]
    failures = []
    for locale in LOCALES:
        current, _key = selected(_Document(after[locale]))
        if not isinstance(current, str) or current.count(UNCERTAIN[locale]) != 1 \
                or current.count(HOLDING[locale]) != 1:
            failures.append(locale + ": uncertainty/continuing-hold fact differs")
        if not isinstance(current, str) or current.count("{name}") != 1 \
                or len(current.split("\n\n")) != 3:
            failures.append(locale + ": name/three-beat result structure differs")
    event = next(row for row in _Document(after["ko"]).value if row["id"] == EVENT)
    choice = event["choices"][1]
    effects = choice.get("effects", {})
    if effects != {"investment_skill": 3, "mental": -3} \
            or any(type(value) not in (int, float) for value in effects.values()) \
            or choice.get("flags") != ["arc_invest_first_loss_seen", "held_through_loss"]:
        failures.append("actual hold effects/flag producer differs")
    return failures


def fixture_errors(script, scene):
    text = script.decode("utf-8")
    required = (
        'extends "res://tools/ProseRecallCheck.gd"',
        'const HOLD_EVENT := "arc_invest_first_loss"',
        'const HOLD_READER := "callback_held_through_loss_echo"',
        'DataRegistry.find_event(HOLD_EVENT)', 'event.get("choices", [])[1]',
        '_source_text_matches(event, source)', 'raw == authored',
        'raw.count("{name}") == 1', 'story.call("_fmt", raw)',
        'GameState.apply_choice(event, choice)', '_unchanged_facts() == facts_before',
        'receipt.get("event_id", "") == HOLD_EVENT',
        'receipt.get("choice_index", -1) == 1',
        'receipt.get("result", "") == formatted',
        'actual == (retained and turn >= 36)',
        'for language: String in LOCALES:',
        'if not restored: failures.append("singleton restoration failed")',
    )
    failures = ["runtime consumer/oracle missing " + token
                for token in required if token not in text]
    if 'path="res://tools/InvestmentLossHoldResultCheck.gd"' not in scene.decode("utf-8") \
            or 'script = ExtResource("1_hold")' not in scene.decode("utf-8"):
        failures.append("runtime scene does not select the holding consumer")
    return failures


def self_test(after, script, scene):
    cases = 0
    for locale in LOCALES:
        current, _ = selected(_Document(after[locale]))
        for label, value in (
            ("guaranteed recovery", current.replace(UNCERTAIN[locale], "Recovery is guaranteed.")),
            ("token", current.replace("{name}", "Minjun")),
            ("paragraph", current + "\n\n"),
            ("sold", current.replace(HOLDING[locale], "Sold the holding.")),
        ):
            changed = dict(after)
            changed[locale] = replace(changed[locale], value)
            assert errors(changed), locale + ":" + label + " accepted"
            cases += 1
    assert errors({key: raw for key, raw in after.items() if key != "ja"})
    cases += 1
    for changed_script, changed_scene in (
        (script.replace(b"GameState.apply_choice", b"GameState.skip_choice", 1), scene),
        (script, scene.replace(b"HoldResultCheck.gd", b"GateCheck.gd", 1)),
    ):
        assert fixture_errors(changed_script, changed_scene), "consumer/scene drift accepted"
        cases += 1
    assert not errors({locale: raw + b"\n" for locale, raw in after.items()})
    assert not fixture_errors(script + b"\n", scene + b"\n")
    cases += 1
    print("INVESTMENT_LOSS_HOLD_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    script, scene = ((ROOT / value).read_bytes() for value in (FIXTURE, SCENE))
    failures = errors(after) + fixture_errors(script, scene)
    for failure in failures:
        print("INVESTMENT_LOSS_HOLD_AUDIT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(after, script, scene)
    print("INVESTMENT_LOSS_HOLD_AUDIT_OK locales=5 results=5 current_uncertainty=preserved")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
