#!/usr/bin/env python3
"""Targeted fail-closed controls; no engine or full-history suite execution."""
from __future__ import annotations

import argparse
import json
from dataclasses import replace
from pathlib import Path
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
    actual_protected = {p: current[p] for p in audit.PROTECTED}
    protected = audit.historical_content_comparison(actual_protected, root)
    check(not audit.content_errors(old_protected, actual_protected, comparison=protected),
          "historical text5/API unchanged; actual current producer/readers")
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
    prefix = pipeline.first_loss_pipeline_predecessor(pipeline.market_cycle_pipeline_predecessor(code))
    check(prefix == history._git(root, "show", audit.SOURCE + ":tools/ja_translation_pipeline.py"),
          "actual sealed JA whole predecessor")
    for label, raw in (("suffix", code + b"\n"), ("prefix", b" " + code),
                       ("appendix", code.replace(b"first-loss UI calls/payload/order/exact coordinates differ",
                                                b"weakened diagnostic", 1))):
        reject(lambda value=raw: pipeline.first_loss_pipeline_predecessor(
            pipeline.market_cycle_pipeline_predecessor(value)), "JA seal " + label)
    check({p: (root / p).read_bytes() for p in paths} == current
          and (root / audit.FIXTURE).read_bytes() == fixture
          and (root / "tools/ja_translation_pipeline.py").read_bytes() == code,
          "test input raw preserved")
    return failures, cases


def run_loss_hold_only(root=audit.ROOT):
    """477 connector controls only; no old Main/UI/simulator/engine suite."""
    import order469_source_compat as history
    import order470_source_compat as current_history
    import night_routine_time_audit as night
    root = Path(root).resolve()
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

    def locale_view(raw):
        return {locale: raw[path] for locale, path in audit.MIDGAME.items()}

    def change_leaf(raw, index, suffix):
        document = night._Document(raw)
        indices = [i for i, row in enumerate(document.value) if row.get("id") == audit.EVENT]
        audit.require(len(indices) == 1, "counterexample exact loss event")
        i = indices[0]
        key = (i, "choices", index, "result_text")
        start, end = document.spans[key]
        value = document.value[i]["choices"][index]["result_text"]
        return (document.text[:start] + json.dumps(value + suffix, ensure_ascii=False)
                + document.text[end:]).encode()

    head = history._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    actual, _ = history._snapshot(root, head, audit.PROTECTED)
    before, _ = history._snapshot(root, audit.BASE, audit.PROTECTED)
    night_before, _ = history._snapshot(root, night.BASE, tuple(audit.MIDGAME.values()))
    inputs = {p: (root / p).read_bytes() for p in audit.PROTECTED}
    audit.require(inputs == actual, "connector actual HEAD/disk binding")
    with current_history.fresh_validation_proof(root):
        compared = audit.historical_content_comparison(actual, root)
        night_compared = night.historical_comparison(locale_view(actual), root)
        check(compared == before, "actual current14 -> immutable pre477 comparison")
        check(night_compared == locale_view(compared), "both adapters share exact pre477 five")
        check(not audit.content_errors(before, actual, comparison=compared),
              "current producers/readers with proven historical raw")
        check(not night.errors(locale_view(night_before), night_compared),
              "old475 exact chronology remains unchanged")
        check(all(actual[p] != compared[p] for p in audit.MIDGAME.values()),
              "all five actual corrected leaves retained outside comparison")
        import market_cycle_label_history as market
        import wealth_milestone_log_history as wealth
        # The old nine-path assertion is kept against the separately proved
        # pre478/pre480 comparisons. Only the two declared log transitions differ.
        historical_actual = {**actual, audit.INVESTMENT:
                             market.market_cycle_predecessor(actual[audit.INVESTMENT], root),
                             audit.GAME_STATE:
                             wealth.game_state_predecessor(actual[audit.GAME_STATE], root)}
        check(all(historical_actual[p] == compared[p] for p in audit.PROTECTED if p not in audit.MIDGAME.values()),
              "other nine protected raw files remain exact after proven478/480 inverses")

        # These malformed supplied inputs fail the adapters' real current-disk
        # boundary before expensive Git history; no proof/collector is mocked.
        for locale, path in audit.MIDGAME.items():
            for label, raw in (("old raw", before[path]),
                               ("outside newline", actual[path] + b"\n"),
                               ("unowned neighbor", change_leaf(actual[path], 0, " altered")),
                               ("owned leaf drift", change_leaf(actual[path], 1, " altered"))):
                mutant = {**actual, path: raw}
                reject(lambda m=mutant: audit.historical_content_comparison(m, root),
                       "protected rejects " + locale + " " + label)
                reject(lambda m=mutant: night.historical_comparison(locale_view(m), root),
                       "night rejects " + locale + " " + label)
        for label, mutant in (
                ("missing", {p: raw for p, raw in actual.items() if p != audit.MIDGAME["ko"]}),
                ("extra", {**actual, "content/foreign.json": b"[]"}),
                ("nonbytes", {**actual, audit.MIDGAME["ja"]: actual[audit.MIDGAME["ja"]].decode()})):
            reject(lambda m=mutant: audit.historical_content_comparison(m, root),
                   "protected population " + label)
        locales = locale_view(actual)
        for label, mutant in (("missing", {k: v for k, v in locales.items() if k != "ko"}),
                               ("extra", {**locales, "foreign": b"[]"}),
                               ("nonbytes", {**locales, "ja": locales["ja"].decode()})):
            reject(lambda m=mutant: night.historical_comparison(m, root), "night population " + label)
        for path in audit.PROTECTED:
            if path not in audit.MIDGAME.values():
                mutant = {**actual, path: actual[path] + b"\n"}
                reject(lambda m=mutant: audit.historical_content_comparison(m, root),
                       "other protected raw " + path)
                check(bool(audit.content_errors(before, actual, comparison={**compared, path: before[path] + b"\n"})),
                      "comparison cannot replace other protected raw " + path)

        # Prove gameplay checks still read actual, not the historical view.
        ko = audit.MIDGAME["ko"]
        audit.require(actual[ko].count(b'"held_through_loss"') == 1,
                      "actual flag mutation fixture population")
        forged = {**actual, ko: actual[ko].replace(b'"held_through_loss"', b'"wrong_held_flag"', 1)}
        check(bool(audit.content_errors(before, forged, comparison=compared)),
              "actual producer flag cannot be hidden by historical comparison")
        shared_before = dict(compared)
        compared[ko] = b"forged returned predecessor"
        night_compared["ko"] = b"forged returned predecessor"
        check(audit.historical_content_comparison(actual, root) == shared_before,
              "protected returned dict has no proof alias")
        check(night.historical_comparison(locales, root) == locale_view(shared_before),
              "night returned dict has no proof alias")
    final, _ = history._snapshot(root, head, audit.PROTECTED)
    check(final == actual == inputs
          and {p: (root / p).read_bytes() for p in audit.PROTECTED} == inputs
          and history._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
          "actual source HEAD/Git/disk preserved after fresh proof exit")
    return failures, cases


