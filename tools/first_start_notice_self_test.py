#!/usr/bin/env python3
"""One current notice admission; old suites execute unchanged in restored views."""
from __future__ import annotations

from collections import Counter
from contextlib import ExitStack, contextmanager, redirect_stderr, redirect_stdout
from dataclasses import asdict, replace
import hashlib
import io
import json
from pathlib import Path
import re
import sys
import traceback
from unittest.mock import patch

import ja_translation_pipeline as pipeline

ROOT = Path(__file__).resolve().parents[1]
START = "scenes/StartMenu.gd"
PIPELINE = "tools/ja_translation_pipeline.py"
OLD_SELF = "tools/new_run_log_locale_self_test.py"
PIPELINE_SHA = "0cc15618245c679bf891244a59ce408b2476283d8f683fde7d22b838a37973f5"
OLD_SELF_SHA = "37555e029e55652cca85705905a5acc186c076e97595dc27221cb8aa1899dd80"
ENTRY_HOOK = '''# BEGIN_FIRST_START_NOTICE_ENTRY_274
_NOTICE_SAVED_MAIN = main
_NOTICE_SAVED_HISTORICAL_ENTRY = historical_entry


def main():
    from first_start_notice_self_test import previous_entry
    return previous_entry(_NOTICE_SAVED_MAIN, "source")


def historical_entry(function, kind):
    from first_start_notice_self_test import previous_entry
    return previous_entry(lambda: _NOTICE_SAVED_HISTORICAL_ENTRY(function, kind), kind)
# END_FIRST_START_NOTICE_ENTRY_274

'''
CASE_IDS = (
    "current_notice", "raw_previous_start", "raw_ko_changed", "raw_en_changed", "raw_unrelated_lf",
    "semantic_missing", "semantic_duplicate", "semantic_owner", "semantic_api", "semantic_ko",
    "semantic_en", "semantic_context", "semantic_extra_owner", "historical_exception_restore",
)
OBSERVED_PATHS = (START, PIPELINE, OLD_SELF, "tools/first_start_notice_self_test.py",
                  "tools/main_game_locale_history.py", "locale/ui_ja.json",
                  "locale/ui_zh-CN.json", "locale/ui_zh-TW.json")


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def pins():
    return {p: {"bytes": len(raw), "sha256": sha(raw)} for p in OBSERVED_PATHS
            for raw in [(ROOT / p).read_bytes()]}


def prepare():
    current, previous, errors = pipeline._notice_raw_view()
    if errors or sha(pipeline.current_demo_pipeline_predecessor(current[PIPELINE])) != PIPELINE_SHA:
        raise AssertionError("current notice/code source: " + repr(errors))
    raw = (ROOT / OLD_SELF).read_bytes()
    hook = ENTRY_HOOK.encode()
    if raw.count(hook) != 1:
        raise AssertionError("new-run entry hook is not exact1")
    old = raw.replace(hook, b"", 1)
    if sha(old) != OLD_SELF_SHA:
        raise AssertionError("new-run whole predecessor differs")
    previous[OLD_SELF] = old
    return current, previous


def call_key(call):
    return (call.path, call.function, call.api, call.korean, call.english, call.context_id)


@contextmanager
def historical_view(previous, observation):
    read0, text0 = Path.read_bytes, Path.read_text
    old_collect, old_checks = pipeline.collect_ui_inventory, pipeline._last11_meta_title_historical_checks
    aliases = []
    # Some consumers import the function directly rather than using the module.
    for name in ("ja_translation_audit", "zh_translation_audit", "demo_localization_scope",
                 "ci_localization_reconciliation_self_test", "meta_title_locale_successor_self_test"):
        module = sys.modules.get(name)
        if module is not None:
            aliases.extend((module, key, value) for key, value in vars(module).items()
                           if value is old_collect or value is old_checks)
    try:
        with ExitStack() as stack:
            stack.enter_context(pipeline._notice_previous_reads(previous))
            stack.enter_context(patch.object(pipeline, "collect_ui_inventory", pipeline._NOTICE_OLD_COLLECT))
            stack.enter_context(patch.object(pipeline, "_last11_meta_title_historical_checks", pipeline._NOTICE_OLD_CHECKS))
            for module, key, value in aliases:
                stack.enter_context(patch.object(module, key, pipeline._NOTICE_OLD_COLLECT
                    if value is old_collect else pipeline._NOTICE_OLD_CHECKS))
            yield
    finally:
        observation.update(path_restored=Path.read_bytes is read0 and Path.read_text is text0,
            callables_restored=pipeline.collect_ui_inventory is old_collect
                and pipeline._last11_meta_title_historical_checks is old_checks,
            imported_aliases_restored=all(getattr(m, k) is v for m, k, v in aliases))


