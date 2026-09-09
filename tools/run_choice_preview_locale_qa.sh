#!/usr/bin/env bash
set -euo pipefail
# Existing bootstrap selects a fresh user:// BEFORE autoloads. No HOME override.
# Keep all test-only storage and logs; never clean or restore player directories.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 - "${script_dir}/.." "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, tempfile

root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Isolated actual choice-preview label component")
parser.add_argument("--godot", default=os.environ.get("GODOT"))
parser.add_argument("--timeout", type=int, default=120)
args = parser.parse_args(sys.argv[2:])
godot = args.godot or shutil.which("godot") or shutil.which("godot4")
if not godot:
    parser.error("Godot required: set GODOT or --godot")
if not 1 <= args.timeout <= 300:
    parser.error("--timeout must be 1..300 seconds")
# Only reuse reviewed platform namespace and process-isolation helpers.
# Importing this module runs neither its scene nor its self-test.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    "choice_preview_isolation", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("cannot determine isolated userdata parent")
namespace = safe.PREFIX + secrets.token_hex(16)
qa_user = parent / namespace
if os.path.lexists(qa_user):
    parser.error("refusing pre-existing QA namespace")
evidence = Path(tempfile.mkdtemp(prefix="gangnam-choice-preview-locale-"))
command = [godot, "--headless", "--path", str(root), "--max-fps", "60",
           "--resolution", "1280x800", "--audio-driver", "Dummy",
           "--quit-after", "7200", "--log-file", str(evidence / "godot.log"),
           "--script", "res://tools/StoryNameplateBootstrap.gd", "--scene",
           "res://tools/ChoicePreviewLocaleCheck.tscn"]
env = os.environ.copy()
env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
result = {"command": command, "expected_user_dir": str(qa_user),
          "status": "initializing", "headless_component": True, "rendered_claim": False,
          "source_files": {}}
for relative in ["scenes/MainGame.gd", "tools/ChoicePreviewLocaleCheck.gd",
                 "tools/ChoicePreviewLocaleCheck.tscn", "tools/StoryNameplateBootstrap.gd",
                 "autoloads/LocaleManager.gd", "locale/ui_ja.json",
                 "locale/ui_zh-CN.json", "locale/ui_zh-TW.json"]:
    raw = (root / relative).read_bytes()
    result["source_files"][relative] = {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
print("CHOICE_PREVIEW_EVIDENCE=" + str(evidence), flush=True)
isolation = ({"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
             if os.name == "nt" else {"start_new_session": True})
proc = subprocess.Popen(command, cwd=root, env=env, stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE, text=True, encoding="utf-8",
                        errors="replace", **isolation)
result["pid"] = proc.pid
handlers = safe.install_handlers()
try:
    stdout, stderr = proc.communicate(timeout=args.timeout)
    safe.set_handlers(handlers, True)
    group_error = safe.kill_remaining_group(proc)
    result["status"] = "completed"
except BaseException as exc:
    safe.set_handlers(handlers, True)
    stdout, stderr, group_error = safe.terminate_tree(proc)
    result["status"] = "interrupted"
    result["exception"] = repr(exc)
finally:
    safe.set_handlers(handlers, False)
(evidence / "stdout.log").write_text(stdout, encoding="utf-8")
(evidence / "stderr.log").write_text(stderr, encoding="utf-8")
engine_file = evidence / "godot.log"
engine = engine_file.read_text(encoding="utf-8", errors="replace") if engine_file.is_file() else ""
combined = stdout + "\n" + stderr + "\n" + engine
marker = ("CHOICE_PREVIEW_LOCALE_CHECK_OK cases=64 base=50 additional=14 locales=5 "
          "caller_labels=64 state_unchanged=64 isolation=preautoload rendered=0")
markers = re.findall(r"(?m)^CHOICE_PREVIEW_LOCALE_CHECK_OK[^\r\n]*$", stdout)
failure_pattern = re.compile(
    r"CHOICE_PREVIEW_LOCALE_CHECK_FAIL|SCRIPT ERROR|Parse Error|Compile Error|"
    r"Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use",
    re.IGNORECASE)
storage, storage_error = safe.validated_storage(stdout, qa_user)
case_lines = re.findall(r"(?m)^CHOICE_PREVIEW_CASE (.+)$", stdout)
cases = []
try:
    cases = [json.loads(line) for line in case_lines]
except ValueError as exc:
    result["case_json_error"] = repr(exc)
source_same = all(
    hashlib.sha256((root / path).read_bytes()).hexdigest() == fingerprint["sha256"]
    for path, fingerprint in result["source_files"].items())
passed = (result["status"] == "completed" and proc.returncode == 0
          and not group_error and engine_file.is_file()
          and not failure_pattern.search(combined) and markers == [marker]
          and storage is not None and not storage_error
          and len(cases) == 64 and len({c.get("id") for c in cases}) == 64
          and all(c.get("pass") is True for c in cases) and source_same)
result.update(status="passed" if passed else "failed", engine_exit=proc.returncode,
              group_error=group_error, storage_error=storage_error,
              cases=cases, markers=markers, source_files_unchanged=source_same,
              storage_retained=str(qa_user), whole_self_or_audit=False)
(evidence / "runner_result.json").write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(stdout, end="" if stdout.endswith("\n") else "\n")
if stderr:
    print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
print("CHOICE_PREVIEW_RUNNER_" + ("OK" if passed else "FAIL")
      + " evidence=" + str(evidence) + " isolated_storage_retained=" + str(qa_user))
raise SystemExit(0 if passed else 1)
PY