def run_market_cycle_only(root=audit.ROOT):
    """478 adapter/tuple controls; partial fixtures are not a full collector."""
    import market_cycle_label_history as market
    import wealth_milestone_log_history as wealth
    import ja_translation_pipeline as pipeline
    root = Path(root).resolve()
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    head = market._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    paths = (*audit.PROTECTED, "tools/ja_translation_pipeline.py",
             "tools/investment_loss_gate_audit.py", "tools/investment_loss_gate_self_test.py")
    inputs = {p: (root / p).read_bytes() for p in paths}
    actual, _ = market._snapshot(root, head, audit.PROTECTED)
    before, _ = market._snapshot(root, audit.BASE, audit.PROTECTED)
    check(actual == {p: inputs[p] for p in audit.PROTECTED}, "actual typed HEAD/disk14")
    with market.fresh_validation_proof(root):
        compared = audit.historical_content_comparison(actual, root)
        check(compared == before, "exact pre477 text5/pre478 Investment1 comparison")
        check(not audit.content_errors(before, actual, comparison=compared),
              "actual gameplay/readers plus exact historical source comparison")
        historical_actual = {**actual, audit.GAME_STATE:
                             wealth.game_state_predecessor(actual[audit.GAME_STATE], root)}
        check(all(historical_actual[p] == compared[p] for p in audit.PROTECTED
                  if p not in (*audit.MIDGAME.values(), audit.INVESTMENT)),
              "remaining eight raw files unchanged after proven480 inverse")
        check(actual[audit.INVESTMENT] != compared[audit.INVESTMENT]
              and market.product_inverse(compared[audit.INVESTMENT], actual[audit.INVESTMENT],
                                         audit.INVESTMENT) == before[audit.INVESTMENT],
              "only proved Investment transition differs")
        for label, mutant in (
                ("rollback", before[audit.INVESTMENT]),
                ("unowned newline", actual[audit.INVESTMENT] + b"\n"),
                ("log bypass", actual[audit.INVESTMENT].replace(market.NEW_LOG, market.OLD_LOG, 1)),
                ("RNG changed", actual[audit.INVESTMENT].replace(b"randi_range(5, 11)", b"randi_range(5, 12)", 1)),
                ("unknown normalized", actual[audit.INVESTMENT].replace(b"\t\t\treturn cycle\n", b'\t\t\treturn "neutral"\n', 1))):
            check(mutant != actual[audit.INVESTMENT], "mutation precondition " + label)
            supplied = {**actual, audit.INVESTMENT: mutant}
            reject(lambda row=supplied: audit.historical_content_comparison(row, root),
                   "adapter rejects " + label)
            check(bool(audit.content_errors(before, supplied, comparison=compared)),
                  "historical view cannot hide actual " + label)
        for path in audit.PROTECTED:
            reject(lambda p=path: audit.historical_content_comparison(
                {**actual, p: actual[p] + b"\n"}, root), "actual raw binding " + path)
        for label, supplied in (("missing", {p: r for p, r in actual.items() if p != audit.INVESTMENT}),
                                 ("extra", {**actual, "foreign.gd": b""}),
                                 ("nonbytes", {**actual, audit.INVESTMENT: actual[audit.INVESTMENT].decode()})):
            reject(lambda row=supplied: audit.historical_content_comparison(row, root), "population " + label)

        previous, current = pipeline._market_cycle_call_views(actual[audit.INVESTMENT])
        check(pipeline._market_cycle_raw_call_views(before[audit.INVESTMENT], actual[audit.INVESTMENT])
              == (previous, current) and len(current) == len(previous) + 3,
              "actual immutable source and exact current three calls")
        for label, raw in (("missing helper", before[audit.INVESTMENT]),
                           ("line drift", b"\n" + actual[audit.INVESTMENT]),
                           ("wrong pair", actual[audit.INVESTMENT].replace(b'"Bull Market"', b'"Bear Market"', 1)),
                           ("wrong owner", actual[audit.INVESTMENT].replace(b"func _cycle_display_name(", b"func _other_cycle(", 1))):
            reject(lambda value=raw: pipeline._market_cycle_raw_call_views(before[audit.INVESTMENT], value),
                   "pure current tuple rejects " + label)

        # This small, explicitly synthetic peer inventory exercises rebuilding
        # only. The original current collector is executed separately by root.
        peers = tuple(pipeline.UiCall("synthetic-peer.gd", "existing", index + 1, "legacy", ko, en)
                      for index, (_line, ko, en) in enumerate(pipeline.MARKET_CYCLE_SITES))
        empty = pipeline.UiInventory((), (), {}, (), {}, (), {}, (), {})
        baseline = pipeline._new_run_log_inventory(empty, (*previous, *peers), {})
        result = pipeline._market_cycle_rebind(baseline, previous, current, {})
        check(tuple(c for c in result.calls if c.path == audit.INVESTMENT) == current
              and {e.source for e in result.legacy_entries} == {e.source for e in baseline.legacy_entries}
              and result.stats["source_calls"] == baseline.stats["source_calls"] + 3
              and result.stats["market_cycle_added_keys"] == 0,
              "partial fixture exact plus3 unique0 actual tuple rebuild")
        identities = {e.source: e for e in baseline.legacy_entries}
        check(all(replace(e, context=identities[e.source].context) == identities[e.source]
                  for e in result.legacy_entries), "partial surviving Entry identities")
        for label, supplied in (("missing", current[:-1]), ("duplicate", (*current, current[-1])),
                                 ("reordered", tuple(reversed(current))),
                                 ("line", (*current[:-1], replace(current[-1], line=current[-1].line + 1))),
                                 ("English", (*current[:-1], replace(current[-1], english="forged"))),
                                 ("owner", (*current[:-1], replace(current[-1], function="forged")))):
            reject(lambda row=supplied: pipeline._market_cycle_rebind(baseline, previous, row, {}),
                   "partial rebind rejects " + label)
        reject(lambda: pipeline._market_cycle_rebind(replace(baseline, calls=baseline.calls[:-1]),
                                                     previous, current, {}), "partial old-owner omission")
        missing_key = pipeline._new_run_log_inventory(empty, (*previous, *peers[:-1]), {})
        reject(lambda: pipeline._market_cycle_rebind(missing_key, previous, current, {}),
               "partial key creation is not accepted as unique0")
        check(audit.historical_content_comparison(actual, root) == before, "fresh final comparison unchanged")
    final, _ = market._snapshot(root, head, audit.PROTECTED)
    check(final == actual and inputs == {p: (root / p).read_bytes() for p in paths}
          and market._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
          "actual HEAD/Git/disk and owned inputs preserved after exit")
    return failures, cases


