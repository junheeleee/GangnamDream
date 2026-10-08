#!/usr/bin/env python3
"""Current investment-loss source/consumer facts; not a trade or release verdict.

The simulator's selected definitions are compiled in isolation: importing its
module would run the whole 240-week program. Runtime outcomes belong to the
separate, pre-autoload-isolated Godot evidence.
"""
from __future__ import annotations

import ast
import copy
import json
import argparse
import math
import re
from pathlib import Path

from ui_translation_append import _loads
from ja_translation_pipeline import _gd_function_source

ROOT = Path(__file__).resolve().parents[1]
MAIN = "scenes/MainGame.gd"
SIM = "tools/arc_flow_sim.py"
SCREEN = "tools/ScreenshotQA.gd"
FIXTURE = "tools/InvestmentLossGateCheck.gd"
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
EVENT = "arc_invest_first_loss"
FLAGS = ("cut_loss_first", "held_through_loss", "averaged_down")
CALLBACKS = ("callback_cut_loss_first_echo", "callback_held_through_loss_echo", "callback_averaged_down_echo")
CONTENT = tuple("content/events" + ("" if locale == "ko" else "_" + locale) + "/" + filename
                for locale in LOCALES for filename in ("arc_midgame.json", "callback_events_45.json"))
PROTECTED = (*CONTENT, "content/assets.json", "autoloads/DataRegistry.gd")
MIDGAME = {locale: "content/events" + ("" if locale == "ko" else "_" + locale)
           + "/arc_midgame.json" for locale in LOCALES}
HELPER = '''
func _has_current_investment_loss() -> bool:
\t# Read the live holding and quote only; experience or an old loss is not enough.
\tfor asset_id in GameState.portfolio:
\t\tif DataRegistry.get_asset(asset_id).is_empty():
\t\t\tcontinue
\t\tvar holding: Variant = GameState.portfolio[asset_id]
\t\tif not holding is Dictionary or not GameState.market_prices.has(asset_id):
\t\t\tcontinue
\t\tvar quantity: Variant = holding.get("quantity", null)
\t\tvar average: Variant = holding.get("avg_price", null)
\t\tvar price: Variant = GameState.market_prices[asset_id]
\t\tvar valid := true
\t\tfor value in [quantity, average, price]:
\t\t\tif (typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT):
\t\t\t\tvalid = false
\t\t\t\tbreak
\t\t\tif not is_finite(float(value)) or float(value) <= 0.0:
\t\t\t\tvalid = false
\t\t\t\tbreak
\t\tif valid and float(price) < float(average):
\t\t\treturn true
\treturn false
'''
ASSET_LOAD = '''with open("content/assets.json", encoding="utf-8") as asset_file:
    ASSET_IDS = frozenset(row["id"] for row in json.load(asset_file))
'''
def require(ok, message):
    if not ok:
        raise ValueError(message)


def statements(source):
    return "\n".join(line.split("#", 1)[0].strip() for line in source.splitlines()
                     if line.split("#", 1)[0].strip())


def source_errors(current):
    if type(current) is not bytes:
        return ["Main source must be bytes"]
    source = current.decode("utf-8")
    failures = []
    helper = _gd_function_source(source, "_has_current_investment_loss")
    if statements(helper) != statements(HELPER):
        failures.append("live holding/registered asset/finite positive quote predicate differs")
    owner = _gd_function_source(source, "_next_arc_id")
    compact = re.sub(r"\s+|\\", "", owner)
    guard = (
        'ift>=15andt<=18andf.get("arc_invest_guidance_seen",false)'
        'andGameState.investment_skill>=5and_has_current_investment_loss()'
        'andnotf.get("arc_invest_first_loss_seen",false):return"arc_invest_first_loss"'
    )
    if compact.count(guard) != 1 or owner.count('return "arc_invest_first_loss"') != 1:
        failures.append("current loss window/guidance/skill/live-loss/seen routing differs")
    return failures


def dump(node):
    return ast.dump(node, include_attributes=False)


def one(nodes, kind, name):
    found = [node for node in nodes if isinstance(node, kind) and getattr(node, "name", None) == name]
    require(len(found) == 1, "expected exactly one " + name)
    return found[0]