def normal(current, previous):
    inventory = pipeline.collect_ui_inventory()
    actual, parse_errors = pipeline.parse_ui_calls(START, current[START].decode())
    with pipeline._notice_previous_reads({p: previous[p] for p in (START, PIPELINE)}):
        old = pipeline._NOTICE_OLD_COLLECT()
    projected, errors = pipeline._notice_predecessor_calls(inventory.calls)
    old_span = pipeline._notice_call(False)
    new_span = pipeline._notice_call(True)
    literal = r'"(?:\\.|[^"\\])*"'
    old_literals = [json.loads(s) for s in re.findall(literal, old_span)]
    new_literals = [json.loads(s) for s in re.findall(literal, new_span)]
    ko = "이 게임에는 다음과 같은 내용이 포함됩니다:\n\n• 재정적 어려움과 부채\n• 가족·사회적 압박과 비교\n• 직장 스트레스와 번아웃\n• 정신건강 관련 묘사\n\n강남드림은 현실적인 삶을 다룹니다. 어려운 상황들은 이야기의 일부이며, 권장하는 내용이 아닙니다."
    en = "This game contains depictions of:\n\n• Financial hardship and debt\n• Family pressure and social comparison\n• Workplace stress and burnout\n• Mental health struggles\n\nGangnam Dream is a realistic portrayal of life. Difficult situations are part of the story — not endorsements."
    old_keys, new_keys = set(old.legacy_blueprint), set(inventory.legacy_blueprint)
    stats = inventory.stats
    checks = {
        "decoded_values": len(old_literals) == 14 and new_literals == [ko, en]
            and ["".join(old_literals[:7]), "".join(old_literals[7:])] == [ko, en]
            and ko.count("\n") == en.count("\n") == 7,
        "source_valid": not inventory.errors and not old.errors and not parse_errors and not errors,
        "current_start_exact": Counter(tuple(asdict(c).items()) for c in inventory.calls if c.path == START)
            == Counter(tuple(asdict(c).items()) for c in actual),
        "non_start_calls_exact": tuple(c for c in inventory.calls if c.path != START)
            == tuple(c for c in old.calls if c.path != START),
        "historical_all_calls_exact": Counter(tuple(asdict(c).items()) for c in projected)
            == Counter(tuple(asdict(c).items()) for c in old.calls),
        "only_one_key_added": new_keys - old_keys == {ko} and not old_keys - new_keys,
        "one_current_legacy_call": len(inventory.calls) == len(old.calls) + 1
            and stats.get("source_calls") == 3466 and stats.get("legacy_keys") == 2949
            and old.stats.get("source_calls") == 3465 and old.stats.get("legacy_keys") == 2948,
        "current_api_partition": all(stats.get(k) == sum(c.api == api for c in inventory.calls)
            for k, api in (("legacy_api_calls", "legacy"), ("format_calls", "format"),
                           ("branch_variant_calls", "branch"), ("context_calls", "context"))),
        "no_new_context": inventory.planned_context_entries == old.planned_context_entries
            and inventory.observed_context_entries == old.observed_context_entries,
    }
    return all(checks.values()), {"checks": checks, "current_stats": stats, "previous_stats": old.stats,
        "errors": list(inventory.errors), "previous_errors": list(old.errors),
        "parse_errors": parse_errors, "semantic_errors": errors,
        "notice": [asdict(c) for c in inventory.calls if c.korean == ko]}, inventory.calls


