#!/usr/bin/env python3
"""Targeted fail-closed controls; no engine or full-history suite execution."""
from __future__ import annotations

import json
from dataclasses import replace
from unittest import mock

import investment_loss_gate_audit as audit


def run(root=audit.ROOT):
    import order469_source_compat as history
    root = root.resolve()
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError):
            check(True, label)
        else:
            check(False, label)

    paths = (audit.MAIN, audit.SIM, audit.SCREEN, *audit.PROTECTED)
    before, _ = history._snapshot(root, audit.BASE, paths)
    current = {path: (root / path).read_bytes() for path in paths}
    check(not audit.source_errors(before[audit.MAIN], current[audit.MAIN]), "actual exact Main delta")
    mutations = (
        ("missing guard", audit.NEW_GUARD, audit.OLD_GUARD),
        ("wrong guard polarity", "and _has_current_investment_loss()", "and not _has_current_investment_loss()"),
        ("unregistered allowed", "if DataRegistry.get_asset(asset_id).is_empty():", "if false:"),
        ("missing quote fallback", "GameState.market_prices[asset_id]", 'GameState.market_prices.get(asset_id, 1.0)'),
        ("quantity omitted", "[quantity, average, price]", "[average, price]"),
        ("bool accepted", "typeof(value) != TYPE_INT", "typeof(value) != TYPE_BOOL"),
        ("nonfinite accepted", "not is_finite(float(value))", "false"),
        ("zero accepted", "float(value) <= 0.0", "float(value) < 0.0"),
        ("break even accepted", "float(price) < float(average)", "float(price) <= float(average)"),
        ("price reversed", "float(price) < float(average)", "float(price) > float(average)"),
        ("window widened", "if t >= 15 and t <= 18", "if t >= 14 and t <= 18"),
        ("skill weakened", "GameState.investment_skill >= 5 and", "GameState.investment_skill >= 4 and"),
        ("UI modified", 'return _tr("칭호", "Title")', 'return _tr("칭호", "Titles")'),
    )
    for label, old, new in mutations:
        raw = current[audit.MAIN]
        require_present = old.encode() in raw
        check(require_present and bool(audit.source_errors(before[audit.MAIN], raw.replace(old.encode(), new.encode(), 1))),
              "Main rejects " + label)
    for label, raw in (("rollback", before[audit.MAIN]), ("unowned newline", current[audit.MAIN] + b"\n"),
                       ("nonbytes", current[audit.MAIN].decode())):
        check(bool(audit.source_errors(before[audit.MAIN], raw)), "Main rejects " + label)

    old_protected = {p: before[p] for p in audit.PROTECTED}
    protected = {p: current[p] for p in audit.PROTECTED}
    check(not audit.content_errors(old_protected, protected), "actual text5/API source unchanged")
    for path in audit.PROTECTED:
        mutant = {**protected, path: protected[path] + b"\n"}
        check(bool(audit.content_errors(old_protected, mutant)), "outside raw " + path)
    mutant = dict(protected)
    del mutant[audit.PROTECTED[0]]
    check(bool(audit.content_errors(old_protected, mutant)), "missing protected path")

    assets = json.loads(current["content/assets.json"])
    old_sim, sim = before[audit.SIM].decode(), current[audit.SIM].decode()
    check(audit.simulator_contract(old_sim, sim, assets) == len(audit.numeric_cases()) + 2,
          "actual simulator numeric/evaluator/trajectory cases")
    for label, old, new in (
        ("constant helper", 'for asset_id, holding in s.portfolio.items():',
         'return True\n        for asset_id, holding in s.portfolio.items():'),
        ("constant evaluator", '"_has_current_investment_loss": S.has_current_investment_loss',
         '"_has_current_investment_loss": lambda: True'),
        ("wrong quote", 'S.market_prices = {"samsung": 63000.0}', 'S.market_prices = {"samsung": 70000.0}'),
        ("premature preparation", 'if t == 15:', 'if t == 14:'),
        ("lost 240-week expectation", '15: "arc_invest_first_loss"', '15: "not_the_loss"'),
        ("break even", 'values[2] < values[1]', 'values[2] <= values[1]'),
        ("bool", 'type(value) in (int, float)', 'isinstance(value, (int, float))'),
        ("nonfinite", 'math.isfinite(value)', 'True'),
        ("missing registry", 'asset_id not in ASSET_IDS', 'False'),
        ("mutating helper", 'for asset_id, holding in s.portfolio.items():',
         's.flags["audit_mutation"] = True\n        for asset_id, holding in s.portfolio.items():'),
    ):
        check(old in sim, "sim mutation precondition " + label)
        reject(lambda old=old, new=new: audit.simulator_contract(old_sim, sim.replace(old, new, 1), assets),
               "sim rejects " + label)
    check(not audit.screen_errors(before[audit.SCREEN].decode(), current[audit.SCREEN].decode()),
          "actual optional screenshot expectation")
    for label, text in (("rollback", before[audit.SCREEN].decode()),
                         ("window", current[audit.SCREEN].decode().replace('< 15 \\', '< 14 \\', 1)),
                         ("neighbor", current[audit.SCREEN].decode() + "\n")):
        check(bool(audit.screen_errors(before[audit.SCREEN].decode(), text)), "screen rejects " + label)

    fixture = (root / audit.FIXTURE).read_bytes()
    check(not audit.fixture_errors(fixture), "actual reviewed runtime wiring and helper oracle")
    for old, new in ((b'actual == expected', b'true'),
                     (b'game.call("_has_current_investment_loss")', b'true'),
                     (b'game.call("_next_arc_id",', b'game.call("_wrong_route",'),
                     (b'if not restored:', b'if false:'),
                     (b'"expected": false', b'"expected": true')):
        check(old in fixture and bool(audit.fixture_errors(fixture.replace(old, new, 1))),
              "fixture rejects " + old.decode())

    # One real current proof precedes isolated coordinate counterexamples. The
    # patched comparison bytes below are explicitly NOT additional Git proofs.
    previous = history.first_loss_predecessor(current[audit.MAIN], root)
    check(previous == before[audit.MAIN], "actual fresh current Main transition")
    import ja_translation_pipeline as pipeline
    pre469, _ = history._snapshot(root, history.PRODUCT_PARENT, (audit.MAIN,))
    calls, errors = pipeline.parse_ui_calls(audit.MAIN, current[audit.MAIN].decode())
    old_calls, old_errors = pipeline.parse_ui_calls(audit.MAIN, pre469[audit.MAIN].decode())
    key = lambda c: (c.path, c.line, c.api)
    calls, old_calls = tuple(sorted(calls, key=key)), tuple(sorted(old_calls, key=key))
    check(not errors and not old_errors and bool(calls), "actual UI parsers")
    with mock.patch.object(history, "first_loss_predecessor", return_value=previous):
        pipeline._chapter_four_call_offsets(pre469[audit.MAIN], current[audit.MAIN], old_calls, calls)
        check(True, "old minus-eight proof and current exact coordinates")
        for field, value in (("line", calls[-1].line + 1), ("english", calls[-1].english + " drift"),
                             ("korean", calls[-1].korean + " 변조"), ("function", "forged_owner")):
            forged = (*calls[:-1], replace(calls[-1], **{field: value}))
            reject(lambda row=forged: pipeline._chapter_four_call_offsets(
                pre469[audit.MAIN], current[audit.MAIN], old_calls, row), "JA tuple " + field)
        for label, rows in (("missing", calls[:-1]), ("duplicate", (*calls, calls[-1])),
                             ("reordered", tuple(reversed(calls)))):
            reject(lambda row=rows: pipeline._chapter_four_call_offsets(
                pre469[audit.MAIN], current[audit.MAIN], old_calls, row), "JA calls " + label)
    code = (root / "tools/ja_translation_pipeline.py").read_bytes()
    prefix = pipeline.first_loss_pipeline_predecessor(code)
    check(prefix == history._git(root, "show", audit.SOURCE + ":tools/ja_translation_pipeline.py"),
          "actual sealed JA whole predecessor")
    for label, raw in (("suffix", code + b"\n"), ("prefix", b" " + code),
                       ("appendix", code.replace(b"first-loss UI calls/payload/order/exact coordinates differ",
                                                b"weakened diagnostic", 1))):
        reject(lambda value=raw: pipeline.first_loss_pipeline_predecessor(value), "JA seal " + label)
    check({p: (root / p).read_bytes() for p in paths} == current
          and (root / audit.FIXTURE).read_bytes() == fixture
          and (root / "tools/ja_translation_pipeline.py").read_bytes() == code,
          "test input raw preserved")
    return failures, cases


def main():
    try:
        failures, cases = run()
    except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError) as exc:
        print("INVESTMENT_LOSS_GATE_SELF_TEST_FAIL " + str(exc))
        return 1
    for failure in failures:
        print("INVESTMENT_LOSS_GATE_SELF_TEST_FAIL " + failure)
    print(f"INVESTMENT_LOSS_GATE_SELF_TEST_{'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