def numeric_cases():
    """Concrete holdings, not experience/nav proxies; every expected is explicit."""
    def held(quantity=1.0, average=100.0, price=90.0):
        return {"samsung": {"quantity": quantity, "avg_price": average}}, {"samsung": price}
    cases = [("empty", {}, {}, False), ("sold", {}, {"samsung": 90.0}, False)]
    for label, q, a, p, expected in (
            ("integer loss", 1, 100, 99, True), ("break even", 1, 100, 100, False),
            ("profit", 1, 100, 101, False), ("fractional quantity", 0.000001, 100, 99, True),
            ("fractional price loss", 1, 0.002, 0.001, True),
            ("tiny relative loss", 1, 1.0, math.nextafter(1.0, 0.0), True),
            ("large finite values", 1e308, 1e308, 1e307, True)):
        portfolio, prices = held(q, a, p)
        cases.append((label, portfolio, prices, expected))
    for field in ("quantity", "avg_price", "price"):
        for label, value in (("missing", None), ("bool true", True), ("bool false", False),
                             ("string", "1"), ("zero", 0), ("negative", -1),
                             ("nan", float("nan")), ("inf", float("inf")),
                             ("negative inf", -float("inf")), ("array", []), ("dict", {})):
            portfolio, prices = held()
            if field == "price":
                if value is None:
                    prices.clear()
                else:
                    prices["samsung"] = value
            elif value is None:
                del portfolio["samsung"][field]
            else:
                portfolio["samsung"][field] = value
            cases.append((field + ":" + label, portfolio, prices, False))
    for malformed in (None, [], 1, "holding", True):
        cases.append(("non-Dictionary:" + repr(malformed), {"samsung": malformed}, {"samsung": 90}, False))
    cases.extend((
        ("unregistered", {"not_a_registered_asset": {"quantity": 1, "avg_price": 100}},
         {"not_a_registered_asset": 90}, False),
        ("mixed not netted", {"samsung": {"quantity": 1, "avg_price": 100},
                             "nvidia": {"quantity": 100, "avg_price": 1}},
         {"samsung": 99, "nvidia": 1000}, True),
        ("invalid then loss", {"nvidia": None, "samsung": {"quantity": 1, "avg_price": 100}},
         {"nvidia": 1, "samsung": 99}, True),
    ))
    return cases


def simulator_contract(current, asset_rows):
    """Execute only current selected definitions, never the 240-week program."""
    tree = ast.parse(current)
    state = one(tree.body, ast.ClassDef, "State")
    one(state.body, ast.FunctionDef, "has_current_investment_loss")
    evaluate = one(tree.body, ast.FunctionDef, "evalconds")
    entries = []
    for node in ast.walk(evaluate):
        if isinstance(node, ast.Dict):
            for index, key in enumerate(node.keys):
                if isinstance(key, ast.Constant) and key.value == "_has_current_investment_loss":
                    entries.append((node, index))
    require(len(entries) == 1, "current predicate evaluator binding population")
    mapping, index = entries[0]
    require(dump(mapping.values[index]) == dump(ast.parse("S.has_current_investment_loss", mode="eval").body),
            "predicate evaluator cannot be an always-true proxy")
    require(any(isinstance(node, ast.With) and dump(node) == dump(ast.parse(ASSET_LOAD).body[0])
                for node in tree.body), "current asset registry loader absent")
    selected = [one(tree.body, ast.ClassDef, "Job"), one(tree.body, ast.ClassDef, "State")]
    selected += [one(tree.body, ast.FunctionDef, name) for name in (
        "evalconds", "traj_A", "traj_B", "father_death_is_monotonic", "chapter5_finale_holds_ending")]
    env = {"math": math, "re": re, "ASSET_IDS": frozenset(row["id"] for row in asset_rows)}
    exec(compile(ast.Module(body=selected, type_ignores=[]), SIM + ":isolated-definitions", "exec"), env)
    require({"samsung", "nvidia"} <= env["ASSET_IDS"], "prepared registered IDs absent")
    tested = 0
    for label, portfolio, prices, expected in numeric_cases():
        state = env["State"]()
        state.portfolio, state.market_prices = copy.deepcopy(portfolio), copy.deepcopy(prices)
        snapshot = repr(state.__dict__)
        require(state.has_current_investment_loss() is expected, "sim numeric " + label)
        require(env["evalconds"](["_has_current_investment_loss()"], state) is expected,
                "sim actual evaluator " + label)
        require(repr(state.__dict__) == snapshot, "sim predicate mutates " + label)
        tested += 1
    for name in ("traj_A", "traj_B"):
        state = env["State"]()
        require(state.portfolio == state.market_prices == {}, "sim defaults invent holding")
        state.t = 14
        env[name](state)
        require(not state.has_current_investment_loss(), name + " premature preparation")
        state.t = 15
        env[name](state)
        require(state.has_current_investment_loss(), name + " prepared loss missing")
        state.market_prices["samsung"] = 70000.0
        require(not state.has_current_investment_loss(), name + " stale price result")
        tested += 1
    return tested


