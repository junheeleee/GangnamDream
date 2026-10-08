#!/usr/bin/env python3
"""Current first-start notice and unformatted delivery-header regressions."""
from __future__ import annotations

from collections import Counter
from dataclasses import replace
from pathlib import Path
import re
import sys

import ja_translation_pipeline as pipeline

ROOT = Path(__file__).resolve().parents[1]
START = "scenes/StartMenu.gd"
DELIVERY = "scenes/ArubaGame.gd"
NOTICE_KO = "이 게임에는 다음과 같은 내용이 포함됩니다:\n\n• 재정적 어려움과 부채\n• 가족·사회적 압박과 비교\n• 직장 스트레스와 번아웃\n• 정신건강 관련 묘사\n\n강남드림은 현실적인 삶을 다룹니다. 어려운 상황들은 이야기의 일부이며, 권장하는 내용이 아닙니다."
NOTICE_EN = "This game contains depictions of:\n\n• Financial hardship and debt\n• Family pressure and social comparison\n• Workplace stress and burnout\n• Mental health struggles\n\nGangnam Dream is a realistic portrayal of life. Difficult situations are part of the story — not endorsements."
NOTICE = (START, "_show_content_warning", "legacy", NOTICE_KO, NOTICE_EN, "")
HEADER_PAIRS = (("비 오는 저녁 배달", "Rainy Evening Delivery"),
                ("배달 루트 설정", "Delivery Route Planning"))


def selector(call):
    return call.path, call.function, call.api, call.korean, call.english, call.context_id


def notice_errors(calls, source):
    owned = [c for c in calls if c.korean.startswith("이 게임에는")
             or c.english.startswith("This game contains")]
    errors = []
    if Counter(map(selector, owned)) != Counter((NOTICE,)):
        errors.append("notice owner, API, context or full bilingual body differs")
    if any(c.korean.count("\n") != 7 or c.english.count("\n") != 7 for c in owned):
        errors.append("notice paragraph layout differs")
    request = pipeline._normalize_gd_expression(pipeline._gd_function_source(source, "_request_new_run"))
    gate = 'ifnotMetaProgression.data.get("content_warning_seen",false):_show_content_warning()return_do_start_run()'
    if gate not in request or request.count("_do_start_run()") != 1:
        errors.append("unseen notice must precede starting the run")
    warning = pipeline._normalize_gd_expression(pipeline._gd_function_source(source, "_show_content_warning"))
    accepted = ('ok_btn.pressed.connect(func():MetaProgression.data["content_warning_seen"]=true'
                'MetaProgression.save_meta()overlay.queue_free()_do_start_run())')
    if accepted not in warning or warning.count("_do_start_run()") != 1:
        errors.append("acceptance must persist the notice and start the run")
    return errors


def header_errors(calls, source):
    owned = [c for c in calls if c.korean in {ko for ko, _ in HEADER_PAIRS}]
    expected = Counter((DELIVERY, "open", "branch", ko, en, "") for ko, en in HEADER_PAIRS)
    errors = []
    if Counter(map(selector, owned)) != expected:
        errors.append("delivery title branch owner, API, context or text differs")
    body = pipeline._normalize_gd_expression(pipeline._gd_function_source(source, "open"))
    consumer = ('_header_lbl.text=LocaleManager.ui("비 오는 저녁 배달"if_is_rain_surge_shift()else"배달 루트 설정",'
                '"Rainy Evening Delivery"if_is_rain_surge_shift()else"Delivery Route Planning")_start_delivery()')
    delivery_body = re.search(r"Mode\.DELIVERY:(.*?)(?=Mode\.[A-Z_]+:|$)", body)
    if delivery_body is None or consumer not in delivery_body[1]:
        errors.append("delivery header must use the same rain selector in both languages")
    return errors


def notice_self_test():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    source = (ROOT / START).read_text(encoding="utf-8")
    calls, errors = pipeline.parse_ui_calls(START, source)
    inventory = pipeline.collect_ui_inventory()
    check(not errors and not inventory.errors, "current source/collector is clean")
    check(Counter(map(selector, calls)) == Counter(map(selector, (c for c in inventory.calls if c.path == START))),
          "direct collector retains actual StartMenu calls")
    check(not notice_errors(calls, source), "notice text and first-start delivery")
    index = next(i for i, c in enumerate(calls) if selector(c) == NOTICE)
    for field, value in (
        ("path", "scenes/MainGame.gd"), ("function", "_request_new_run"),
        ("api", "format"), ("context_id", "unexpected.notice"),
        ("korean", NOTICE_KO + " "), ("english", NOTICE_EN + " "),
        ("korean", NOTICE_KO.replace("\n", " ")),
    ):
        changed = list(calls)
        changed[index] = replace(changed[index], **{field: value})
        check(bool(notice_errors(changed, source)), f"reject notice {field} drift")
    check(bool(notice_errors([c for i, c in enumerate(calls) if i != index], source)),
          "reject missing notice")
    check(bool(notice_errors([*calls, calls[index]], source)), "reject duplicated notice")
    for before, after in (
        ('data.get("content_warning_seen", false)', 'data.get("content_warning_seen", true)'),
        ("\t\t_show_content_warning()\n", ""),
        ('MetaProgression.data["content_warning_seen"] = true', 'MetaProgression.data["content_warning_seen"] = false'),
        ("\t\tMetaProgression.save_meta()\n", ""),
    ):
        check(before in source and bool(notice_errors(calls, source.replace(before, after, 1))),
              "reject changed first-start notice lifecycle")
    shifted = [replace(c, line=c.line + 31) for c in reversed(calls)]
    check(not notice_errors(shifted, source + "\n"), "meaning-preserving line/order/whitespace changes")
    return failures, cases