def exception_probe(previous):
    observed = {}
    caught = None
    try:
        with historical_view(previous, observed):
            observed["inside_exact"] = all((ROOT / p).read_bytes() == raw for p, raw in previous.items())
            raise RuntimeError("first-start notice deliberate restoration exception")
    except RuntimeError as exc:
        caught = str(exc)
    return all(observed.values()) and caught == "first-start notice deliberate restoration exception", {
        "restoration": observed, "caught": caught}


def previous_entry(function, kind):
    before, after, code, fatal, observation, prerequisite = pins(), None, None, None, {}, {}
    stdout, stderr = io.StringIO(), io.StringIO()
    try:
        current, previous = prepare()
        good, prerequisite, _calls = normal(current, previous)
        if good:
            with historical_view(previous, observation), redirect_stdout(stdout), redirect_stderr(stderr):
                code = function()
    except Exception:
        fatal = traceback.format_exc()
    finally:
        after = pins()
    passed = code == 0 and not fatal and not stderr.getvalue() and before == after and all(observation.values())
    print(json.dumps({"scope": "first-start notice prerequisite then unchanged " + kind,
        "passed": passed, "normal_prerequisite": prerequisite, "old_exit": code,
        "stdout": stdout.getvalue(), "stderr": stderr.getvalue(), "exception": fatal,
        "restoration": observation, "physical_before": before, "physical_after": after,
        "old_invocations": int(code is not None), "new14": 0}, ensure_ascii=False, indent=2))
    print("FIRST_START_NOTICE_HISTORY_" + ("OK" if passed else "FAIL") + " kind=" + kind)
    return 0 if passed else 1


def main():
    before, results, fatal, calls = pins(), [], None, ()
    try:
        current, previous = prepare()
        for cid in CASE_IDS:
            stdout, stderr, exception, values, passed = io.StringIO(), io.StringIO(), None, {}, False
            try:
                with redirect_stdout(stdout), redirect_stderr(stderr):
                    if cid == "current_notice":
                        passed, values, calls = normal(current, previous)
                    elif cid == "historical_exception_restore":
                        passed, values = exception_probe(previous)
                    elif cid.startswith("raw_"):
                        raw = {"raw_previous_start": previous[START],
                               "raw_ko_changed": current[START].replace("이 게임에는".encode(), "이 작품에는".encode(), 1),
                               "raw_en_changed": current[START].replace(b"This game contains", b"This game includes", 1),
                               "raw_unrelated_lf": current[START] + b"\n"}[cid]
                        with pipeline._notice_previous_reads({START: raw}), patch.object(
                                pipeline, "_NOTICE_OLD_COLLECT", side_effect=AssertionError("old collector must not run")) as saved:
                            returned = pipeline.collect_ui_inventory()
                        passed = bool(returned.errors) and saved.call_count == 0
                        values = {"input_sha256": sha(raw), "errors": list(returned.errors), "saved_calls": saved.call_count}
                    else:
                        supplied = list(calls)
                        index = next(i for i, c in enumerate(supplied) if c.korean == pipeline.NOTICE_KO)
                        call = supplied[index]
                        if cid == "semantic_missing":
                            supplied.pop(index)
                        elif cid == "semantic_duplicate":
                            supplied.append(call)
                        elif cid == "semantic_extra_owner":
                            supplied.append(replace(call, path="scenes/MainGame.gd", function="_render_sidebars"))
                        else:
                            field, value = {"semantic_owner": ("function", "_request_new_run"),
                                "semantic_api": ("api", "format"), "semantic_ko": ("korean", call.korean + " "),
                                "semantic_en": ("english", call.english + " "),
                                "semantic_context": ("context_id", "unexpected.notice")}[cid]
                            supplied[index] = replace(call, **{field: value})
                        returned, errors = pipeline._notice_predecessor_calls(supplied)
                        passed = bool(errors) and returned == tuple(supplied)
                        values = {"errors": errors, "identity_on_rejection": returned == tuple(supplied)}
            except Exception:
                exception = traceback.format_exc()
            results.append({"id": cid, "passed": bool(passed and not exception and not stderr.getvalue()),
                "values": values, "stdout": stdout.getvalue(), "stderr": stderr.getvalue(), "exception": exception})
    except Exception:
        fatal = traceback.format_exc()
    after = pins()
    positive = bool(results and results[0]["passed"])
    for row in results:
        row["effective_negative"] = positive and row["passed"] and row["id"].startswith(("raw_", "semantic_"))
    passed = len(results) == 14 and all(r["passed"] for r in results) and not fatal and before == after
    print(json.dumps({"scope": "first-start notice fixed14; no old suite duplication", "passed": passed,
        "results": results, "exception": fatal, "physical_before": before, "physical_after": after,
        "effective_negatives": sum(r["effective_negative"] for r in results), "old_suites": 0}, ensure_ascii=False, indent=2))
    print("FIRST_START_NOTICE_SELF_TEST_" + ("OK" if passed else "FAIL") + " cases=14")
    return 0 if passed else 1


