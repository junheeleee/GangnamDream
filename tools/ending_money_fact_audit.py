#!/usr/bin/env python3
"""Bounded money-subject repair; not full-ending prose or release approval."""
from __future__ import annotations

import argparse
import copy
import json
import re
from pathlib import Path

from ui_translation_append import _Document
from ja_translation_pipeline import _gd_function_source

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
VARIANTS = {
    "stable_success": ("cut_sangchul_network",),
    "orthodox_pinnacle": ("salary_raised", "salary_denied", "credit_asserted",
        "credit_recognized", "jobswitch_reconnected", "declined_golf", "extreme_frugal",
        "frugal_quiet", "skipped_staycation", "ignored_mystery_info", "orthodox_wavered"),
    "unorthodox_legend": ("cafe_double_jackpot", "coin_second_win", "holdem_high_stakes_win",
        "own_path_solidified", "investigating_gray_contact", "gray_tip_debt_paid"),
}
NET = {"ko": "순자산", "en": "net worth", "ja": "純資産", "zh-CN": "净资产", "zh-TW": "淨資產"}
AMOUNTS = {
    "ko": ("10억 이상", "5억 이상"),
    "en": ("at least one billion won", "at least five hundred million won"),
    "ja": ("10億ウォン以上", "5億ウォン以上"),
    "zh-CN": (r"(?:至少(?:有)?10亿韩元|10亿韩元以上)", r"至少(?:有)?5亿韩元"),
    "zh-TW": (r"(?:至少(?:有)?10億韓元|10億韓元以上)", r"至少(?:有)?5億韓元"),
}
STALE = {"ko": ("통장", "잔고", "은행 앱", "20억"),
    "en": ("in the bank", "in the account", "banking app", "a balance of", "remaining two billion"),
    "ja": ("口座", "残高", "20億"), "zh-CN": ("账户", "余额", "20亿"),
    "zh-TW": ("帳戶", "餘額", "20億")}
TOKEN = re.compile(r"\{[^{}]+\}|%(?:\d+\$)?[-+0 #]*\d*(?:\.\d+)?[sdif]|\[/?[A-Za-z][^\]]*\]")
GAME = "autoloads/GameState.gd"


def path(locale):
    return "content/endings" + ("" if locale == "ko" else "_" + locale) + ".json"


def selected(document):
    found = {}
    ids = [row["id"] for row in document.value]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate ending ID")
    for index, row in enumerate(document.value):
        if row["id"] in VARIANTS:
            found[(row["id"], "description")] = (row["description"], (index, "description"))
            for flag in VARIANTS[row["id"]]:
                found[(row["id"], "description_if_known", flag)] = (
                    row["description_if_known"][flag], (index, "description_if_known", flag))
    expected = {(ending, "description") for ending in VARIANTS}
    expected.update((ending, "description_if_known", flag)
                    for ending, flags in VARIANTS.items() for flag in flags)
    if set(found) != expected:
        raise ValueError("current money ending variants missing")
    return found


def errors(after):
    if set(after) != set(LOCALES):
        return ["exact five ending locales required"]
    failures = []
    source_leaves = selected(_Document(after["ko"]))
    for locale in LOCALES:
        leaves = selected(_Document(after[locale]))
        for keys, (text, _) in leaves.items():
            label = locale + ":" + "/".join(keys)
            if not isinstance(text, str) or not text.count("{name}"):
                failures.append(label + ": current name token absent")
                continue
            # JA/zh are direct KO overlays. English can use a pronoun where KO
            # repeats a name; it remains a nonempty current player-name consumer.
            if locale != "en" and TOKEN.findall(text) != TOKEN.findall(source_leaves[keys][0]):
                failures.append(label + ": current source tokens differ")
            if NET[locale] not in text.lower():
                failures.append(label + ": net-worth subject absent")
            amount = AMOUNTS[locale][int(keys[0] == "unorthodox_legend")]
            if len(re.findall(amount, text, re.IGNORECASE)) != 1:
                failures.append(label + ": inclusive threshold missing or repeated")
            if any(word in text.lower() for word in STALE[locale]):
                failures.append(label + ": stale cash/fixed-remainder fact")
    return failures


def runtime_errors(source):
    """Bind the translated threshold facts to the current ending owner."""
    owner = _gd_function_source(source, "check_game_over")
    compact = re.sub(r"\s+|\\", "", "\n".join(
        line.split("#", 1)[0] for line in owner.splitlines()))
    failures = []
    if compact.count('vartotal=get_total_asset_value()') != 1:
        failures.append("current ending settlement must use live net worth")
    for ending, condition in (
        ("orthodox_pinnacle", "total>=1_000_000_000androute_orthodox-route_unorthodox>=15"),
        ("unorthodox_legend", "total>=500_000_000androute_unorthodox-route_orthodox>=15"),
        ("stable_success", "total>=1_000_000_000"),
    ):
        branch = 'if' + condition + ':finish_run("' + ending + '");return'
        if compact.count(branch) != 1 or owner.count('finish_run("' + ending + '")') != 1:
            failures.append(ending + ": current inclusive net-worth branch differs")
    return failures


def self_test(after, source):
    cases = 0
    for label, locale, ending, field, replace in (
        ("fixed remainder", "en", "stable_success", "description", lambda t: t + " remaining two billion"),
        ("cash subject", "ko", "orthodox_pinnacle", "description", lambda t: t.replace("순자산", "통장")),
        ("exclusive threshold", "ko", "unorthodox_legend", "description", lambda t: t.replace("5억 이상", "5억 초과")),
        ("token drift", "en", "stable_success", "description", lambda t: t.replace("{name}", "Minjun")),
    ):
        mutant = copy.deepcopy(after)
        rows = json.loads(mutant[locale])
        row = next(r for r in rows if r["id"] == ending)
        original, changed = row[field], replace(row[field])
        mutant[locale] = mutant[locale].replace(json.dumps(original, ensure_ascii=False).encode(),
                                               json.dumps(changed, ensure_ascii=False).encode(), 1)
        if not errors(mutant):
            raise AssertionError(label + " was accepted")
        cases += 1
    assert errors({locale: raw for locale, raw in after.items() if locale != "ja"})
    cases += 1
    assert not errors({locale: raw + b"\n" for locale, raw in after.items()})
    cases += 1
    owner = _gd_function_source(source, "check_game_over")
    for before, changed in (
        ("var total = get_total_asset_value()", "var total = money"),
        ("total >= 1_000_000_000", "total > 1_000_000_000"),
        ("total >= 500_000_000 and route_unorthodox", "total >= 600_000_000 and route_unorthodox"),
        ('finish_run("stable_success")', 'finish_run("ordinary_life")'),
    ):
        mutant = source.replace(owner, owner.replace(before, changed, 1), 1)
        assert mutant != source and runtime_errors(mutant), "current ending branch drift accepted"
        cases += 1
    assert not runtime_errors(source + "\n"), "unrelated source whitespace must remain free"
    print("ENDING_MONEY_FACT_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    source = (ROOT / GAME).read_text(encoding="utf-8")
    failures = errors(after) + runtime_errors(source)
    for failure in failures:
        print("ENDING_MONEY_FACT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(after, source)
    print("ENDING_MONEY_FACT_OK locales=5 net_worth=inclusive_thresholds leaves=105")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