def screen_errors(current):
    owner = _gd_function_source(current, "_demo_scene_flow_error")
    compact = re.sub(r"\s+|\\", "", owner)
    # Retain the optional reached-window condition, not the complete QA file.
    condition = (
        'ifevent_weeks.has("arc_invest_first_loss")'
        'and(int(event_weeks["arc_invest_first_loss"])<15'
        'orint(event_weeks["arc_invest_first_loss"])>18):'
    )
    if compact.count(condition) != 1 or '"arc_invest_first_loss":15' in compact:
        return ["current screenshot loss expectation must be optional and inside weeks15-18"]
    return []


def content_errors(current):
    failures = []
    if set(current) != set(PROTECTED):
        return ["current loss event/callback/asset/reader inputs absent"]
    documents = {path: _loads(raw) for path, raw in current.items() if path.endswith(".json")}
    for locale in LOCALES:
        rows = [row for row in documents[MIDGAME[locale]] if row.get("id") == EVENT]
        if len(rows) != 1 or len(rows[0].get("choices", [])) != 3:
            failures.append(locale + ": one current loss root/three choices required")
    root = next(row for row in documents[MIDGAME["ko"]] if row.get("id") == EVENT)
    callbacks = {row["id"]: row for row in documents[CONTENT[1]]}
    expected_effects = (
        {"money": -100000, "mental": 3, "investment_skill": 2},
        {"investment_skill": 3, "mental": -3},
        {"money": -200000, "investment_skill": 1, "mental": -2},
    )
    for index, flag in enumerate(FLAGS):
        choice = root["choices"][index]
        effects = choice.get("effects", {})
        if choice.get("flags") != [EVENT + "_seen", flag] \
                or effects != expected_effects[index] \
                or any(type(value) not in (int, float) for value in effects.values()):
            failures.append("typed cost/effect/flag producer differs: " + flag)
        reader = callbacks.get(CALLBACKS[index], {})
        if reader.get("conditions") != {"flag": flag, "min_turn": 36} \
                or type(reader.get("conditions", {}).get("min_turn")) not in (int, float):
            failures.append("W36 callback reader differs: " + flag)
    assets = documents["content/assets.json"]
    ids = [row["id"] for row in assets]
    if len(ids) != len(set(ids)) or not {"samsung", "nvidia"} <= set(ids):
        failures.append("current prepared holding IDs are not unique registered assets")
    registry_source = current["autoloads/DataRegistry.gd"].decode()
    registry = _gd_function_source(registry_source, "get_asset")
    if statements(registry) != 'func get_asset(asset_id):\nreturn assets_by_id.get(asset_id, {})':
        failures.append("current registered asset reader differs")
    loader = statements(_gd_function_source(registry_source, "reload"))
    if 'assets = _load_array(ASSETS_PATH)' not in loader \
            or 'assets_by_id = _index_by_id(assets)' not in loader:
        failures.append("current registered asset reader is not loaded from actual assets")
    return failures


