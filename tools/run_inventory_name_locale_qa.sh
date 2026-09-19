#!/usr/bin/env bash
set -euo pipefail
# Fresh user namespace before autoloads; no player storage is opened.
script_dir="$(cd "$(dirname "$0")" && pwd)"
python3 - "$script_dir/.." "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, tempfile, time
root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Isolated stored inventory-name locale component")
parser.add_argument("--godot", default=os.environ.get("GODOT"))
parser.add_argument("--timeout", type=int, default=180)
args = parser.parse_args(sys.argv[2:])
godot = args.godot or shutil.which("godot") or shutil.which("godot4")
if not godot or not 1 <= args.timeout <= 300:
    parser.error("Godot and --timeout 1..300 are required")
scene = root / "tools/InventoryNameLocaleCheck.tscn"
match = re.search(r'^script/source = (".*")$', scene.read_text(), re.M)
if match is None or not re.search(r"(?m)^const FIXTURE_APPROVED := true$", json.loads(match[1])):
    parser.error("independently reviewed fixture not approved; engine not launched")
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("inventory_isolation", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("cannot determine isolated userdata parent")
namespace = safe.PREFIX + secrets.token_hex(16)
qa_user = parent / namespace
if os.path.lexists(qa_user):
    parser.error("refusing pre-existing QA namespace")
evidence = Path(tempfile.mkdtemp(prefix="gangnam-inventory-name-"))
inputs = [
    "tools/InventoryNameLocaleCheck.tscn", "tools/run_inventory_name_locale_qa.sh",
    "tools/StoryNameplateBootstrap.gd", "tools/run_routine_background_context_check.py",
    "scenes/MainGame.gd", "scenes/MainGame.tscn", "autoloads/DataRegistry.gd",
    "autoloads/LocaleManager.gd", "autoloads/GameState.gd", "autoloads/SaveManager.gd",
    "autoloads/MetaProgression.gd", "autoloads/ModLoader.gd", "systems/BuildFlavor.gd",
    "content/items.json", "locale/catalog_ja.json", "locale/catalog_zh-CN.json",
    "locale/catalog_zh-TW.json", "locale/ui_ja.json", "locale/ui_zh-CN.json",
    "locale/ui_zh-TW.json", "project.godot"]
def pin(path):
    raw = path.read_bytes()
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
def pins():
    return {p: pin(root / p) for p in inputs}
before = pins()
command = [godot, "--headless", "--path", str(root), "--max-fps", "60",
    "--resolution", "1280x800", "--audio-driver", "Dummy", "--quit-after", "10800",
    "--log-file", str(evidence / "godot.log"), "--script", "res://tools/StoryNameplateBootstrap.gd",
    "--scene", "res://tools/InventoryNameLocaleCheck.tscn"]
env = os.environ.copy()
env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
result = {"command": command, "status": "initializing", "source_before": before,
    "expected_user_dir": str(qa_user), "headless_component": True, "rendered_claim": False}
print("INVENTORY_NAME_EVIDENCE=" + str(evidence), flush=True)
started = time.monotonic()
isolation = ({"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True})
group_error = None
with (evidence / "stdout.log").open("xb") as out, (evidence / "stderr.log").open("xb") as err:
    proc = subprocess.Popen(command, cwd=root, env=env, stdout=out, stderr=err, **isolation)
    result["pid"] = proc.pid
    handlers = safe.install_handlers()
    try:
        proc.communicate(timeout=args.timeout)
        safe.set_handlers(handlers, True)
        group_error = safe.kill_remaining_group(proc)
        result["status"] = "completed"
    except BaseException as exc:
        safe.set_handlers(handlers, True)
        _, _, group_error = safe.terminate_tree(proc)
        result.update(status="interrupted", exception=repr(exc))
    finally:
        safe.set_handlers(handlers, False)
# Actual bytes are already retained before decoding/postreads.
result.update(engine_exit=proc.returncode, seconds=time.monotonic()-started, group_error=group_error)
(evidence / "execution_checkpoint.json").write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
errors = []
def stream(name):
    path = evidence / name
    if not path.is_file():
        errors.append("missing " + name)
        return ""
    try:
        return path.read_bytes().decode("utf-8")
    except UnicodeError:
        errors.append("invalid UTF-8 " + name)
        return path.read_bytes().decode("utf-8", errors="replace")
stdout, stderr, engine = [stream(p) for p in ("stdout.log", "stderr.log", "godot.log")]
failure_pattern = re.compile(r"INVENTORY_NAME_CHECK_FAIL|STORY_NAMEPLATE_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use", re.I)
error_lines = [line for line in (stdout+"\n"+stderr+"\n"+engine).splitlines() if failure_pattern.search(line)]
storage, storage_error = safe.validated_storage(stdout, qa_user)
locales = ["ko", "en", "ja", "zh-CN", "zh-TW"]
expected_ids = [l + "/" + f for l in locales for f in ("aliases", "stored_edges", "gifts", "acquisition")]
expected_ids += ["switch/" + l for l in ["en", "ja", "zh-CN", "zh-TW", "ko", "ko/same"]]
expected_ids += ["live/" + f for f in ["string", "blank", "number", "alias", "missing", "removed",
    "restored", "same_language", "changed_language", "custom_changed_language"]]
expected_ids += ["preset/" + f for f in ["settings_only", "notify_not_reload", "changed_language",
    "stored_old_preset", "live_and_pending", "disabled_on_language", "explicit_reload_getter"]]
expected_ids += ["loader/preset_unknown_id", "loader/fallback_and_types", "loader/preset_types", "storage/save",
    "storage/language_preserves_saved_bytes", "storage/load", "storage/loaded_display_immutable", "teardown/restored_memory"]
assert len(expected_ids) == 51 and len(set(expected_ids)) == 51
cases = []
try:
    cases = [json.loads(s) for s in re.findall(r"(?m)^INVENTORY_NAME_CASE (.+)$", stdout)]
except ValueError as exc:
    errors.append("case JSON: " + str(exc))
marker = "INVENTORY_NAME_CHECK_OK groups=51 locales=5 same_panel=1 isolation=preautoload rendered=0"
markers = re.findall(r"(?m)^INVENTORY_NAME_CHECK_OK[^\r\n]*$", stdout)
after = pins()
passed = (result["status"] == "completed" and proc.returncode == 0 and not group_error
    and not errors and not error_lines and storage is not None and not storage_error
    and markers == [marker] and [c.get("id") for c in cases] == expected_ids
    and all(c.get("pass") is True and c.get("state_ok") is True for c in cases) and before == after)
result.update(status="passed" if passed else "failed", source_after=after,
    inputs_unchanged=before == after, errors=errors, error_lines=error_lines,
    storage_error=storage_error, storage_retained=str(qa_user),
    case_ids=[c.get("id") for c in cases], expected_ids=expected_ids,
    failed_cases=[c.get("id") for c in cases if c.get("pass") is not True], markers=markers,
    streams={p: pin(evidence/p) for p in ("stdout.log","stderr.log","godot.log") if (evidence/p).is_file()},
    boundary="51 finite component groups; nested comparisons are not extra groups. Raw state triplets in stdout.log. JSON load number normalization is separate from typed display preservation. QA files retained; no rendered/native/human/full-product GO.")
(evidence / "runner_result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
print(json.dumps({"status": result["status"], "engine_exit": proc.returncode, "groups": len(cases),
    "failed_cases": result["failed_cases"], "error_lines": error_lines, "errors": errors,
    "storage_error": storage_error, "group_error": group_error, "inputs_unchanged": before == after}, ensure_ascii=False))
print("INVENTORY_NAME_RUNNER_" + ("OK" if passed else "FAIL") + " evidence=" + str(evidence))
raise SystemExit(0 if passed else 1)
PY
