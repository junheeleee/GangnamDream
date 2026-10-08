#!/usr/bin/env python3
"""Current new-run system-log consumers, argument provenance and housing keys."""
from __future__ import annotations

from collections import Counter
from dataclasses import replace
import json
from pathlib import Path
import re

import ja_translation_pipeline as pipeline

ROOT = Path(__file__).resolve().parents[1]
GS = "autoloads/GameState.gd"
PROFILE_PAIRS = (("백수", "unemployed"), ("알바", "working part-time"))
THEME_ROWS = (
    ("investment", "투자", "Investing"), ("jobs", "직장", "Jobs"),
    ("social", "인간관계", "Social"), ("health", "건강", "Health"),
    ("relationship", "연애", "Relationships"), ("gambling", "도박", "Gambling"),
    ("finance", "재정", "Finance"),
)
LOGS = (
    ("start_new_game", "다시 시작한 아침. 출발점은 %s였다.",
     "Another beginning. He started out %s.",
     "[_localized_profile_label(starting_profile)]",
     "[_localized_profile_label(starting_profile,true)]"),
    ("_roll_run_theme", "이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.",
     "This time, news tied to %s and %s caught his eye first.",
     "[a,b]", "[english_labels.get(pool[0],pool[0]),english_labels.get(pool[1],pool[1])]"),
)


def selector(call):
    return call.path, call.function, call.api, call.korean, call.english, call.context_id


def shape_key(shape):
    return shape.path, shape.function, shape.korean, shape.english, shape.ko_args, shape.en_args


def new_run_errors(calls, shapes, source):
    expected = [(GS, "_localized_profile_label", "legacy", ko, en, "") for ko, en in PROFILE_PAIRS]
    expected += [(GS, "_roll_run_theme", "legacy", ko, en, "") for _, ko, en in THEME_ROWS]
    expected += [(GS, owner, "format", ko, en, "") for owner, ko, en, _, _ in LOGS]
    owned = [c for c in calls if c.function in ("_localized_profile_label", "_roll_run_theme")
             or (c.function == "start_new_game" and c.korean == LOGS[0][1])]
    errors = []
    if Counter(map(selector, owned)) != Counter(expected):
        errors.append("new-run labels/log owner, API, context or bilingual text differs")
    expected_shapes = Counter((GS, *row) for row in LOGS)
    owned_shapes = [s for s in shapes if s.path == GS and s.function in {row[0] for row in LOGS}]
    if Counter(map(shape_key, owned_shapes)) != expected_shapes:
        errors.append("new-run target/English argument provenance differs")
    for owner, ko, en, ko_args, en_args in LOGS:
        body = pipeline._normalize_gd_expression(pipeline._gd_function_source(source, owner))
        consumer = ("add_log(LocaleManager.ui_format(" + json.dumps(ko, ensure_ascii=False) + ","
                    + json.dumps(en, ensure_ascii=False) + "," + ko_args + "," + en_args + '),"system")')
        if consumer not in body:
            errors.append(f"{owner}: formatted localized text must reach the system log")
        if pipeline._ui_template_signature(ko) != pipeline._ui_template_signature(en):
            errors.append(f"{owner}: placeholder kinds differ")
    profile = pipeline._gd_function_source(source, "_localized_profile_label")
    if pipeline._gd_named_string_map(profile, "labels") != dict(PROFILE_PAIRS):
        errors.append("English-only profile labels differ")
    if "ifenglish_only:returnstr(labels.get(profile,profile))" not in pipeline._normalize_gd_expression(profile):
        errors.append("English fallback must not reuse the current target-language profile")
    theme = pipeline._gd_function_source(source, "_roll_run_theme")
    match = re.search(r"(?s)var\s+english_labels\s*:?=\s*\{(.*?)\}", theme)
    english_labels = {}
    if match:
        for a, b in re.findall(r'("(?:\\.|[^"\\])*")\s*:\s*("(?:\\.|[^"\\])*")', match[1]):
            english_labels[pipeline.decode_gd_string(a)] = pipeline.decode_gd_string(b)
    if english_labels != {category: en for category, _, en in THEME_ROWS}:
        errors.append("English-only theme category map differs")
    return errors


def housing_errors(calls, contract, source):
    provider, errors, _stats = pipeline.collect_dynamic_housing_ui_calls(contract, source)
    owned = [c for c in calls if c.path == GS and c.function in ("get_housing_name", "get_housing_display_name")]
    if Counter(map(selector, owned)) != Counter(map(selector, provider)):
        errors = [*errors, "current collector must include every narrative/display housing pair exactly once"]
    return errors


def whole_won_errors(source):
    body = pipeline._normalize_gd_expression(pipeline._gd_function_source(source, "_fmt"))
    return [] if body.count("return") == 1 and body.endswith(
        "returnLocaleManager.format_whole_won(int(amount))") else [
        "Holdem formatter must preserve exact whole-won presentation"]


