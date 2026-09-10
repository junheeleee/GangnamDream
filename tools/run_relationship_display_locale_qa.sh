#!/usr/bin/env bash
set -euo pipefail
# Fresh user:// before autoloads; never touch or clean player storage.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 - "${script_dir}/.." "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, tempfile

root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Isolated relationship display actual-caller component")
parser.add_argument("--godot", default=os.environ.get("GODOT"))
parser.add_argument("--timeout", type=int, default=180)
args = parser.parse_args(sys.argv[2:])
godot = args.godot or shutil.which("godot") or shutil.which("godot4")
if not godot:
    parser.error("Godot required: set GODOT or --godot")
if not 1 <= args.timeout <= 300:
    parser.error("--timeout must be 1..300 seconds")
scene_path = root / "tools/RelationshipDisplayLocaleCheck.tscn"
scene = scene_path.read_text(encoding="utf-8")
match = re.search(r'^script/source = (".*")$', scene, re.MULTILINE)
if match is None:
    parser.error("embedded test source missing")
script = json.loads(match.group(1))
if not re.search(r"(?m)^const FIXTURE_APPROVED := true$", script):
    parser.error("reviewed fixture not frozen; no engine launched")
# Import only existing platform namespace/process/storage helpers; no self-test.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    "relationship_display_isolation", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("cannot determine isolated userdata parent")
namespace = safe.PREFIX + secrets.token_hex(16)
qa_user = parent / namespace
if os.path.lexists(qa_user):
    parser.error("refusing pre-existing QA namespace")
evidence = Path(tempfile.mkdtemp(prefix="gangnam-relationship-display-"))
command = [godot, "--headless", "--path", str(root), "--max-fps", "60",
           "--resolution", "1280x800", "--audio-driver", "Dummy", "--quit-after", "10800",
           "--log-file", str(evidence / "godot.log"),
           "--script", "res://tools/StoryNameplateBootstrap.gd",
           "--scene", "res://tools/RelationshipDisplayLocaleCheck.tscn"]
env = os.environ.copy()
env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
inputs = ["scenes/MainGame.gd", "systems/RelationshipSystem.gd",
          "tools/RelationshipDisplayLocaleCheck.tscn", "tools/run_relationship_display_locale_qa.sh",
          "tools/StoryNameplateBootstrap.gd", "tools/run_routine_background_context_check.py",
          "autoloads/GameState.gd", "autoloads/LocaleManager.gd", "autoloads/SaveManager.gd",
          "locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json", "project.godot"]
def pins():
    return {p: {"bytes": (root / p).stat().st_size,
                "sha256": hashlib.sha256((root / p).read_bytes()).hexdigest()} for p in inputs}
before = pins()
result = {"command": command, "expected_user_dir": str(qa_user), "status": "initializing",
          "source_before": before, "headless_component": True, "rendered_claim": False}
print("RELATIONSHIP_DISPLAY_EVIDENCE=" + str(evidence), flush=True)
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
    result.update(status="interrupted", exception=repr(exc))
finally:
    safe.set_handlers(handlers, False)
(evidence / "stdout.log").write_text(stdout, encoding="utf-8")
(evidence / "stderr.log").write_text(stderr, encoding="utf-8")
engine_file = evidence / "godot.log"
engine = engine_file.read_text(encoding="utf-8", errors="replace") if engine_file.is_file() else ""
combined = stdout + "\n" + stderr + "\n" + engine
marker = "RELATIONSHIP_DISPLAY_CHECK_OK cases=65 locales=5 names=14 parents=6 isolation=preautoload rendered=0"
markers = re.findall(r"(?m)^RELATIONSHIP_DISPLAY_CHECK_OK[^\r\n]*$", stdout)
failure_pattern = re.compile(
    r"RELATIONSHIP_DISPLAY_CHECK_FAIL|STORY_NAMEPLATE_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use",
    re.IGNORECASE)
storage, storage_error = safe.validated_storage(stdout, qa_user)
case_lines = re.findall(r"(?m)^RELATIONSHIP_DISPLAY_CASE (.+)$", stdout)
cases = []
try:
    cases = [json.loads(line) for line in case_lines]
except ValueError as exc:
    result["case_json_error"] = repr(exc)
locales = ["ko", "en", "ja", "zh-CN", "zh-TW"]
families = ["names14", "exact_custom", "parents_shared", "first_name", "save_language",
            "vip_populated", "vip_empty", "vip_no_ap", "ended", "passive_romantic",
            "passive_mentor", "passive_business", "passive_family"]
expected_ids = {locale + "/" + family for locale in locales for family in families}
after = pins()
passed = (result["status"] == "completed" and proc.returncode == 0 and not group_error
          and engine_file.is_file() and not failure_pattern.search(combined)
          and markers == [marker] and storage is not None and not storage_error
          and re.findall(r"(?m)^RELATIONSHIP_QA_STATE_RESTORED=(.*)$", stdout) == ["1"]
          and len(cases) == 65 and {c.get("id") for c in cases} == expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True for c in cases)
          and before == after)
result.update(status="passed" if passed else "failed", engine_exit=proc.returncode,
              group_error=group_error, storage_error=storage_error, cases=cases,
              markers=markers, source_after=after, source_files_unchanged=before == after,
              storage_retained=str(qa_user), whole_self_or_audit=False,
              boundary="Fixed actual-caller regression only; no full-panel/render/native/full-game GO.")
(evidence / "runner_result.json").write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(stdout, end="" if stdout.endswith("\n") else "\n")
if stderr:
    print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
print("RELATIONSHIP_DISPLAY_RUNNER_" + ("OK" if passed else "FAIL")
      + " evidence=" + str(evidence) + " isolated_storage_retained=" + str(qa_user))
raise SystemExit(0 if passed else 1)
PY
