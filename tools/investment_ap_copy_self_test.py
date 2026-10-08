#!/usr/bin/env python3
"""Current trading AP toast ownership and translations; no old Git view."""
from __future__ import annotations
import argparse
import hashlib
from pathlib import Path
import full_game_localization as exchange
import ja_translation_audit as audit
import ja_translation_pipeline as pipeline

ROOT = Path(__file__).resolve().parents[1]
MAIN = "scenes/MainGame.gd"
OWNERS = ("_on_leverage_buy", "_on_buy_asset", "_on_sell_asset")
PAIR = ("행동력이 없습니다", "No Action Points")
RETIRED = "행동력이 없습니다. 이번 달 거래 불가"


def source_errors(source: str) -> list[str]:
    calls, errors = pipeline.parse_ui_calls(MAIN, source)
    expected = {(owner, "legacy", *PAIR, ""): 1 for owner in OWNERS}
    observed = dict.fromkeys(expected, 0)
    for call in calls:
        if call.function not in OWNERS:
            continue
        if "행동력" not in call.korean and "Action Points" not in call.english:
            continue
        key = (call.function, call.api, call.korean, call.english, call.context_id)
        if key not in observed:
            errors.append("trading AP toast has incorrect owner/API/text/context")
        else:
            observed[key] += 1
    if observed != expected:
        errors.append("trading AP toast must occur once in each of three trading callbacks")
    return errors


def run_self_test(*, include_current: bool = True) -> tuple[list[str], int]:
    failures, cases = [], 0
    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)
    paths = (MAIN, "tools/investment_ap_copy_self_test.py",
             "locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json",
             "content/meta/full_game_localization.json")
    before = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    source = (ROOT / MAIN).read_text()
    check(not source_errors(source), "current three trading callback toasts")
    check(not source_errors(source + "\n"), "harmless whitespace allowed")
    for owner in OWNERS:
        body = pipeline._gd_function_source(source, owner)
        check(bool(body), owner + " current owner exists")
        literal = '_tr("행동력이 없습니다", "No Action Points")'
        check(body.count(literal) == 1, owner + " mutation precondition")
        for label, old, new in (
            ("missing", literal, '"AP unavailable"'),
            ("duplicate", literal, literal + " + " + literal),
            ("wrong-ko", PAIR[0], "행동력이 부족합니다"),
            ("wrong-en", PAIR[1], "No trading this month"),
            ("retired-month-claim", PAIR[0], RETIRED),
        ):
            mutant = source.replace(body, body.replace(old, new, 1), 1)
            check(bool(source_errors(mutant)), owner + " rejects " + label)
        mutant = source.replace("func " + owner + "(", "func " + owner + "_unowned(", 1)
        check(bool(source_errors(mutant)), owner + " wrong owner")
    if include_current:
        inventory = pipeline.collect_ui_inventory()
        check(not inventory.errors, "actual current source collector")
        for owner in OWNERS:
            calls = [c for c in inventory.calls if c.path == MAIN
                     and c.function == owner and c.korean == PAIR[0]]
            check(len(calls) == 1 and calls[0].english == PAIR[1],
                  owner + " current collector owner")
        check(PAIR[0] in inventory.blueprint and RETIRED not in inventory.blueprint,
              "retired monthly claim is not live coverage")
        ledger = exchange.loads((ROOT / "content/meta/full_game_localization.json").read_text())
        for locale in ("ja", "zh-CN", "zh-TW"):
            targets = exchange.loads((ROOT / f"locale/ui_{locale}.json").read_text())
            check(isinstance(targets.get(PAIR[0]), str) and bool(targets[PAIR[0]].strip()),
                  locale + " current AP target")
            entry = next(e for e in inventory.legacy_entries if e.source == PAIR[0])
            check(not pipeline.validate_translation(entry, targets[PAIR[0]]),
                  locale + " AP target formatting")
            if locale != "ja":
                leaf = "ui:" + PAIR[0] + ":/" + PAIR[0]
                receipt = ledger["accepted"][locale].get(leaf, {})
                source_leaf = exchange.Leaf(
                    "ui", PAIR[0], "runtime:static_ui", (PAIR[0],),
                    PAIR[0], "ui_static_context")
                check(receipt.get("target_sha256") == exchange.digest(targets[PAIR[0]])
                      and receipt.get("source_sha256") == source_leaf.source_sha256,
                      locale + " source/target receipt binding")
        optional, errors = audit.retired_relationship_ui_entries(inventory)
        check(not errors and RETIRED in optional, "unused retired dictionary row is optional")
        check("ui:" + RETIRED + ":/" + RETIRED not in ledger["accepted"]["ja"],
              "no fabricated retired Japanese receipt")
    after = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    check(before == after, "inputs unchanged")
    return failures, cases


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-only", action="store_true")
    args = parser.parse_args(argv)
    try:
        failures, cases = run_self_test(include_current=not args.source_only)
    except Exception as exc:
        print("INVESTMENT_AP_COPY_SELF_TEST_FAIL exception=" + repr(exc))
        return 1
    marker = "INVESTMENT_AP_COPY_SOURCE_ONLY" if args.source_only else "INVESTMENT_AP_COPY_SELF_TEST"
    print(f"{marker}_{'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)}")
    for failure in failures:
        print("ERROR " + failure)
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