def run_self_test():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    source = (ROOT / GS).read_text(encoding="utf-8")
    calls, parse_errors = pipeline.parse_ui_calls(GS, source)
    shapes, shape_errors = pipeline.collect_ui_format_argument_shapes()
    contract = pipeline.read_ui_context_contract()
    dynamic, dynamic_errors, _stats = pipeline.collect_dynamic_housing_ui_calls(contract, source)
    inventory = pipeline.collect_ui_inventory(contract)
    actual_gs = [c for c in inventory.calls if c.path == GS]
    complete = [*calls, *dynamic]
    check(not parse_errors and not shape_errors and not dynamic_errors and not inventory.errors,
          "current source and direct collector are clean")
    check(Counter(map(selector, actual_gs)) == Counter(map(selector, complete)),
          "direct collector includes literal and computed housing calls")
    check(not new_run_errors(calls, shapes, source), "current localized labels and two system logs")
    check(not housing_errors(actual_gs, contract, source), "current housing consumers")
    check(all(inventory.stats.get(key) == sum(c.api == api for c in inventory.calls)
              for key, api in (("legacy_api_calls", "legacy"), ("format_calls", "format"),
                               ("branch_variant_calls", "branch"), ("context_calls", "context"))),
          "current API partition is measured, not a historical census")
    shifted = [replace(c, line=c.line + 31) for c in reversed(calls)]
    shifted_shapes = [replace(s, line=s.line + 31) for s in reversed(shapes)]
    check(not new_run_errors(shifted, shifted_shapes, source + "\n"),
          "semantic location ignores line numbers, ordering and unrelated whitespace")
    index = next(i for i, c in enumerate(calls) if c.function == "_localized_profile_label" and c.korean == "백수")
    for field, value in (("path", "fixture.gd"), ("function", "_roll_run_theme"), ("api", "context"),
                         ("context_id", "unexpected.profile"), ("korean", "무직"), ("english", "idle")):
        changed = list(calls)
        changed[index] = replace(changed[index], **{field: value})
        check(bool(new_run_errors(changed, shapes, source)), f"reject new-run label {field} drift")
    check(bool(new_run_errors([c for i, c in enumerate(calls) if i != index], shapes, source)), "reject missing profile label")
    check(bool(new_run_errors([*calls, calls[index]], shapes, source)), "reject duplicated profile label")

    for owner, ko, en, ko_args, en_args in LOGS:
        call_index = next(i for i, c in enumerate(calls) if c.function == owner and c.korean == ko)
        for field, value in (("api", "legacy"), ("function", "other"), ("context_id", "unexpected.log"),
                             ("korean", ko.replace("%s", "%d", 1))):
            changed = list(calls)
            changed[call_index] = replace(changed[call_index], **{field: value})
            check(bool(new_run_errors(changed, shapes, source)), f"reject {owner} template {field} drift")
        shape_index = next(i for i, s in enumerate(shapes) if s.path == GS and s.function == owner)
        for field, value in (("ko_args", en_args), ("en_args", ko_args), ("function", "other"),
                             ("path", "fixture.gd")):
            changed = list(shapes)
            changed[shape_index] = replace(changed[shape_index], **{field: value})
            check(bool(new_run_errors(calls, changed, source)), f"reject {owner} argument {field} drift")
        check(bool(new_run_errors(calls, [s for i, s in enumerate(shapes) if i != shape_index], source)),
              f"reject missing {owner} argument shape")
    for before, after in (
        ("if english_only:", "if not english_only:"),
        ('"investment": "Investing", "jobs": "Jobs"', '"investment": "Jobs", "jobs": "Investing"'),
        ('[_localized_profile_label(starting_profile, true)]), "system")',
         '[_localized_profile_label(starting_profile, true)]), "event")'),
    ):
        check(before in source and bool(new_run_errors(calls, shapes, source.replace(before, after, 1))),
              "reject changed English fallback or system-log delivery")
    hi = next(i for i, c in enumerate(actual_gs) if c.function == "get_housing_name" and c.korean == "강남 아파트")
    for field, value in (("function", "get_housing_display_name"), ("english", "Gangnam Apartment"),
                         ("api", "format"), ("context_id", "unexpected.housing")):
        changed = list(actual_gs)
        changed[hi] = replace(changed[hi], **{field: value})
        check(bool(housing_errors(changed, contract, source)), f"reject housing {field} drift")
    check(bool(housing_errors([c for i, c in enumerate(actual_gs) if i != hi], contract, source)), "reject missing housing pair")
    check(bool(housing_errors([*actual_gs, actual_gs[hi]], contract, source)), "reject duplicated housing pair")
    check(bool(housing_errors([c for c in actual_gs if c.function not in ("get_housing_name", "get_housing_display_name")],
                              contract, source)), "reject omitted dynamic housing provider")
    changed_source = source.replace('"name_en": "Gangnam apartment"', '"name_en": "Gangnam Apartment"', 1)
    check(changed_source != source and bool(housing_errors(actual_gs, contract, changed_source)),
          "reject dynamic housing English meaning drift")
    changed_contract = dict(contract)
    changed_contract["dynamic_housing_registry_sha256"] = "0" * 64
    check(bool(housing_errors(actual_gs, changed_contract, source)), "reject altered housing registry checksum")

    holdem = (ROOT / "scenes/HoldemClub.gd").read_text(encoding="utf-8")
    check(not whole_won_errors(holdem), "current whole-won consumer")
    check(bool(whole_won_errors(holdem.replace("return LocaleManager.format_whole_won(int(amount))",
                                               "return LocaleManager.format_money(float(amount))", 1))),
          "reject lossy or compact Holdem money formatting")
    check(not whole_won_errors(holdem + "\n"), "whole-won ignores unrelated whitespace")
    return failures, cases


def main():
    try:
        failures, cases = run_self_test()
    except Exception as exc:
        failures, cases = [f"{type(exc).__name__}: {exc}"], 0
    for failure in failures:
        print("ERROR new-run log locale: " + failure)
    print(f"NEW_RUN_LOG_SOURCE_SELF_TEST_{'FAIL' if failures else 'OK'} cases={cases}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
