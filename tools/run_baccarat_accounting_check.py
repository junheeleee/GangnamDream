#!/usr/bin/env python3
"""Run the real Baccarat table accounting check in fresh pre-autoload storage.

Preserve every attempt, including failures. This is deterministic component
regression evidence, not a physical-controller, probability, or release verdict.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile
import time

import run_routine_background_context_check as safe

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_SUCCESS = "BACCARAT_ACCOUNTING_CHECK_OK cases=36 locales=2"
CASE_IDS = (
    "player_win", "player_loss", "banker_win", "banker_loss", "tie_win", "tie_loss",
    "player_tie_refund", "banker_tie_refund", "mixed_tie_refunds", "player_pair_win",
    "player_pair_loss", "banker_pair_win", "banker_pair_loss", "both_pairs_win",
    "banker_pair_mixed", "player_banker_negative", "multi_round_commission", "reopen_empty",
)
RESULT_FIELDS = {"steps", "cash", "commission", "net", "summary", "rounds", "counts",
                 "road", "round_surfaces", "commission_logs", "closed_signals"}
INPUTS = (
    "scenes/BaccaratTable.gd", "systems/Baccarat.gd", "project.godot",
    "scenes/JeongseonCasino.gd", "scenes/TutorialOverlay.gd",
    "autoloads/GameState.gd", "autoloads/LocaleManager.gd",
    "autoloads/AudioManager.gd", "autoloads/MetaProgression.gd",
    "tools/StoryNameplateBootstrap.gd", "tools/BaccaratAccountingCheck.gd",
    "tools/BaccaratAccountingCheck.tscn", "tools/run_baccarat_accounting_check.py",
    "tools/run_routine_background_context_check.py",
)


def pin(path: Path) -> dict:
    raw = path.read_bytes()
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def real_user_pins(parent: Path) -> dict:
    engine_dir = "Godot" if os.name == "nt" or os.sys.platform == "darwin" else "godot"
    roots = [parent / engine_dir / "app_userdata" / "강남드림",
             parent / "GangnamDream_StoryDemo_v1"]
    return {str(path): pin(path) for root in roots if root.exists()
            for path in sorted(root.rglob("*")) if path.is_file()}


def case_rows_valid(rows: list) -> bool:
    if len(rows) != 36 or any(not isinstance(row, dict) for row in rows):
        return False
    if [(row.get("locale"), row.get("case")) for row in rows] != [
            (locale, case) for locale in ("ko", "en") for case in CASE_IDS]:
        return False
    return all(row.get("passed") is True and isinstance(row.get("expected"), dict)
               and set(row["expected"]) == RESULT_FIELDS
               and row["expected"] == row.get("actual")
               and bool(row["expected"]["steps"]) for row in rows)


def self_test() -> int:
    signature = {key: 0 for key in RESULT_FIELDS}
    signature["steps"] = [{"action": "deal"}]
    good = [{"locale": locale, "case": case, "passed": True,
             "expected": copy.deepcopy(signature), "actual": copy.deepcopy(signature)}
            for locale in ("ko", "en") for case in CASE_IDS]
    cases = [(good, True), ([], False), (good[:-1], False), (good + good[:1], False)]
    for field, value in (("passed", False), ("actual", {}), ("case", "wrong"),
                         ("locale", "ja"), ("expected", {})):
        bad = copy.deepcopy(good)
        bad[0][field] = value
        cases.append((bad, False))
    duplicate = copy.deepcopy(good)
    duplicate[1] = copy.deepcopy(duplicate[0])
    cases.append((duplicate, False))
    for rows, expected in cases:
        if case_rows_valid(rows) != expected:
            print("BACCARAT_ACCOUNTING_RUNNER_SELF_TEST_FAIL")
            return 1
    print(f"BACCARAT_ACCOUNTING_RUNNER_SELF_TEST_OK cases={len(cases)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    parser.add_argument("--evidence", type=Path)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required; set GODOT or --godot")
    parent = safe.user_data_parent()
    if parent is None:
        parser.error("unknown Godot userdata parent")
    if args.evidence:
        evidence = args.evidence.resolve()
        evidence.mkdir(parents=True, exist_ok=False)
    else:
        evidence = Path(tempfile.mkdtemp(prefix="gangnam-baccarat-accounting-"))
    namespace = safe.PREFIX + secrets.token_hex(16)
    qa_path = parent / namespace
    if os.path.lexists(qa_path):
        raise RuntimeError("refused existing QA namespace")
    inputs_before = {path: pin(ROOT / path) for path in INPUTS}
    users_before = real_user_pins(parent)
    env = os.environ.copy()
    env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
    command = [godot, "--headless", "--path", str(ROOT), "--max-fps", "60",
               "--resolution", "1280x800", "--locale", "en", "--audio-driver", "Dummy",
               "--quit-after", "3600", "--log-file", str(evidence / "godot.log"),
               "--script", "res://tools/StoryNameplateBootstrap.gd",
               "--scene", "res://tools/BaccaratAccountingCheck.tscn"]
    report = {"command": command, "head": git("rev-parse", "HEAD"),
              "tree": git("rev-parse", "HEAD^{tree}"),
              "status_before": git("status", "--porcelain"),
              "inputs_before": inputs_before, "real_user_files_before": users_before,
              "namespace": str(qa_path), "claim": __doc__}
    process_options = ({"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
                       if os.name == "nt" else {"start_new_session": True})
    print(f"BACCARAT_ACCOUNTING_EVIDENCE={evidence}", flush=True)
    started = time.monotonic()
    stdout, stderr = "", ""
    try:
        proc = subprocess.Popen(command, cwd=ROOT, env=env, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, text=True, **process_options)
    except OSError as exc:
        report.update({"pass": False, "exception": repr(exc), "stage": "spawn"})
        with (evidence / "result.json").open("x", encoding="utf-8") as handle:
            json.dump(report, handle, ensure_ascii=False, indent=2)
        print(f"BACCARAT_ACCOUNTING_RUNNER_FAIL spawn: {exc}")
        return 1
    handlers = safe.install_handlers()
    try:
        stdout, stderr = proc.communicate(timeout=args.timeout)
        safe.set_handlers(handlers, True)
        report["process_group_error"] = safe.kill_remaining_group(proc)
    except BaseException as exc:
        safe.set_handlers(handlers, True)
        stdout, stderr, report["process_group_error"] = safe.terminate_tree(proc)
        report["exception"] = repr(exc)
    finally:
        safe.set_handlers(handlers, False)
    for name, output in (("stdout.log", stdout), ("stderr.log", stderr)):
        with (evidence / name).open("x", encoding="utf-8") as handle:
            handle.write(output)
    engine_path = evidence / "godot.log"
    engine = engine_path.read_text(errors="replace") if engine_path.exists() else ""
    report.update(exit=proc.returncode, seconds=time.monotonic() - started,
                  inputs_after={path: pin(ROOT / path) for path in INPUTS},
                  real_user_files_after=real_user_pins(parent),
                  status_after=git("status", "--porcelain"),
                  head_after=git("rev-parse", "HEAD"))
    report["raw_logs"] = {name: pin(evidence / name) for name in
                          ("stdout.log", "stderr.log", "godot.log")
                          if (evidence / name).is_file()}
    report["error_lines"] = [line for line in (stdout + stderr + engine).splitlines()
                             if safe.FAILURE.search(line) or "BACCARAT_ACCOUNTING_CHECK_FAIL" in line
                             or "BACCARAT_ACCOUNTING_ASSERT_FAIL" in line]
    storage, report["storage_error"] = safe.validated_storage(stdout, qa_path)
    report["marker_exact"] = [line for line in stdout.splitlines() if
                              line.startswith("BACCARAT_ACCOUNTING_CHECK_OK")] == [EXPECTED_SUCCESS]
    report["case_rows"] = []
    report["case_parse_errors"] = []
    for line in stdout.splitlines():
        if line.startswith("BACCARAT_ACCOUNTING_CASE="):
            try:
                report["case_rows"].append(json.loads(line.split("=", 1)[1]))
            except ValueError as exc:
                report["case_parse_errors"].append(str(exc))
    report["inputs_unchanged"] = report["inputs_before"] == report["inputs_after"]
    report["real_user_files_unchanged"] = users_before == report["real_user_files_after"]
    report["case_rows_valid"] = case_rows_valid(report["case_rows"])
    report["pass"] = (proc.returncode == 0 and not report.get("exception")
                      and not report["process_group_error"] and not report["error_lines"]
                      and bool(engine) and report["marker_exact"] and storage == qa_path
                      and not report["case_parse_errors"] and report["case_rows_valid"]
                      and report["inputs_unchanged"] and report["real_user_files_unchanged"]
                      and report["status_before"] == report["status_after"]
                      and report["head"] == report["head_after"])
    report["storage_retained"] = True  # Never delete user data, even on a passing run.
    with (evidence / "result.json").open("x", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)
    print(json.dumps({"pass": report["pass"], "exit": proc.returncode,
                      "cases": len(report["case_rows"]), "errors": report["error_lines"],
                      "users_unchanged": report["real_user_files_unchanged"]}))
    return 0 if report["pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
