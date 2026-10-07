#!/usr/bin/env python3
"""Exact market display-only source2; not economics or rendered UI approval."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "dfc23a93d8f3c028528dae2405bd63b11e6fac4d"
SOURCE = "20443aa07a5f260ec4b581aaec97c89388004705"
INVESTMENT = "systems/InvestmentSystem.gd"
JA = "locale/ui_ja.json"
FIXTURE = "tools/MarketCycleLogCheck.gd"
SCENE = "tools/MarketCycleLogCheck.tscn"
OLD_ARGUMENT = b'% cycle, "market")\n'
NEW_ARGUMENT = b'% _cycle_display_name(cycle), "market")\n'
APPENDIX = '''
func _cycle_display_name(cycle: String) -> String:
\tmatch cycle:
\t\t"bull":
\t\t\treturn LocaleManager.ui("상승장", "Bull Market")
\t\t"bear":
\t\t\treturn LocaleManager.ui("하락장", "Bear Market")
\t\t"neutral":
\t\t\treturn LocaleManager.ui("횡보장", "Sideways")
\t\t_:
\t\t\treturn cycle
'''.encode()
FIXTURE_SHA = "fef2f2f40f3e7fe643bd8a53211d8c0539eeca95d2412312c8ad244fdf30f2ba"
SCENE_SHA = "8701cdddce0bbb6a23a9d02f521462a6c69f8b1db2ef461e368223a9d9ba792f"

def errors(before, after):
    failures = []
    if set(before) != {INVESTMENT, JA} or set(after) != {INVESTMENT, JA}:
        return ["source2 population drift"]
    old = before[INVESTMENT]
    if old.count(OLD_ARGUMENT) != 1 or after[INVESTMENT] != old.replace(OLD_ARGUMENT, NEW_ARGUMENT) + APPENDIX:
        failures.append("market log argument/pure helper only: unowned/RNG/gameplay bytes drift")
    old_ja = '"횡보장": "横歩場"'.encode()
    new_ja = '"횡보장": "横ばい相場"'.encode()
    if before[JA].count(old_ja) != 1 or after[JA] != before[JA].replace(old_ja, new_ja):
        failures.append("JA neutral exact1 raw value: neighbor/key/order drift")
    return failures

def fixture_errors(script, scene):
    return [label + ": bounded prepared25 fixture drift" for label, raw, expected in
            ((FIXTURE, script, FIXTURE_SHA), (SCENE, scene, SCENE_SHA))
            if hashlib.sha256(raw).hexdigest() != expected]

def self_test(before, after, script, scene):
    mutants = [
        (INVESTMENT, before[INVESTMENT]),
        (INVESTMENT, after[INVESTMENT] + b"\n"),
        (INVESTMENT, after[INVESTMENT].replace(b"randi_range(5, 11)", b"randi_range(5, 12)", 1)),
        (INVESTMENT, after[INVESTMENT].replace(b"var roll = randf()", b"var roll = randf() + randf()", 1)),
        (INVESTMENT, after[INVESTMENT].replace(b'"crash_risk"] = clampf(0.02', b'"crash_risk"] = clampf(0.03', 1)),
        (INVESTMENT, after[INVESTMENT].replace(b"return cycle\n", b'return "Sideways"\n', 1)),
        (INVESTMENT, after[INVESTMENT].replace(b'"bear":\n\t\t\treturn', b'"bull":\n\t\t\treturn', 1)),
        (JA, before[JA]), (JA, after[JA] + b"\n"),
        (JA, after[JA].replace('"횡보": "横歩"'.encode(), '"횡보": "横ばい"'.encode(), 1)),
        (JA, after[JA].replace('"횡보장":'.encode(), '"횡보장2":'.encode(), 1)),
    ]
    for path, raw in mutants:
        assert raw != after[path], "inert negative"
        assert errors(before, {**after, path: raw}), "mutation accepted " + path
    assert errors(before, {INVESTMENT: after[INVESTMENT]}), "missing population accepted"
    assert errors(before, {**after, "extra": b""}), "extra population accepted"
    for changed_script, changed_scene in ((script + b"\n", scene), (script, scene + b"\n"),
                                          (script.replace(b'investment.call("_roll_cycle")', b'pass', 1), scene),
                                          (script, scene.replace(b"MarketCycleLogCheck.gd", b"ProseRecallCheck.gd", 1))):
        assert fixture_errors(changed_script, changed_scene), "fixture mutation accepted"
    print("MARKET_CYCLE_LOG_SELF_TEST_OK cases=17")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    def git(*parts):
        return subprocess.check_output(["git", "--no-replace-objects", *parts], cwd=ROOT)
    if git("rev-parse", SOURCE + "^").decode().strip() != BASE:
        raise ValueError("source direct parent changed")
    if set(git("diff", "--name-only", BASE, SOURCE).decode().splitlines()) != {INVESTMENT, JA}:
        raise ValueError("source2 global diff changed")
    git("merge-base", "--is-ancestor", SOURCE, "HEAD")
    before = {p: git("show", BASE + ":" + p) for p in (INVESTMENT, JA)}
    committed = {p: git("show", SOURCE + ":" + p) for p in (INVESTMENT, JA)}
    after = {p: (ROOT / p).read_bytes() for p in (INVESTMENT, JA)}
    script, scene = ((ROOT / p).read_bytes() for p in (FIXTURE, SCENE))
    failures = errors(before, committed) + errors(before, after) + fixture_errors(script, scene)
    if after != committed: failures.append("actual current source2 differs from reviewed typed commit")
    for failure in failures: print("MARKET_CYCLE_LOG_AUDIT_FAIL " + failure)
    if failures: return 1
    if args.self_test: self_test(before, after, script, scene)
    print("MARKET_CYCLE_LOG_AUDIT_OK source2=2 ja_values=1 gameplay_rng_raw=unchanged")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