def fixture_errors(raw):
    """Source wiring only; never substitutes for actual engine case records."""
    text = raw.decode("utf-8")
    failures = []
    required = ('actual == expected', 'game.call("_has_current_investment_loss")', 'game.call("_next_arc_id",',
                'const INVESTMENT := preload("res://systems/InvestmentSystem.gd")',
                'var investment: Node = INVESTMENT.new()', 'investment.free()',
                'investment.buy_asset("samsung", 140000.0)',
                'investment.sell_asset("samsung", 0.5)',
                'investment.sell_asset("samsung", 1.0)',
                'GameState.apply_choice(event, event["choices"][index])',
                '_loss_prepare(15)', 'GameState.turn = turn', '"prepared_choice_turn": 15',
                'EventManager.call("_check_conditions", callback.get("conditions", {}))',
                'actual == (retained and turn >= 36) and _state_bytes() == before',
                'var_to_bytes(GameState.portfolio) == holdings_before',
                'var_to_bytes(GameState.market_prices) == prices_before',
                'if not restored: failures.append("singleton restoration failed")',
                'INVESTMENT_LOSS_GATE_CHECK_OK locales=5 cases=430')
    failures += ["runtime fixture missing actual consumer/oracle " + token for token in required if token not in text]
    helper_case = _gd_function_source(text, "_helper_case")
    if 'var actual: bool = game.call("_has_current_investment_loss")' not in helper_case \
            or 'actual == expected and _state_bytes() == before' not in helper_case:
        failures.append("current helper case lost its actual predicate/immutable-state oracle")
    routes = _gd_function_source(text, "_loss_routes")
    if 'game.call("_next_arc_id", row["turn"], preview, false)' not in routes:
        failures.append("current route case no longer calls the actual live owner")
    match = re.search(r'func _loss_helpers\(game: Node\).*?var rows := (\[.*?\n\t\])', text, re.S)
    if not match:
        return [*failures, "runtime helper rows absent"]
    rows = ast.literal_eval(re.sub(r'\b(false|true|null)\b',
                                  lambda m: {"false": "False", "true": "True", "null": "None"}[m[0]],
                                  match[1]))
    if len(rows) != 15 or len({row["id"] for row in rows}) != 15:
        failures.append("runtime helper named population differs")
    for row in rows:
        actual = False
        for asset_id, holding in row["holdings"].items():
            if asset_id not in {"samsung", "nvidia"} or type(holding) is not dict:
                continue
            values = (holding.get("quantity"), holding.get("avg_price"), row["prices"].get(asset_id))
            if all(type(v) in (int, float) and math.isfinite(v) and v > 0 for v in values):
                actual |= values[2] < values[1]
        if row["expected"] is not actual:
            failures.append("runtime helper numeric oracle differs: " + row["id"])
    if 'var invalid := [null, 0, -1, "1", true, NAN, INF, -INF, []]' not in text \
            or 'for field: String in ["quantity", "avg_price", "price"]:' not in text:
        failures.append("runtime nine invalid values across three fields changed")
    return failures


def current_inputs(root=ROOT):
    paths = (MAIN, SIM, SCREEN, FIXTURE, FIXTURE.replace(".gd", ".tscn"), *PROTECTED)
    return {path: (Path(root) / path).read_bytes() for path in paths}


def run(root=ROOT):
    actual = current_inputs(root)
    failures = source_errors(actual[MAIN])
    failures += content_errors({path: actual[path] for path in PROTECTED})
    failures += screen_errors(actual[SCREEN].decode())
    failures += fixture_errors(actual[FIXTURE])
    if 'path="res://tools/InvestmentLossGateCheck.gd"' not in actual[FIXTURE.replace(".gd", ".tscn")].decode():
        failures.append("runtime scene no longer selects the loss-gate consumer")
    require(not failures, "; ".join(failures))
    cases = simulator_contract(actual[SIM].decode(), _loads(actual["content/assets.json"]))
    return {"locales": 5, "simulator_cases": cases,
            "scope": "current source/predicate/fixture wiring; runtime and human observation separate"}


