#!/usr/bin/env python3
"""ORDER-422: two exact employment UI numeric contracts, no old suites."""
from __future__ import annotations

import json
from pathlib import Path
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
import full_game_localization as exchange
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]
PATHS = "하나를 택하면 다른 두 길은 이번 주에 닫힌다."
RANGE = "지출 3만~10만원을 막는다"
ACTUAL = {
    PATHS: ("选一条路，本周另外两条路就会关闭。", "選了一條路，另外兩條這週就走不了。"),
    RANGE: ("省下3万~10万韩元开销", "省下3萬韓元～10萬韓元的開支"),
}


def employment_choice_number_self_test() -> tuple[list[str], int]:
    errors: list[str] = []
    cases = []

    def pair(name, source, targets, *, passed=False, helper="REJECT",
             owner=None, group="ui", component=None):
        for locale, target in zip(zh.LANGUAGES, targets):
            cases.append((name + "/" + locale, locale, source, source if owner is None else owner,
                          group, target, passed, helper, component))

    for source, targets in ACTUAL.items():
        pair("actual_paths" if source == PATHS else "actual_range", source, targets,
             passed=True, helper="NORMALIZE")
    pair("natural_paths", PATHS, (
        "一旦选定1条路，其余2条路本周就无法选择。",
        "如果選擇一條路，剩下的兩條路這週便不能走。",
    ), passed=True, helper="NORMALIZE")
    for name, cn_old, tw_old, cn_new, tw_new in (
        ("chosen_two", "选一", "選了一", "选两", "選了兩"),
        ("remaining_three", "另外两", "另外兩", "另外三", "另外三"),
        ("remaining_one", "另外两", "另外兩", "另外一", "另外一"),
        ("missing_choice", "选一条路，", "選了一條路，", "", ""),
        ("missing_other", "另外两条路", "另外兩條", "", ""),
        ("wrong_unit", "另外两条路", "另外兩條", "另外两人", "另外兩人"),
        ("wrong_week", "本周", "這週", "下周", "下週"),
        ("missing_week", "本周", "這週", "", ""),
        ("open_not_closed", "就会关闭", "就走不了", "不会关闭", "就能走"),
        ("sign", "选一", "選了一", "选+1", "選了-1"),
        ("decimal", "选一", "選了一", "选1.0", "選了1.0"),
    ):
        pair(name, PATHS, (ACTUAL[PATHS][0].replace(cn_old, cn_new, 1),
                           ACTUAL[PATHS][1].replace(tw_old, tw_new, 1)))
    pair("swapped_roles", PATHS, ("选两条路，本周另外一条路就会关闭。",
                                  "選了兩條路，另外一條這週就走不了。"))
    pair("duplicate_choice", PATHS, ("选一条路，" + ACTUAL[PATHS][0],
                                     "選了一條路，" + ACTUAL[PATHS][1]))
    pair("duplicate_other", PATHS, (ACTUAL[PATHS][0] + "另外两条路。",
                                    ACTUAL[PATHS][1] + "另外兩條路。"))
    pair("borrowed_quantity", PATHS, (ACTUAL[PATHS][0].replace("另外两", "另外") + "两条路。",
                                      ACTUAL[PATHS][1].replace("另外兩", "另外") + "兩條路。"))
    pair("other_extra_count", PATHS, (ACTUAL[PATHS][0] + "一人。", ACTUAL[PATHS][1] + "一人。"))
    pair("negated_choice", PATHS, ("不" + ACTUAL[PATHS][0], "不" + ACTUAL[PATHS][1]))
    pair("borrowed_week", PATHS, ("选一条路，另外两条路关闭。本周。",
                                  "選了一條路，另外兩條走不了。這週。"))
    pair("wrong_week_then_correct", PATHS, ("选一条路，另外两条路下周关闭。本周。",
                                            "選了一條路，另外兩條下週走不了。這週。"))

    for name, targets in (
        ("range_shared", ("省下3万～10万韩元开销", "省下3萬～10萬韓元的開支")),
        ("range_repeated", ("省下3万韩元至10万韩元开销", "省下3萬韓元至10萬韓元的開支")),
        ("range_natural", ("减少支出30000韩元到100000韩元", "節省三萬至十萬韓元的開支")),
    ):
        pair(name, RANGE, targets, passed=True, helper="NORMALIZE")
    for name, cn_old, tw_old, cn_new, tw_new in (
        ("lower", "3万", "3萬", "4万", "4萬"),
        ("lower_scale", "3万", "3萬", "3千", "3千"),
        ("upper", "10万", "10萬", "11万", "11萬"),
        ("negative", "3万", "3萬", "-3万", "-3萬"),
        ("positive_sign", "3万", "3萬", "+3万", "+3萬"),
        ("range_sum", "~", "～", "加", "加"),
        ("range_two_payments", "~", "～", "和", "和"),
        ("currency", "韩元", "韓元", "美元", "美元"),
        ("wrong_role", "省下", "省下", "收入", "收入"),
        ("negated_saving", "省下", "省下", "不省下", "不省下"),
        ("upper_rate", "韩元开销", "韓元的開支", "韩元/月开销", "韓元/月的開支"),
        ("qualified", "韩元开销", "韓元的開支", "韩元以上开销", "韓元以上的開支"),
    ):
        pair(name, RANGE, (ACTUAL[RANGE][0].replace(cn_old, cn_new, 1),
                           ACTUAL[RANGE][1].replace(tw_old, tw_new, 1)))
    pair("reversed_range", RANGE, ("省下10万~3万韩元开销", "省下10萬韓元～3萬韓元的開支"))
    pair("duplicate_range", RANGE, tuple(text + text for text in ACTUAL[RANGE]))
    pair("approximate_range", RANGE, ("约" + ACTUAL[RANGE][0], "約" + ACTUAL[RANGE][1]))
    pair("approximate_lower", RANGE, (ACTUAL[RANGE][0].replace("3万", "约3万"),
                                      ACTUAL[RANGE][1].replace("3萬", "約3萬")))
    pair("changed_upper_scale", RANGE, (ACTUAL[RANGE][0].replace("10万", "10千"),
                                        ACTUAL[RANGE][1].replace("10萬", "10千")))
    pair("extra_money", RANGE, (ACTUAL[RANGE][0] + "，另有1韩元。",
                                ACTUAL[RANGE][1] + "，另有1韓元。"))
    pair("extra_count", RANGE, (ACTUAL[RANGE][0] + "，一人。", ACTUAL[RANGE][1] + "，一人。"))
    # Every independent diagnostic sees original bytes, even when numeric
    # ownership itself rejects a mutation. No filtering of error strings.
    for source, targets in ACTUAL.items():
        for name, suffix, component in (
            ("token", " %s", "placeholder/BBCode mismatch"),
            ("bbcode", "[b]", "placeholder/BBCode mismatch"),
            ("newline", "\n", "newline mismatch"),
            ("currency_diagnostic", " ￥2", "Korean won was relabeled as yen/yuan/Taiwan dollar"),
        ):
            pair(name, source, tuple(text + suffix for text in targets),
                 helper=None, component=component)
        pair("script", source, (
            targets[0].replace("选", "選").replace("万", "萬"),
            targets[1].replace("選", "选").replace("萬", "万"),
        ), helper=None, component="script")
        pair("source_boundary", source + " ", targets, owner=source, passed=None, helper="OFF")
        pair("key_boundary", source, targets, owner="qa_other_employment", passed=None, helper="OFF")
        pair("group_boundary", source, targets, group="events", passed=None, helper="OFF")
        for locale in ("ja", "en"):
            cases.append(("locale_boundary/" + locale, locale, source, source, "ui",
                          targets[0], None, "OFF", None))
    pair("old_two_paths_title", "두 길 사이", ("两条路之间", "兩條路之間"), passed=True, helper="OFF")
    pair("old_title_wrong_count", "두 길 사이", ("三条路之间", "三條路之間"), helper="OFF")
    pair("old_coffee_title", "두 번째 커피", ("第二次咖啡闲谈", "第二次喝咖啡"), passed=True, helper="OFF")

    main = (ROOT / "scenes/MainGame.gd").read_text(encoding="utf-8")
    for source, consumer in ((PATHS, "_render_scene_first_decision"), (RANGE, "_weekly_commitment_base_preview")):
        body = main.split("func " + consumer + "(", 1)[1].split("\nfunc ", 1)[0]
        if body.count(json.dumps(source, ensure_ascii=False)) != 1:
            errors.append("actual source anchor changed: " + consumer)
    for name, locale, source, owner, group, target, passed, expected_helper, component in cases:
        leaf = exchange.Leaf(group, owner, "runtime:static_ui", (owner,), source, "ui_static_context")
        args = (locale, leaf.id, source, target)
        problems = []
        try:
            adapted = [fn(*args) for fn in (zh._ui_choice_paths_numbers, zh._ui_expense_range_numbers)]
            active = [item for item in adapted if item is not None]
            state = "OFF" if not active else "REJECT" if active[0][2] else "NORMALIZE"
            direct = zh.validate_text(*args)
            full = exchange.translation_errors(leaf, locale, target)
            if len(active) > 1 or expected_helper is not None and state != expected_helper:
                problems.append(f"helper {state} != {expected_helper}")
            if passed is not None and (bool(direct) == passed or bool(full) == passed):
                problems.append(f"direct={direct!r}, full={full!r}, expected_pass={passed}")
            if component:
                expected = zh._script_errors(locale, target) if component == "script" else [component]
                if not expected or any(not any(item in error for error in direct) or
                                       not any(item in error for error in full) for item in expected):
                    problems.append("original diagnostic lost: " + component)
            if expected_helper == "OFF" or name.startswith("actual_"):
                with patch.object(zh, "_ui_choice_paths_numbers", return_value=None), \
                        patch.object(zh, "_ui_expense_range_numbers", return_value=None):
                    old_direct = zh.validate_text(*args)
                    old_full = exchange.translation_errors(leaf, locale, target)
                if expected_helper == "OFF" and (direct != old_direct or full != old_full):
                    problems.append("unowned original path changed")
                if name.startswith("actual_paths") and not all(
                        any("unmatched target entity quantity invented: 2" in item for item in result)
                        for result in (old_direct, old_full)):
                    problems.append("original two-path false positive not reproduced")
                if name == "actual_range/zh-TW" and not all(
                        any("Korean-won values changed" in item for item in result)
                        for result in (old_direct, old_full)):
                    problems.append("original shared-unit false positive not reproduced")
                if name == "actual_range/zh-CN" and (old_direct or old_full):
                    problems.append("original shared-unit CN coincident pass changed")
            errors.extend(name + ": " + problem for problem in problems)
            print(f"EMPLOYMENT_CHOICE_NUMBER_CASE {name} {'FAIL' if problems else 'PASS'}")
        except Exception as exc:
            errors.append(f"{name}: {type(exc).__name__}: {exc}")
            print(f"EMPLOYMENT_CHOICE_NUMBER_CASE {name} FAIL exception")
    return errors, len(cases)


if __name__ == "__main__":
    failures, count = employment_choice_number_self_test()
    for failure in failures:
        print("EMPLOYMENT_CHOICE_NUMBER_ERROR " + failure)
    print(f"EMPLOYMENT_CHOICE_NUMBER_{'FAIL' if failures else 'OK'} cases={count} historical_cases=0")
    raise SystemExit(int(bool(failures)))
