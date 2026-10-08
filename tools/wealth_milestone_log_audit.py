#!/usr/bin/env python3
"""Current net-worth milestone/log facts; no historical source seals."""
import argparse
import json
import re
from pathlib import Path

from ui_translation_append import _loads
from ja_translation_pipeline import _gd_function_source, parse_ui_calls

ROOT = Path(__file__).resolve().parents[1]
GAME = "autoloads/GameState.gd"
UI = {locale: "locale/ui_" + locale + ".json" for locale in ("ja", "zh-CN", "zh-TW")}
KEY = "🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다."
OLD_KEY = KEY + " 남은 건 10억."
EN = "🔥 Assets passed KRW 2B — Gangnam feels close."
OLD_EN = EN + " KRW 1B left."
TARGETS = {
    "ja": "🔥 資産が20億ウォンを突破 — カンナムに手が届きそうだ。",
    "zh-CN": "🔥 资产突破20亿韩元——江南仿佛触手可及。",
    "zh-TW": "🔥 資產突破20億韓元——江南彷彿近在眼前。",
}
FIXTURE = "tools/WealthMilestoneLogCheck.gd"
SCENE = "tools/WealthMilestoneLogCheck.tscn"


def normalized(source):
    return "\n".join(line.split("#", 1)[0].strip() for line in source.splitlines()
                     if line.split("#", 1)[0].strip())


def errors(after):
    if set(after) != {GAME, *UI.values()}:
        return ["current milestone source/target inputs absent"]
    failures = []
    source = after[GAME].decode("utf-8")
    calls, parse_errors = parse_ui_calls(GAME, source)
    failures.extend(parse_errors)
    selected = [call for call in calls if call.korean == KEY]
    if len(selected) != 1 or selected[0].function != "check_game_over" \
            or selected[0].english != EN or selected[0].api != "legacy":
        failures.append("current milestone log owner/KO/EN differs")
    owner = _gd_function_source(source, "check_game_over")
    block = (
        'if total_now >= 2_000_000_000 and not flags.get("asset_2b_reached", false):\n'
        'flags["asset_2b_reached"] = true\n'
        'add_log(LocaleManager.ui("' + KEY + '", "' + EN + '"), "money")'
    )
    if normalized(owner).count(block) != 1 \
            or 'var total_now = get_total_asset_value()' not in owner \
            or OLD_KEY in owner or OLD_EN in owner:
        failures.append("inclusive net-worth threshold/one-shot flag/current log differs")
    total = normalized("\n".join(
        line for line in _gd_function_source(source, "get_total_asset_value").splitlines()
        if line.startswith(("func ", "\t"))
    ))
    expected = normalized("""func get_total_asset_value():
    var total = money
    for asset_id in portfolio:
        var holding: Dictionary = portfolio[asset_id]
        total += float(holding.get("quantity", 0.0)) * float(market_prices.get(asset_id, holding.get("avg_price", 0.0)))
    return total - get_loan_total()
""")
    if total != expected:
        failures.append("cash plus marked holdings minus loans net-worth producer differs")
    for locale, path in UI.items():
        current = _loads(after[path])
        if not isinstance(current, dict) or current.get(KEY) != TARGETS[locale]:
            failures.append(path + ": current two-billion-won meaning differs")
    return failures


def fixture_errors(script, scene):
    text = script.decode("utf-8")
    required = (
        'extends "res://tools/ProseRecallCheck.gd"',
        'var net: float = cash - debt',
        'var emits: bool = net >= 2_000_000_000.0 and not already',
        'GameState.get_total_asset_value()', 'GameState.check_game_over()',
        'after == expected', 'emitted == expected_entries',
        'not GameState.is_game_over', 'not target_miss',
        '"exact20": 2_000_000_000.0',
        '_check("net_debt", "cash21_minus_loan2", 2_100_000_000.0, 200_000_000.0, false)',
        'for language: String in LOCALES:',
        'GameState.serialize() == initial_game',
        '_snapshot_properties(LocaleManager, LOCALE_STATE) == locale_snapshot',
    )
    failures = ["runtime milestone consumer/oracle missing " + token
                for token in required if token not in text]
    if 'path="res://tools/WealthMilestoneLogCheck.gd"' not in scene.decode("utf-8") \
            or 'script = ExtResource("1_wealth")' not in scene.decode("utf-8"):
        failures.append("runtime scene does not select milestone consumer")
    return failures


def self_test(after, script, scene):
    cases = 0
    for before, changed in (
        ("total_now >= 2_000_000_000", "total_now >= 1_900_000_000"),
        ('flags["asset_2b_reached"] = true', 'flags["asset_2b_reached"] = false'),
        ("total += float", "total -= float"),
        ("return total - get_loan_total()", "return total + get_loan_total()"),
        (EN, OLD_EN),
    ):
        source = after[GAME].decode("utf-8")
        function = "get_total_asset_value" if before.startswith(("total +=", "return total")) \
            else "check_game_over"
        owner = _gd_function_source(source, function)
        raw = source.replace(owner, owner.replace(before, changed, 1), 1).encode()
        assert raw != after[GAME] and errors({**after, GAME: raw}), "source fact mutation accepted"
        cases += 1
    for locale, path in UI.items():
        current = _loads(after[path])
        del current[KEY]
        assert errors({**after, path: json.dumps(current, ensure_ascii=False).encode()})
        current[KEY] = TARGETS[locale].replace("20", "10", 1)
        assert errors({**after, path: json.dumps(current, ensure_ascii=False).encode()})
        cases += 2
    assert errors({p: raw for p, raw in after.items() if p != GAME})
    cases += 1
    for changed_script, changed_scene in (
        (script.replace(b"GameState.check_game_over()", b"pass", 1), scene),
        (script, scene.replace(b"WealthMilestoneLogCheck.gd", b"ProseRecallCheck.gd", 1)),
    ):
        assert fixture_errors(changed_script, changed_scene), "fixture consumer drift accepted"
        cases += 1
    assert not errors({path: raw + b"\n" for path, raw in after.items()})
    assert not fixture_errors(script + b"\n", scene + b"\n")
    cases += 1
    print("WEALTH_MILESTONE_LOG_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    after = {path: (ROOT / path).read_bytes() for path in (GAME, *UI.values())}
    script, scene = ((ROOT / path).read_bytes() for path in (FIXTURE, SCENE))
    failures = errors(after) + fixture_errors(script, scene)
    for failure in failures:
        print("WEALTH_MILESTONE_LOG_AUDIT_FAIL " + failure)
    if failures:
        return 1
    if args.self_test:
        self_test(after, script, scene)
    print("WEALTH_MILESTONE_LOG_AUDIT_OK locales=5 net_worth=inclusive2b current_log=one_shot")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