def self_test(root=ROOT):
    current = current_inputs(root)
    failures, cases = [], 0
    def check(condition, label):
        nonlocal cases
        cases += 1
        if not condition:
            failures.append(label)
    def reject(operation, label):
        try:
            operation()
        except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError):
            check(True, label)
        else:
            check(False, label)
    check(not source_errors(current[MAIN]), "current Main semantics")
    for label, old, new in (
        ("missing live guard", "and _has_current_investment_loss()", ""),
        ("wrong polarity", "and _has_current_investment_loss()", "and not _has_current_investment_loss()"),
        ("unregistered asset", "if DataRegistry.get_asset(asset_id).is_empty():", "if false:"),
        ("missing quote", "GameState.market_prices[asset_id]", 'GameState.market_prices.get(asset_id, 1.0)'),
        ("quantity omitted", "[quantity, average, price]", "[average, price]"),
        ("boolean accepted", "typeof(value) != TYPE_INT", "typeof(value) != TYPE_BOOL"),
        ("nonfinite accepted", "not is_finite(float(value))", "false"),
        ("zero accepted", "float(value) <= 0.0", "float(value) < 0.0"),
        ("break even accepted", "float(price) < float(average)", "float(price) <= float(average)"),
        ("price reversed", "float(price) < float(average)", "float(price) > float(average)"),
        ("window widened", "if t >= 15 and t <= 18", "if t >= 14 and t <= 18"),
        ("skill weakened", "GameState.investment_skill >= 5 and", "GameState.investment_skill >= 4 and"),
    ):
        raw = current[MAIN]
        check(old.encode() in raw and bool(source_errors(raw.replace(old.encode(), new.encode(), 1))),
              "Main rejects " + label)
    check(not source_errors(current[MAIN] + b"\n"), "Main unrelated whitespace accepted")
    protected = {path: current[path] for path in PROTECTED}
    check(not content_errors(protected), "current producers and callback readers")
    rows = _loads(protected[MIDGAME["ko"]])
    for index in range(3):
        changed = copy.deepcopy(rows)
        mutant = next(row for row in changed if row["id"] == EVENT)
        mutant["choices"][index]["flags"] = ["wrong_flag"]
        check(bool(content_errors({**protected, MIDGAME["ko"]: json.dumps(changed).encode()})),
              "producer flag " + FLAGS[index])
    changed = copy.deepcopy(rows)
    event = next(row for row in changed if row["id"] == EVENT)
    event["choices"][0]["effects"]["money"] = True
    check(bool(content_errors({**protected, MIDGAME["ko"]: json.dumps(changed).encode()})),
          "producer cost must remain numeric and not boolean")
    callback_rows = _loads(protected[CONTENT[1]])
    next(row for row in callback_rows if row["id"] == CALLBACKS[0])["conditions"]["min_turn"] = True
    check(bool(content_errors({**protected, CONTENT[1]: json.dumps(callback_rows).encode()})),
          "callback turn must remain numeric and not boolean")
    registry_path = "autoloads/DataRegistry.gd"
    for before, changed in ((b"assets = _load_array(ASSETS_PATH)", b"assets = []"),
                            (b"assets_by_id = _index_by_id(assets)", b"assets_by_id = {}")):
        raw = protected[registry_path]
        check(before in raw and bool(content_errors({**protected, registry_path: raw.replace(before, changed, 1)})),
              "registered asset loader cannot be bypassed")
    assets = _loads(current["content/assets.json"])
    sim = current[SIM].decode()
    check(simulator_contract(sim, assets) == len(numeric_cases()) + 2, "current numeric/evaluator/trajectory cases")
    for label, old, new in (
        ("constant helper", "for asset_id, holding in s.portfolio.items():",
         "return True\n        for asset_id, holding in s.portfolio.items():"),
        ("constant evaluator", '"_has_current_investment_loss": S.has_current_investment_loss',
         '"_has_current_investment_loss": lambda: True'),
        ("wrong quote", 'S.market_prices = {"samsung": 63000.0}', 'S.market_prices = {"samsung": 70000.0}'),
        ("premature preparation", "if t == 15:", "if t == 14:"),
        ("break even", "values[2] < values[1]", "values[2] <= values[1]"),
        ("boolean", "type(value) in (int, float)", "isinstance(value, (int, float))"),
        ("nonfinite", "math.isfinite(value)", "True"),
        ("registry bypass", "asset_id not in ASSET_IDS", "False"),
        ("mutating helper", "for asset_id, holding in s.portfolio.items():",
         's.flags["audit_mutation"] = True\n        for asset_id, holding in s.portfolio.items():'),
    ):
        check(old in sim, "sim mutation precondition " + label)
        reject(lambda old=old, new=new: simulator_contract(sim.replace(old, new, 1), assets),
               "sim rejects " + label)
    screen = current[SCREEN].decode()
    check(not screen_errors(screen), "current optional screenshot expectation")
    check(bool(screen_errors(screen.replace('< 15 \\', '< 14 \\', 1))), "screenshot narrowed lower window")
    check(not screen_errors(screen + "\n"), "screen unrelated whitespace accepted")
    fixture = current[FIXTURE]
    check(not fixture_errors(fixture), "current fixture consumer wiring/oracle")
    for old, new in ((b"actual == expected", b"true"),
                     (b'game.call("_has_current_investment_loss")', b"true"),
                     (b'game.call("_next_arc_id",', b'game.call("_wrong_route",'),
                     (b"if not restored:", b"if false:"),
                     (b'"expected": false', b'"expected": true')):
        check(old in fixture and bool(fixture_errors(fixture.replace(old, new, 1))),
              "fixture rejects " + old.decode())
    return failures, cases


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        report = run()
        if args.self_test:
            failures, cases = self_test()
            require(not failures, "; ".join(failures))
            print("INVESTMENT_LOSS_GATE_SELF_TEST_OK cases=" + str(cases))
    except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError) as exc:
        print("INVESTMENT_LOSS_GATE_AUDIT_FAIL " + str(exc))
        return 1
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    print("INVESTMENT_LOSS_GATE_AUDIT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
