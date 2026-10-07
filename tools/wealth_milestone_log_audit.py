#!/usr/bin/env python3
"""Exact two-literal/three-key milestone repair; not economics or screen approval."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "209b79ec7df4e6e3a2bcc652f3371b1b24d862a5"
SOURCE = "42d30615708ef3344a1cad8af0aad7cebe7e6ca7"
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
FIXTURE_SHA = "cf847aafc8a1c588aeb19da5e40cdb3ddbd76f4c35918cf42848639f4593858f"
SCENE_SHA = "583b1a9701e11143224cd0c6791d0c4e4c541fed7addcd2075c9d050966cc3b9"


def strict_json(raw):
    def pairs(rows):
        value = {}
        for key, item in rows:
            if key in value: raise ValueError("duplicate key")
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def errors(before, after):
    paths = {GAME, *UI.values()}
    if set(before) != paths or set(after) != paths:
        return ["source4 population drift"]
    old = before[GAME]
    failures = []
    if old.count(OLD_KEY.encode()) != 1 or old.count(OLD_EN.encode()) != 1 \
            or after[GAME] != old.replace(OLD_KEY.encode(), KEY.encode()).replace(OLD_EN.encode(), EN.encode()):
        failures.append("GameState exact two literals only: gameplay/neighbor drift")
    for locale, path in UI.items():
        try:
            prior, current = strict_json(before[path]), strict_json(after[path])
            if KEY in prior or current.get(KEY) != TARGETS[locale] or {**prior, KEY: TARGETS[locale]} != current:
                failures.append(path + ": exact first key/value only")
            addition = (json.dumps(KEY, ensure_ascii=False) + ": " + json.dumps(TARGETS[locale], ensure_ascii=False)).encode()
            # Remove one whole member, including its separator; all historic bytes must return.
            lines = after[path].splitlines(True)
            positions = [i for i, line in enumerate(lines) if addition in line]
            if len(positions) != 1:
                failures.append(path + ": raw member population")
            else:
                index = positions[0]
                normalized = list(lines)
                removed = normalized.pop(index)
                if not removed.rstrip().endswith(b",") and index > 0:
                    normalized[index - 1] = normalized[index - 1].replace(b",\n", b"\n")
                if b"".join(normalized) != before[path]:
                    failures.append(path + ": historic raw/order drift")
        except (ValueError, TypeError, KeyError):
            failures.append(path + ": invalid raw dictionary")
    return failures


def fixture_errors(script, scene):
    return [path + ": prepared50 fixture drift" for path, raw, expected in
            ((FIXTURE, script, FIXTURE_SHA), (SCENE, scene, SCENE_SHA))
            if hashlib.sha256(raw).hexdigest() != expected]


def self_test(before, after, script, scene):
    cases = 0
    mutations = [(GAME, before[GAME]), (GAME, after[GAME] + b"\n"),
        (GAME, after[GAME].replace(b"total_now >= 2_000_000_000", b"total_now >= 1_900_000_000", 1)),
        (GAME, after[GAME].replace(b'flags["asset_2b_reached"] = true', b'flags["asset_2b_reached"] = false', 1)),
        (GAME, after[GAME].replace(b"total += float", b"total -= float", 1))]
    for locale, path in UI.items():
        mutations.extend(((path, before[path]), (path, after[path] + b"\n"),
            (path, after[path].replace(TARGETS[locale].encode(), (TARGETS[locale] + "!").encode(), 1))))
    for path, raw in mutations:
        assert raw != after[path], "inert negative"
        assert errors(before, {**after, path: raw}), "mutation accepted " + path
        cases += 1
    assert errors(before, {p: v for p, v in after.items() if p != GAME})
    assert errors(before, {**after, "extra": b""})
    cases += 2
    for changed_script, changed_scene in ((script + b"\n", scene), (script, scene + b"\n"),
            (script.replace(b"GameState.check_game_over()", b"pass", 1), scene),
            (script, scene.replace(b"WealthMilestoneLogCheck.gd", b"ProseRecallCheck.gd", 1))):
        assert fixture_errors(changed_script, changed_scene), "fixture mutation accepted"
        cases += 1
    print("WEALTH_MILESTONE_LOG_SELF_TEST_OK cases=" + str(cases))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    def git(*parts):
        return subprocess.check_output(["git", "--no-replace-objects", *parts], cwd=ROOT)
    if SOURCE is None: raise ValueError("actual source4 is unbound")
    if git("rev-parse", SOURCE + "^").decode().strip() != git("rev-parse", BASE).decode().strip():
        raise ValueError("source direct parent changed")
    paths = {GAME, *UI.values()}
    if set(git("diff", "--name-only", BASE, SOURCE).decode().splitlines()) != paths:
        raise ValueError("source4 global diff changed")
    git("merge-base", "--is-ancestor", SOURCE, "HEAD")
    before = {p: git("show", BASE + ":" + p) for p in paths}
    committed = {p: git("show", SOURCE + ":" + p) for p in paths}
    after = {p: (ROOT / p).read_bytes() for p in paths}
    script, scene = ((ROOT / p).read_bytes() for p in (FIXTURE, SCENE))
    failures = errors(before, committed) + errors(before, after) + fixture_errors(script, scene)
    if after != committed: failures.append("current source4 differs from actual typed commit")
    for failure in failures: print("WEALTH_MILESTONE_LOG_AUDIT_FAIL " + failure)
    if failures: return 1
    if args.self_test: self_test(before, after, script, scene)
    print("WEALTH_MILESTONE_LOG_AUDIT_OK source4=4 literal2=2 new_ui3=3 gameplay_raw=unchanged")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