def current_code_self_test():
    """Exact369 caller/370 adapter controls; none replaces the original14."""
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("current-demo code boundary: " + label)

    raw = (ROOT / PIPELINE).read_bytes()
    before = pins()
    read0, text0 = Path.read_bytes, Path.read_text
    previous = pipeline.current_demo_pipeline_predecessor(raw)
    check(sha(previous) == PIPELINE_SHA, "exact historical274 code")
    current, old, errors = pipeline._notice_raw_view()
    check(not errors and current[PIPELINE] == raw and current[START] == (ROOT / START).read_bytes(),
          "current observation returns actual raw")
    check(sha(old[PIPELINE]) == pipeline.NOTICE_PIPELINE_PREVIOUS_SHA,
          "older reader still receives pre274 code")
    inventory = pipeline.collect_ui_inventory()
    check(not inventory.errors and len(inventory.calls) == 3466
          and inventory.stats.get("legacy_keys") == 2949
          and inventory.stats.get("migrated_context_ids") == 29, "actual collector population and stats")
    check(Path.read_bytes is read0 and Path.read_text is text0, "normal read restoration")

    begin, end = b"# BEGIN_CURRENT_DEMO_EXPECTATION_370\n", b"# END_CURRENT_DEMO_EXPECTATION_370\n\n"
    a, z = raw.index(begin), raw.index(end) + len(end)
    span = raw[a:z]
    no_append = raw[:a] + raw[z:]
    new, old_hunk = pipeline.CURRENT_DEMO_NEW_HUNK.encode(), pipeline.CURRENT_DEMO_OLD_HUNK.encode()
    mutations = (
        ("full old274 rollback", previous), ("369 without appendix", no_append),
        ("missing caller only", raw.replace(new, old_hunk, 1)),
        ("duplicate caller", raw.replace(new, new + new, 1)),
        ("changed caller", raw.replace(b"expected, expectation_errors = demo_scope.current_source_contract",
                                        b"expected, expectation_errors = demo_scope.other_source_contract", 1)),
        ("duplicate appendix", raw[:z] + span + raw[z:]),
        ("missing appendix start", raw.replace(begin, b"", 1)),
        ("missing appendix end", raw.replace(end, b"", 1)),
        ("appendix implementation", raw.replace(b"predecessor = current_demo_pipeline_predecessor(",
                                               b"predecessor = other_pipeline_predecessor(", 1)),
        ("seal forged", raw.replace(pipeline.CURRENT_DEMO_APPEND_SHA.encode(), b"0" * 64, 1)),
        ("outside function", raw.replace(b"def git_private_path(filename:", b"def other_private_path(filename:", 1)),
        ("old pin changed", raw.replace(pipeline.NOTICE_PIPELINE_PREVIOUS_SHA.encode(), b"0" * 64, 1)),
        ("leading whitespace", b" " + raw), ("trailing newline", raw + b"\n"), ("empty", b""),
    )
    for label, mutant in mutations:
        rejected = False
        try:
            pipeline.current_demo_pipeline_predecessor(mutant)
        except (OSError, ValueError, TypeError):
            rejected = True
        def altered_read(path):
            return mutant if path == ROOT / PIPELINE else read0(path)
        with patch.object(Path, "read_bytes", altered_read), patch.object(
                pipeline, "_CURRENT_DEMO_OLD_NOTICE_RAW_VIEW",
                side_effect=AssertionError("historical reader must not run")) as historical:
            returned, projected, guard_errors = pipeline._notice_raw_view()
        check(rejected and bool(guard_errors) and not projected and not historical.called
              and returned.get(PIPELINE) == mutant, label)
    for invalid in (None, "not raw bytes", bytearray(raw)):
        try:
            pipeline.current_demo_pipeline_predecessor(invalid)
        except (ValueError, TypeError):
            check(True, "nonbytes rejected")
        else:
            check(False, "nonbytes rejected")
    actual_git = pipeline._current_demo_git
    for label, fake in (
        ("missing Git", lambda *args: (_ for _ in ()).throw(OSError("missing immutable proof"))),
        ("forged Git blob", lambda *args: b"forged" if args[0] == "show" else actual_git(*args)),
        ("wrong parent", lambda *args: b"0" * 40 + b"\n" if args[0] == "rev-parse" else actual_git(*args)),
    ):
        with patch.object(pipeline, "_current_demo_git", side_effect=fake), patch.object(
                pipeline, "_CURRENT_DEMO_OLD_NOTICE_RAW_VIEW",
                side_effect=AssertionError("historical reader must not run")) as historical:
            returned, projected, guard_errors = pipeline._notice_raw_view()
        check(bool(guard_errors) and not projected and not historical.called and returned.get(PIPELINE) == raw, label)
        recovered, _old, guard_errors = pipeline._notice_raw_view()
        check(not guard_errors and recovered[PIPELINE] == raw, label + " recovery")
    original_reader = pipeline._CURRENT_DEMO_OLD_NOTICE_RAW_VIEW
    inside = {}
    other = ROOT / "content/meta/demo_localization_scope.json"
    other_raw = other.read_bytes()
    def observed_reader(source):
        inside.update(code=(ROOT / PIPELINE).read_bytes() == previous,
                      text=(ROOT / PIPELINE).read_text(encoding="utf-8") == previous.decode(),
                      other=other.read_bytes() == other_raw)
        return original_reader(source)
    with patch.object(pipeline, "_CURRENT_DEMO_OLD_NOTICE_RAW_VIEW", side_effect=observed_reader):
        _current, _old, guard_errors = pipeline._notice_raw_view()
    check(not guard_errors and inside == {"code": True, "text": True, "other": True}, "scoped read only")
    check(Path.read_bytes is read0 and Path.read_text is text0, "observed reader restoration")
    caught = False
    def exploding_reader(source):
        if (ROOT / PIPELINE).read_bytes() != previous:
            raise AssertionError("exception fixture not in predecessor scope")
        raise RuntimeError("deliberate current-demo restoration exception")
    with patch.object(pipeline, "_CURRENT_DEMO_OLD_NOTICE_RAW_VIEW", side_effect=exploding_reader):
        try:
            pipeline._notice_raw_view()
        except RuntimeError as exc:
            caught = str(exc) == "deliberate current-demo restoration exception"
    check(caught and Path.read_bytes is read0 and Path.read_text is text0, "exception restoration")
    current, _old, guard_errors = pipeline._notice_raw_view()
    check(not guard_errors and current[PIPELINE] == raw, "recovery after exception")
    check(before == pins(), "physical inputs unchanged")
    return failures, cases


_ORIGINAL_FIXED14_MAIN = main


def main():
    old_exit = _ORIGINAL_FIXED14_MAIN()
    try:
        failures, cases = current_code_self_test()
    except Exception:
        failures, cases = [traceback.format_exc()], 0
    print(json.dumps({"scope": "exact369 caller/current370 code boundary, separate from fixed14",
                      "failures": failures, "cases": cases}, ensure_ascii=False))
    print("FIRST_START_NOTICE_CURRENT_CODE_" + ("FAIL" if failures else "OK") + f" cases={cases}")
    return int(bool(old_exit or failures))


if __name__ == "__main__":
    raise SystemExit(main())
