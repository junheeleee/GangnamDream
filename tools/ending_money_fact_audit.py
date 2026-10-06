#!/usr/bin/env python3
"""Bounded money-subject repair; not full-ending prose or release approval."""
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
BASE = "d6c1394fbf2a93f21179d7b7f9967cf9680fe449"
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


def path(locale):
    return "content/endings" + ("" if locale == "ko" else "_" + locale) + ".json"


def read_base():
    return {locale: subprocess.check_output(["git", "--no-replace-objects", "show", BASE + ":" + path(locale)],
                                           cwd=ROOT) for locale in LOCALES}


def selected(document):
    found = {}
    for index, row in enumerate(document.value):
        if row["id"] in VARIANTS:
            found[(row["id"], "description")] = (row["description"], (index, "description"))
            for flag in VARIANTS[row["id"]]:
                found[(row["id"], "description_if_known", flag)] = (
                    row["description_if_known"][flag], (index, "description_if_known", flag))
    if len(found) != 21:
        raise ValueError("exact21 owned leaf population")
    return found


def masked(document, leaves):
    text = document.text
    spans = sorted((document.spans[keys] for _, keys in leaves.values()), reverse=True)
    for start, end in spans:
        text = text[:start] + '"__OWNED_ENDING_MONEY_LEAF__"' + text[end:]
    return text


def errors(before, after):
    failures = []
    for locale in LOCALES:
        old, new = _Document(before[locale]), _Document(after[locale])
        old_leaves, new_leaves = selected(old), selected(new)
        if old_leaves.keys() != new_leaves.keys() or masked(old, old_leaves) != masked(new, new_leaves):
            failures.append(locale + ": outside21 raw/gameplay changed")
        for keys, (text, _) in new_leaves.items():
            source = old_leaves[keys][0]
            label = locale + ":" + "/".join(keys)
            if text == source:
                failures.append(label + ": money-subject correction absent")
            if text.count("\n") != source.count("\n") or TOKEN.findall(text) != TOKEN.findall(source):
                failures.append(label + ": line/token drift")
            if NET[locale] not in text.lower():
                failures.append(label + ": net-worth subject absent")
            amount = AMOUNTS[locale][int(keys[0] == "unorthodox_legend")]
            if len(re.findall(amount, text, re.IGNORECASE)) != 1:
                failures.append(label + ": inclusive threshold missing or repeated")
            if any(word in text.lower() for word in STALE[locale]):
                failures.append(label + ": stale cash/fixed-remainder fact")
    return failures


def self_test(before, after):
    cases = 0
    for label, locale, ending, field, replace in (
        ("fixed remainder", "en", "stable_success", "description", lambda t: t + " remaining two billion"),
        ("cash subject", "ko", "orthodox_pinnacle", "description", lambda t: t.replace("순자산", "통장")),
        ("exclusive threshold", "ko", "unorthodox_legend", "description", lambda t: t.replace("5억 이상", "5억 초과")),
        ("token drift", "en", "stable_success", "description", lambda t: t.replace("{name}", "Minjun")),
        ("line drift", "ja", "stable_success", "description", lambda t: t + "\n"),
    ):
        mutant = copy.deepcopy(after)
        rows = json.loads(mutant[locale])
        row = next(r for r in rows if r["id"] == ending)
        original, changed = row[field], replace(row[field])
        mutant[locale] = mutant[locale].replace(json.dumps(original, ensure_ascii=False).encode(),
                                               json.dumps(changed, ensure_ascii=False).encode(), 1)
        if not errors(before, mutant):
            raise AssertionError(label + " was accepted")
        cases += 1
    mutant = dict(after)
    mutant["ko"] += b"\n"
    assert errors(before, mutant), "unowned raw whitespace accepted"
    cases += 1
    assert errors(before, before), "old cash-bound prose accepted"
    cases += 1
    print("ENDING_MONEY_FACT_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    before = read_base()
    after = {locale: (ROOT / path(locale)).read_bytes() for locale in LOCALES}
    failures = errors(before, after)
    for failure in failures:
        print("ENDING_MONEY_FACT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(before, after)
    population = [(locale, path(locale), keys) for locale in LOCALES
                  for keys in selected(_Document(after[locale]))]
    digest = hashlib.sha256(json.dumps(population, ensure_ascii=False, separators=(",", ":")).encode()).hexdigest()
    print("ENDING_MONEY_FACT_OK locales=5 leaves=105 outside_owned_raw=unchanged population_sha256=" + digest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
