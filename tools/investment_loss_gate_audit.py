#!/usr/bin/env python3
"""ORDER-476 source/consumer contract; not a trade, render or release verdict.

The simulator's selected definitions are compiled in isolation: importing its
module would run the whole 240-week program. Runtime outcomes belong to the
separate, pre-autoload-isolated Godot evidence.
"""
from __future__ import annotations

import ast
import copy
import hashlib
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "53b885d66af93532b5c5a3117795be16cbe7e288"
SOURCE = "54bda08d1c0ec1472b3cf1805703f84e1f533428"
MAIN = "scenes/MainGame.gd"
SIM = "tools/arc_flow_sim.py"
SCREEN = "tools/ScreenshotQA.gd"
FIXTURE = "tools/InvestmentLossGateCheck.gd"
FIXTURE_SHA256 = "88e11e6325a6a7c4a48500350c5232720a2d3488cef6de50a771fde2775f5e45"
SCENE_SHA256 = "5bd53f16d18a353390549e93b18cc053329ca4eef2ba82c965a3f97014f51347"
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
EVENT = "arc_invest_first_loss"
FLAGS = ("cut_loss_first", "held_through_loss", "averaged_down")
CALLBACKS = ("callback_cut_loss_first_echo", "callback_held_through_loss_echo", "callback_averaged_down_echo")
CONTENT = tuple("content/events" + ("" if locale == "ko" else "_" + locale) + "/" + filename
                for locale in LOCALES for filename in ("arc_midgame.json", "callback_events_45.json"))
PROTECTED = (*CONTENT, "content/assets.json", "autoloads/GameState.gd",
             "autoloads/DataRegistry.gd", "systems/InvestmentSystem.gd")
INVESTMENT = "systems/InvestmentSystem.gd"
GAME_STATE = "autoloads/GameState.gd"
MIDGAME = {locale: "content/events" + ("" if locale == "ko" else "_" + locale)
           + "/arc_midgame.json" for locale in LOCALES}
OLD_GUARD = '\t\t\tand GameState.investment_skill >= 5 \\\n'
NEW_GUARD = '\t\t\tand GameState.investment_skill >= 5 and _has_current_investment_loss() \\\n'
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
PREPARED = '''if t == 15:
    S.portfolio = {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}
    S.market_prices = {"samsung": 63000.0}
'''
ASSET_LOAD = '''with open("content/assets.json", encoding="utf-8") as asset_file:
    ASSET_IDS = frozenset(row["id"] for row in json.load(asset_file))
'''
SCREEN_OLD = '\t\t"arc_invest_first_loss": 15,\n'
SCREEN_ADDED = '''\t# This input route does not buy a holding. A first loss is optional, and may
\t# only appear in its existing window when the live holding predicate passes.
\tif event_weeks.has("arc_invest_first_loss") \\
\t\t\tand (int(event_weeks["arc_invest_first_loss"]) < 15 \\
\t\t\tor int(event_weeks["arc_invest_first_loss"]) > 18):
\t\treturn "arc_invest_first_loss may only occupy demo weeks 15-18, got %s." % \\
\t\t\t\tevent_weeks["arc_invest_first_loss"]
'''
SCREEN_ANCHOR = '\tif event_weeks.has("arc_job_vs_invest") \\\n'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def source_errors(before, current):
    if type(before) is not bytes or type(current) is not bytes:
        return ["Main raw must be bytes"]
    old, new, helper = OLD_GUARD.encode(), NEW_GUARD.encode(), HELPER.encode()
    if before.count(old) != 1 or before.count(b"func _has_current_investment_loss(") != 0:
        return ["Main predecessor selector population"]
    expected = before.replace(old, new, 1) + helper
    return [] if current == expected else ["Main differs outside exact guard/EOF helper"]


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


