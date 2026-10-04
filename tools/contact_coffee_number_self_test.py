#!/usr/bin/env python3
"""ORDER-419: exact contact-coffee numeric scope, without historical suites."""
from __future__ import annotations

import json
from pathlib import Path
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
import full_game_localization as exchange
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]
SOURCE = "두 번째 커피 이후로 임상철은 진짜 이야기를 시작했다. 30년의 눈이 담긴 이야기들."
ACTUAL = {
    "zh-CN": "第二次喝咖啡后，Im Sangchul开始讲真正的故事。那些故事里，有他30年的阅历。",
    "zh-TW": "喝過第二次咖啡後，Im Sangchul才開始說真正的故事。那些故事裡，藏著他30年的閱歷。",
}


def contact_coffee_number_self_test() -> tuple[list[str], int]:
    errors: list[str] = []
    cases = []

    def pair(name, targets, *, passed=False, helper="REJECT", source=SOURCE,
             owner=SOURCE, group="ui", component=None):
        for locale, target in zip(ACTUAL, targets):
            cases.append((name + "/" + locale, locale, source, owner, group,
                          target, passed, helper, component))

    # The two unchanged targets rejected by official ORDER-418 check come first.
    pair("actual", ACTUAL.values(), passed=True, helper="NORMALIZE")
    pair("independent_natural", (
        ACTUAL["zh-CN"].replace("第二次喝咖啡后", "第二回喝咖啡之后"),
        ACTUAL["zh-TW"].replace("喝過第二次咖啡後", "第二回喝咖啡之後"),
    ), passed=True, helper="NORMALIZE")
    for name, old, new in (
        ("first", "第二", "第一"), ("third", "第二", "第三"),
        ("cup", "次", "杯"), ("year_role", "次", "年"),
        ("missing_ordinal", "第二次", ""),
        ("missing_coffee", "咖啡", ""),
        ("signed", "第二", "第+2"), ("negative", "第二", "第-2"),
        ("decimal", "第二", "第2.0"), ("malformed_group", "第二", "第2,,"),
    ):
        pair(name, [text.replace(old, new, 1) for text in ACTUAL.values()])
    pair("before_not_after", [ACTUAL["zh-CN"].replace("后", "前", 1),
                              ACTUAL["zh-TW"].replace("後", "前", 1)])
    pair("missing_after", [ACTUAL["zh-CN"].replace("后", "", 1),
                           ACTUAL["zh-TW"].replace("後", "", 1)])
    pair("ordinal_borrowed_later", [text.replace("第二次", "", 1) + "第二次。"
                                    for text in ACTUAL.values()])
    pair("coffee_borrowed_later", [text.replace("咖啡", "", 1) + "咖啡。"
                                   for text in ACTUAL.values()])
    pair("duplicate_coffee", [text + "第二次咖啡。" for text in ACTUAL.values()])
    pair("duplicate_occasion", [text + "第二次。" for text in ACTUAL.values()])
    pair("duplicate_ordinal_variant", [ACTUAL["zh-CN"] + "第2回。", ACTUAL["zh-TW"] + "第２次。"])
    for name, old, new in (("years29", "30", "29"), ("years_missing", "30", ""),
                           ("years_unit", "30年", "30次")):
        pair(name, [text.replace(old, new, 1) for text in ACTUAL.values()], helper="NORMALIZE")
    # These failures must still reach their original non-numeric diagnostics.
    for name, suffix, component in (
        ("token", " %s", "placeholder/BBCode mismatch"),
        ("bbcode", "[b]", "placeholder/BBCode mismatch"),
        ("newline", "\n", "newline mismatch"),
        ("paragraph", "\n\n", "paragraph mismatch"),
        ("hangul", " 한글", "Hangul remains"),
        ("kana", " カナ", "Japanese kana remains"),
        ("money", " ￥2", "Korean won was relabeled as yen/yuan/Taiwan dollar"),
    ):
        pair(name, [text + suffix for text in ACTUAL.values()], helper="NORMALIZE", component=component)
    pair("name", [text.replace("Im Sangchul", "Han Jiyeon") for text in ACTUAL.values()],
         helper="NORMALIZE", component="must retain Romanized form")
    pair("script", [ACTUAL["zh-CN"].replace("阅历", "閱歷"),
                    ACTUAL["zh-TW"].replace("閱歷", "阅历")], helper="NORMALIZE", component="script")
    pair("source_boundary", ACTUAL.values(), source=SOURCE + " ", helper="OFF")
    pair("key_boundary", ACTUAL.values(), owner="qa_other_contact_coffee", helper="OFF")
    pair("group_boundary", ACTUAL.values(), group="events", helper="OFF")
    pair("original_title", ("第二次咖啡闲谈", "第二次喝咖啡"), source="두 번째 커피",
         owner="두 번째 커피", passed=True, helper="OFF")
    pair("original_title_cup", ("第二杯咖啡", "第二杯咖啡"), source="두 번째 커피",
         owner="두 번째 커피", helper="OFF")
    pair("generic_cups", ("两杯咖啡", "兩杯咖啡"), source="커피 두 잔", owner="커피 두 잔",
         passed=True, helper="OFF")
    pair("generic_cup_wrong_role", ("两次咖啡", "兩次咖啡"), source="커피 두 잔",
         owner="커피 두 잔", helper="OFF")
    for locale in ("ja", "en"):
        cases.append(("locale_boundary/" + locale, locale, SOURCE, SOURCE, "ui",
                      ACTUAL["zh-TW"], None, "OFF", None))

    # Read the two source anchors only; no inventory, history replay or engine.
    main = (ROOT / "scenes/MainGame.gd").read_text(encoding="utf-8")
    contact = main.split("func _contact_flavor(", 1)[1].split("\nfunc ", 1)[0]
    if contact.count(json.dumps(SOURCE, ensure_ascii=False)) != 1:
        errors.append("actual contact source anchor changed")
    arc = json.loads((ROOT / "content/events/arc_events.json").read_text(encoding="utf-8"))
    coffee = [event for event in arc if event.get("id") == "arc_sangchul_02_coffee"]
    if len(coffee) != 1 or coffee[0].get("title") != "두 번째 커피" \
            or not any("arc_sangchul_02_seen" in choice.get("flags", []) for choice in coffee[0]["choices"]):
        errors.append("actual second-encounter source binding changed")

    for name, locale, source, owner, group, target, passed, expected_helper, component in cases:
        leaf = exchange.Leaf(group, owner, "runtime:static_ui", (owner,), source, "ui_static_context")
        args = (locale, leaf.id, source, target)
        try:
            adapted = zh._ui_contact_coffee_numbers(*args)
            observed_helper = "OFF" if adapted is None else "REJECT" if adapted[2] else "NORMALIZE"
            direct = zh.validate_text(*args)
            full = exchange.translation_errors(leaf, locale, target)
            problems = []
            if observed_helper != expected_helper:
                problems.append(f"helper {observed_helper} != {expected_helper}")
            if adapted is not None and not adapted[2] and adapted != (
                    source.replace("두 번째 커피", "두 번째 대화", 1), target, []):
                problems.append("numeric-only source/target contract changed")
            if passed is not None and (bool(direct) == passed or bool(full) == passed):
                problems.append(f"direct={direct!r}, full={full!r}, expected_pass={passed}")
            if component:
                expected = zh._script_errors(locale, target) if component == "script" else [component]
                if not expected or any(not any(item in error for error in direct) or
                                       not any(item in error for error in full) for item in expected):
                    problems.append(f"original {component} diagnostic not retained")
            if expected_helper == "OFF" or name.startswith("actual/"):
                with patch.object(zh, "_ui_contact_coffee_numbers", return_value=None):
                    old_direct = zh.validate_text(*args)
                    old_full = exchange.translation_errors(leaf, locale, target)
                if expected_helper == "OFF" and (direct != old_direct or full != old_full):
                    problems.append("unowned original path changed")
                if name.startswith("actual/") and not (
                        any("ordinal_cup" in error for error in old_direct) and
                        any("ordinal_cup" in error for error in old_full)):
                    problems.append("original official cup false positive not reproduced")
            errors.extend(name + ": " + problem for problem in problems)
            print(f"CONTACT_COFFEE_NUMBER_CASE {name} {'FAIL' if problems else 'PASS'}")
        except Exception as exc:
            errors.append(f"{name}: {type(exc).__name__}: {exc}")
            print(f"CONTACT_COFFEE_NUMBER_CASE {name} FAIL exception")
    return errors, len(cases)


if __name__ == "__main__":
    failures, count = contact_coffee_number_self_test()
    for failure in failures:
        print("CONTACT_COFFEE_NUMBER_ERROR " + failure)
    print(f"CONTACT_COFFEE_NUMBER_{'FAIL' if failures else 'OK'} cases={count} historical_cases=0")
    raise SystemExit(int(bool(failures)))
