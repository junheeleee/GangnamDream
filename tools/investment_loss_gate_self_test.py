#!/usr/bin/env python3
"""Bounded current loss-gate mutation controls; no engine or history proof."""
from __future__ import annotations

import investment_loss_gate_audit as audit


def run(root=audit.ROOT):
    audit.run(root)
    return audit.self_test(root)


def main():
    try:
        failures, cases = run()
    except (ValueError, TypeError, KeyError, IndexError, OSError, SyntaxError) as exc:
        print("INVESTMENT_LOSS_GATE_SELF_TEST_FAIL " + str(exc))
        return 1
    for failure in failures:
        print("INVESTMENT_LOSS_GATE_SELF_TEST_FAIL " + failure)
    print(f"INVESTMENT_LOSS_GATE_SELF_TEST_{'FAIL' if failures else 'OK'} "
          f"cases={cases} failures={len(failures)}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