def simulator_contract(before, current, asset_rows):
    """Retain the whole historical simulator AST except five explicit additions."""
    tree, old = ast.parse(current), ast.parse(before)
    normalized = copy.deepcopy(tree)
    imports = [n for n in normalized.body if isinstance(n, ast.Import) and any(a.name == "math" for a in n.names)]
    require(len(imports) == 1, "sim math import population")
    imports[0].names = [a for a in imports[0].names if a.name != "math"]
    expected_load = dump(ast.parse(ASSET_LOAD).body[0])
    loads = [n for n in normalized.body if isinstance(n, ast.With) and dump(n) == expected_load]
    require(len(loads) == 1, "sim actual registered asset population")
    normalized.body.remove(loads[0])
    state = one(normalized.body, ast.ClassDef, "State")
    predicate = one(state.body, ast.FunctionDef, "has_current_investment_loss")
    state.body.remove(predicate)
    init = one(state.body, ast.FunctionDef, "__init__")
    for field in ("portfolio", "market_prices"):
        expected = dump(ast.parse("s." + field + " = {}").body[0])
        matches = [n for n in init.body if dump(n) == expected]
        require(len(matches) == 1, "sim empty default " + field)
        init.body.remove(matches[0])
    evaluate = one(normalized.body, ast.FunctionDef, "evalconds")
    entries = []
    for node in ast.walk(evaluate):
        if isinstance(node, ast.Dict):
            for index, key in enumerate(node.keys):
                if isinstance(key, ast.Constant) and key.value == "_has_current_investment_loss":
                    entries.append((node, index))
    require(len(entries) == 1, "sim actual predicate eval binding population")
    mapping, index = entries[0]
    require(dump(mapping.values[index]) == dump(ast.parse("S.has_current_investment_loss", mode="eval").body),
            "sim predicate cannot be an always-true proxy")
    del mapping.keys[index]
    del mapping.values[index]
    prepared = dump(ast.parse(PREPARED).body[0])
    for name in ("traj_A", "traj_B"):
        trajectory = one(normalized.body, ast.FunctionDef, name)
        matches = [n for n in trajectory.body if dump(n) == prepared]
        require(len(matches) == 1, "sim W15 explicit loss holding " + name)
        trajectory.body.remove(matches[0])
    require(dump(normalized) == dump(old), "sim unowned AST/240-week expectations changed")
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


def screen_errors(before, current):
    if before.count(SCREEN_OLD) != 1 or before.count(SCREEN_ANCHOR) != 1:
        return ["ScreenshotQA predecessor selector population"]
    expected = before.replace(SCREEN_OLD, "", 1).replace(SCREEN_ANCHOR, SCREEN_ADDED + SCREEN_ANCHOR, 1)
    return [] if current == expected else ["ScreenshotQA exceeds optional W15-18 expectation repair"]


def historical_content_comparison(current, root=ROOT):
    """Current14 -> pre477 text5/pre478 Investment1/pre480 GameState1."""
    import order470_source_compat as history
    import market_cycle_label_history as market
    import wealth_milestone_log_history as wealth
    root = Path(root).resolve()
    require(type(current) is dict and set(current) == set(PROTECTED)
            and all(type(raw) is bytes for raw in current.values()),
            "protected comparison requires exact current14 bytes")
    require(all((root / path).read_bytes() == raw for path, raw in current.items()),
            "protected comparison supplied raw differs from current disk")
    previous = history.historical_loss_hold_comparison(
        {locale: current[path] for locale, path in MIDGAME.items()}, root)
    require(type(previous) is dict and set(previous) == set(LOCALES)
            and all(type(raw) is bytes for raw in previous.values()),
            "protected comparison predecessor population/type")
    investment = market.market_cycle_predecessor(current[INVESTMENT], root)
    game_state = wealth.game_state_predecessor(current[GAME_STATE], root)
    return {**current, **{path: previous[locale] for locale, path in MIDGAME.items()},
            INVESTMENT: investment, GAME_STATE: game_state}