def delivery_headers_self_test():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    source = (ROOT / DELIVERY).read_text(encoding="utf-8")
    calls, errors = pipeline.parse_ui_calls(DELIVERY, source)
    inventory = pipeline.collect_ui_inventory()
    check(not errors and not inventory.errors, "current delivery source/collector is clean")
    check(Counter(map(selector, calls)) == Counter(map(selector, (c for c in inventory.calls if c.path == DELIVERY))),
          "direct collector includes both delivery branches")
    check(not header_errors(calls, source), "current conditional delivery header")
    index = next(i for i, c in enumerate(calls) if c.korean == HEADER_PAIRS[0][0])
    for field, value in (("path", "fixture.gd"), ("function", "other"), ("api", "format"),
                         ("context_id", "unexpected.header"), ("english", "Other")):
        changed = list(calls)
        changed[index] = replace(changed[index], **{field: value})
        check(bool(header_errors(changed, source)), f"reject delivery {field} drift")
    check(bool(header_errors([c for i, c in enumerate(calls) if i != index], source)),
          "reject missing branch")
    check(bool(header_errors([*calls, calls[index]], source)), "reject duplicated branch")
    changed_source = source.replace('"Rainy Evening Delivery" if _is_rain_surge_shift()',
                                    '"Rainy Evening Delivery" if other()', 1)
    check(changed_source != source and bool(header_errors(calls, changed_source)),
          "reject divergent language selector")

    plain = 'func open():\n\tLocaleManager.ui("비" if wet() else "맑음", "Rain" if wet() else "Clear")\n'
    branches, errors = pipeline.nonformat_ui_calls("fixture.gd", plain)
    check(not errors and [(c.korean, c.english) for c in branches] == [("비", "Rain"), ("맑음", "Clear")],
          "plain shared selector exposes both translations")
    for label, value in (
        ("different selectors", plain.replace('"Rain" if wet()', '"Rain" if dry()')),
        ("literal condition", plain.replace('wet()', 'weather == "rain"')),
        ("nested condition", plain.replace('"비" if wet()', '"비" if wet() else "눈" if cold()')),
        ("unpaired argument", plain.replace('"Rain" if wet() else "Clear"', '"Rain"')),
        ("third argument", plain.replace('else "Clear")', 'else "Clear", true)')),
        ("empty literal", plain.replace('"비"', '""')),
        ("format operator", plain.replace('else "Clear")', 'else "Clear") % 2')),
        ("property suffix", plain.replace('else "Clear")', 'else "Clear").length()')),
    ):
        _calls, errors = pipeline.nonformat_ui_calls("fixture.gd", value)
        check(bool(errors), "reject " + label)
    formatted = plain.replace('else "Clear")', 'else "Clear").format({})')
    check(pipeline.nonformat_ui_calls("fixture.gd", formatted) == ([], []),
          "formatted branch remains with its own parser")
    check(pipeline.nonformat_ui_calls("fixture.gd", 'func open():\n\tLocaleManager.ui("비", "Rain")\n') == ([], []),
          "literal call is not duplicated")
    check(not header_errors([replace(c, line=c.line + 31) for c in reversed(calls)], source + "\n"),
          "meaning-preserving line/order/whitespace changes")
    return failures, cases


def main():
    headers = sys.argv[1:] == ["--delivery-headers"]
    try:
        failures, cases = delivery_headers_self_test() if headers else notice_self_test()
    except Exception as exc:
        failures, cases = [f"{type(exc).__name__}: {exc}"], 0
    for failure in failures:
        print("ERROR first-start/delivery locale: " + failure)
    marker = "DELIVERY_HEADERS_SELF_TEST" if headers else "FIRST_START_NOTICE_SELF_TEST"
    print(f"{marker}_{'FAIL' if failures else 'OK'} cases={cases}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