def run_wealth_milestone_only(root=audit.ROOT):
    """480 GameState comparison only; no old numeric/UI/engine populations."""
    import wealth_milestone_log_history as wealth
    root = Path(root).resolve()
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def reject(fn, label):
        try:
            fn()
        except (ValueError, TypeError, KeyError, IndexError, OSError):
            check(True, label)
        else:
            check(False, label)

    head = wealth._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    paths = (*audit.PROTECTED, "tools/investment_loss_gate_audit.py",
             "tools/investment_loss_gate_self_test.py")
    inputs = {p: (root / p).read_bytes() for p in paths}
    actual, _ = wealth._snapshot(root, head, audit.PROTECTED)
    before, _ = wealth._snapshot(root, audit.BASE, audit.PROTECTED)
    check(actual == {p: inputs[p] for p in audit.PROTECTED}, "actual typed HEAD/disk14")
    with wealth.fresh_validation_proof(root) as proof:
        path = audit.GAME_STATE
        current = actual[path]
        previous = wealth.game_state_predecessor(current, root)
        check(proof["current"][path] == current and proof["before"][path] == previous,
              "actual current source and immutable predecessor bound")
        check(previous == before[path] and previous != current,
              "only new log pair projects to original476 protected GameState")
        # This pure content predicate receives an explicit immutable comparison
        # fixture. It is not a fresh proof of the unchanged477/478 transitions;
        # root separately invokes the original audit's full current adapter.
        check(not audit.content_errors(before, actual, comparison=before),
              "actual producer/readers and wealth inverse accept immutable comparison fixture")
        check(bool(audit.content_errors(before, actual)), "unprojected current is not old raw")
        mutations = (
            ("rollback", previous),
            ("outside newline", current + b"\n"),
            ("old Korean", current.replace(wealth.NEW_KEY.encode(), wealth.OLD_KEY.encode(), 1)),
            ("old English", current.replace(wealth.NEW_ENGLISH.encode(), wealth.OLD_ENGLISH.encode(), 1)),
            ("threshold", current.replace(b"total_now >= 2_000_000_000", b"total_now >= 2_500_000_000", 1)),
            ("flag", current.replace(b'flags["asset_2b_reached"] = true', b'flags["asset_2b_reached"] = false', 1)),
            ("neighbor", current.replace("🔥 자산 27억".encode(), "🔥 자산 28억".encode(), 1)),
        )
        for label, mutant in mutations:
            check(mutant != current, "mutation precondition " + label)
            check(bool(audit.content_errors(before, {**actual, path: mutant}, comparison=before)),
                  "immutable comparison cannot hide actual GameState " + label)
        check(bool(audit.content_errors(before, {**actual, path: current.decode()}, comparison=before)),
              "actual GameState nonbytes rejected")
        check(bool(audit.content_errors(before, actual, comparison={**before, path: previous + b"\n"})),
              "forged historical GameState rejected")
        check(bool(audit.content_errors(before, actual, comparison={**before, path: current})),
              "current raw cannot masquerade as historical comparison")
        # The adapter's actual disk boundary rejects these without acquiring any
        # historical proof. No mutable live disk or proof substitution is used.
        for label, mutant in (*mutations, ("nonbytes", current.decode())):
            reject(lambda value=mutant: audit.historical_content_comparison(
                {**actual, path: value}, root), "adapter current boundary " + label)
        for label, supplied in (("missing", {p: r for p, r in actual.items() if p != path}),
                                 ("extra", {**actual, "foreign.gd": b""})):
            reject(lambda row=supplied: audit.historical_content_comparison(row, root),
                   "adapter protected population " + label)
        check(wealth.game_state_predecessor(current, root) == previous,
              "fresh final GameState comparison unchanged")
    final, _ = wealth._snapshot(root, head, audit.PROTECTED)
    check(final == actual and inputs == {p: (root / p).read_bytes() for p in paths}
          and wealth._git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
          "actual HEAD/Git/disk and owned inputs preserved after exit")
    return failures, cases


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--loss-hold-only", action="store_true",
                        help="only ORDER477 historical-comparison connector controls")
    parser.add_argument("--market-cycle-only", action="store_true",
                        help="only ORDER478 comparison/call rebuilding controls; no full collector")
    parser.add_argument("--wealth-milestone-only", action="store_true",
                        help="only ORDER480 protected GameState comparison; no full collector")
    args = parser.parse_args()
    if sum((args.loss_hold_only, args.market_cycle_only, args.wealth_milestone_only)) > 1:
        parser.error("choose at most one targeted scope")
    prefix = ("INVESTMENT_WEALTH_MILESTONE_ADAPTER_SELF_TEST" if args.wealth_milestone_only else
              "INVESTMENT_MARKET_CYCLE_ADAPTER_SELF_TEST" if args.market_cycle_only else
              "INVESTMENT_LOSS_HOLD_ADAPTER_SELF_TEST" if args.loss_hold_only else "INVESTMENT_LOSS_GATE_SELF_TEST")
    try:
        failures, cases = (run_wealth_milestone_only() if args.wealth_milestone_only else
                           run_market_cycle_only() if args.market_cycle_only else
                           run_loss_hold_only() if args.loss_hold_only else run())
    except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError) as exc:
        print(prefix + "_FAIL " + str(exc))
        return 1
    for failure in failures:
        print(prefix + "_FAIL " + failure)
    print(f"{prefix}_{'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