def content_errors(before, current, *, comparison=None):
    """Historical raw equality and actual-current producer/readers are distinct."""
    failures = []
    compared = current if comparison is None else comparison
    if set(before) != set(PROTECTED) or set(current) != set(PROTECTED) \
            or set(compared) != set(PROTECTED):
        return ["protected source/text population differs"]
    for path in PROTECTED:
        if type(current[path]) is not bytes or type(compared[path]) is not bytes \
                or compared[path] != before[path]:
            failures.append("unowned source/text raw changed: " + path)
        if path == INVESTMENT and comparison is not None:
            # Do not let a supplied historical view hide an arbitrary live
            # price/trading change. The fresh adapter above and this pure exact
            # inverse independently bind the only permitted log/helper delta.
            import market_cycle_label_history as market
            try:
                if market.product_inverse(compared[path], current[path], path) != compared[path]:
                    failures.append("Investment comparison inverse differs")
            except (ValueError, TypeError, KeyError, IndexError):
                failures.append("actual Investment exceeds exact market-label transition")
        elif path == GAME_STATE and comparison is not None:
            # A historical comparison must not conceal a live economy, flag,
            # routing or adjacent-log edit. Only the sealed KO/EN pair differs.
            import wealth_milestone_log_history as wealth
            import asset_one_billion_log_history as one_billion
            try:
                pre_one_billion = one_billion.game_state_inverse(current[path])
                if wealth.product_inverse(compared[path], pre_one_billion, path) != compared[path]:
                    failures.append("GameState comparison inverse differs")
            except (ValueError, TypeError, KeyError, IndexError):
                failures.append("actual GameState exceeds exact wealth-log transition")
        elif path not in MIDGAME.values() and compared[path] != current[path]:
            failures.append("comparison changed a non-midgame protected path: " + path)
    for locale in LOCALES:
        path = "content/events" + ("" if locale == "ko" else "_" + locale) + "/arc_midgame.json"
        rows = [row for row in json.loads(current[path]) if row.get("id") == EVENT]
        if len(rows) != 1 or len(rows[0].get("choices", [])) != 3:
            failures.append(locale + ": exact root/three choices absent")
    root = next(row for row in json.loads(current[CONTENT[0]]) if row.get("id") == EVENT)
    callbacks = {row["id"]: row for row in json.loads(current[CONTENT[1]])}
    for index, flag in enumerate(FLAGS):
        if root["choices"][index]["flags"] != [EVENT + "_seen", flag]:
            failures.append("producer flag changed: " + flag)
        if callbacks[CALLBACKS[index]]["conditions"] != {"flag": flag, "min_turn": 36}:
            failures.append("W36 callback reader changed: " + flag)
    return failures


def fixture_errors(raw):
    """Source wiring only; never substitutes for actual engine case records."""
    text = raw.decode("utf-8")
    failures = []
    if hashlib.sha256(raw).hexdigest() != FIXTURE_SHA256:
        failures.append("runtime fixture differs from reviewed complete consumer/restore source")
    required = ('game.call("_has_current_investment_loss")', 'game.call("_next_arc_id",',
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


def run(root=ROOT):
    import order469_source_compat as history
    root = Path(root).resolve()
    head = history._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    paths = (MAIN, SIM, SCREEN, FIXTURE, FIXTURE.replace(".gd", ".tscn"), *PROTECTED)
    actual, _ = history._snapshot(root, head, paths)
    require(all((root / path).read_bytes() == raw for path, raw in actual.items()), "actual HEAD/disk differs")
    prior, _ = history._snapshot(root, BASE, (MAIN, SIM, SCREEN, *PROTECTED))
    main_before = history.first_loss_predecessor(actual[MAIN], root)
    require(main_before == prior[MAIN], "Main predecessor differs from declaration")
    failures = source_errors(prior[MAIN], actual[MAIN])
    protected = {p: actual[p] for p in PROTECTED}
    comparison = historical_content_comparison(protected, root)
    failures += content_errors({p: prior[p] for p in PROTECTED}, protected, comparison=comparison)
    failures += screen_errors(prior[SCREEN].decode(), actual[SCREEN].decode())
    failures += fixture_errors(actual[FIXTURE])
    if hashlib.sha256(actual[FIXTURE.replace(".gd", ".tscn")]).hexdigest() != SCENE_SHA256:
        failures.append("runtime scene no longer selects reviewed fixture")
    require(not failures, "; ".join(failures))
    cases = simulator_contract(prior[SIM].decode(), actual[SIM].decode(), json.loads(actual["content/assets.json"]))
    final, _ = history._snapshot(root, head, paths)
    require(final == actual and all((root / p).read_bytes() == raw for p, raw in actual.items())
            and history._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
            "source changed during audit")
    require(historical_content_comparison(protected, root) == comparison,
            "historical content comparison changed during audit")
    return {"head": head, "source_commit": SOURCE, "locales": 5, "text_changes": 0,
            "text_changes_scope": "ORDER476 historical comparison only; actual ORDER477 leaf5 retained",
            "historical_comparison": "pre477 exact midgame5 plus pre478 exact Investment1 plus pre480 exact GameState1; actual raw retained",
            "simulator_cases": cases, "protected_paths": len(PROTECTED),
            "scope": "source/predicate/fixture wiring; actual runtime and human observation separate",
            "input_sha256": {p: hashlib.sha256(raw).hexdigest() for p, raw in actual.items()}}


def main():
    try:
        report = run()
    except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError) as exc:
        print("INVESTMENT_LOSS_GATE_AUDIT_FAIL " + str(exc))
        return 1
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    print("INVESTMENT_LOSS_GATE_AUDIT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
