#!/usr/bin/env bash
set -euo pipefail
# New component. Existing inventory/gift/bootstrap/process helpers stay unchanged.
script_dir="$(cd "$(dirname "$0")" && pwd)"
python3 - "$script_dir/.." "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, tempfile, time

root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Isolated actual new-run log localization component")
parser.add_argument("--godot", default=os.environ.get("GODOT"))
parser.add_argument("--timeout", type=int, default=180)
args = parser.parse_args(sys.argv[2:])
godot = args.godot or shutil.which("godot") or shutil.which("godot4")
if not godot or not 1 <= args.timeout <= 300:
    parser.error("Godot and --timeout 1..300 are required")
scene = root / "tools/NewRunLogLocaleCheck.tscn"
match = re.search(r'^script/source = (".*")$', scene.read_text(), re.M)
if match is None or not re.search(r"(?m)^const FIXTURE_APPROVED := true$", json.loads(match[1])):
    parser.error("independently reviewed fixture not approved; engine not launched")

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("new_run_log_isolation", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("cannot determine isolated userdata parent")
namespace = safe.PREFIX + secrets.token_hex(16)
qa_user = parent / namespace
if os.path.lexists(qa_user):
    parser.error("refusing pre-existing QA namespace")
evidence = Path(tempfile.mkdtemp(prefix="gangnam-new-run-log-"))
inputs = [
    "tools/NewRunLogLocaleCheck.tscn", "tools/run_new_run_log_locale_qa.sh",
    "tools/StoryNameplateBootstrap.gd", "tools/run_routine_background_context_check.py",
    "scenes/MainGame.gd", "scenes/MainGame.tscn", "autoloads/DataRegistry.gd",
    "autoloads/LocaleManager.gd", "autoloads/GameState.gd", "autoloads/SaveManager.gd",
    "autoloads/MetaProgression.gd", "autoloads/ModLoader.gd", "systems/BuildFlavor.gd",
    "content/items.json", "locale/catalog_ja.json", "locale/catalog_zh-CN.json",
    "locale/catalog_zh-TW.json", "locale/ui_ja.json", "locale/ui_zh-CN.json",
    "locale/ui_zh-TW.json", "project.godot", "autoloads/ImageRegistry.gd",
    "systems/InventorySystem.gd", "autoloads/AudioManager.gd", "autoloads/BGMPlayer.gd",
    "tools/GiftCaptionLocaleCheck.tscn", "tools/run_gift_caption_locale_qa.sh",
    "autoloads/EventManager.gd", "systems/BuildInfo.gd", "systems/PhoneSystem.gd",
    "systems/Chapter5CausalRoute.gd", "systems/Chapter5FinaleRoute.gd",
    "content/assets.json", "content/jobs.json",
]
def pin(path):
    raw = path.read_bytes()
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
def pins():
    return {path: pin(root / path) for path in inputs}

before = pins()
command = [godot, "--headless", "--path", str(root), "--max-fps", "60",
    "--resolution", "1280x800", "--audio-driver", "Dummy", "--quit-after", "18000",
    "--log-file", str(evidence / "godot.log"), "--script", "res://tools/StoryNameplateBootstrap.gd",
    "--scene", "res://tools/NewRunLogLocaleCheck.tscn"]
env = os.environ.copy()
env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
result = {"command": command, "status": "initializing", "source_before": before,
    "expected_user_dir": str(qa_user), "headless_component": True, "rendered_claim": False}
print("NEW_RUN_LOG_EVIDENCE=" + str(evidence), flush=True)
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
failure_pattern = re.compile(r"NEW_RUN_LOG_CHECK_FAIL|STORY_NAMEPLATE_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use", re.I)
error_lines = [line for line in (stdout+"\n"+stderr+"\n"+engine).splitlines() if failure_pattern.search(line)]
storage, storage_error = safe.validated_storage(stdout, qa_user)
def records(marker):
    rows = []
    for value in re.findall(r"(?m)^" + re.escape(marker) + r" (.+)$", stdout):
        try:
            rows.append(json.loads(value))
        except ValueError as exc:
            errors.append(marker + ": " + str(exc))
    return rows

cases = records("NEW_RUN_LOG_CASE")
setups = records("NEW_RUN_LOG_SETUP")
summaries = records("NEW_RUN_LOG_SUMMARY")
restores = records("NEW_RUN_LOG_STATE_RESTORED")
providers = records("NEW_RUN_LOG_PROVIDER_RESTORED")
locales = ("ko", "en", "ja", "zh-CN", "zh-TW")
pool = ("investment", "jobs", "social", "health", "relationship", "gambling", "finance")
modes = ("parent_missing", "argument_missing", "both_missing", "community_both", "community_argument", "invalid_parent")
expected_ids, expected_provider_ids = [], []
parent_sources = ("다시 시작한 아침. 출발점은 %s였다.", "이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.")
expected_warnings = []
for locale in locales[2:]:
    for index, source in enumerate(parent_sources):
        old_signature = '["s"]' if index == 0 else '["s", "s"]'
        new_signature = '["d"]' if index == 0 else '["d", "s"]'
        expected_warnings.append("I18N_UI_FORMAT_REJECT lang=%s key=%s reason=localized %s: placeholder signature mismatch %s != %s"
            % (locale, source, locale, old_signature, new_signature))
setup_ok = len(setups) == 1 and isinstance(setups[0], dict)
summary_ok = len(summaries) == 1 and isinstance(summaries[0], dict)
if setup_ok:
    setup = setups[0]
    coverage = setup.get("coverage", [])
    covered, seeds = set(), []
    for row in coverage:
        if not isinstance(row, dict):
            setup_ok = False
            continue
        value, pair = row.get("seed"), row.get("pair", [])
        if (type(value) is not int or not 0 <= value < 128 or len(pair) != 2
                or len(set(pair)) != 2 or not set(pair) <= set(pool) or not set(pair)-covered):
            setup_ok = False
        seeds.append(value)
        covered.update(pair)
    setup_ok = (setup_ok and 4 <= len(coverage) <= 7 and covered == set(pool)
        and seeds == sorted(set(seeds)) and not setup.get("precondition_errors") and not setup.get("oracle_errors"))
    for locale in locales:
        expected_ids.append(locale + "/default_new_run")
        expected_ids.extend(locale + "/known_" + str(i) for i in range(2))
        expected_ids.extend(locale + "/unknown_" + str(i) for i in range(3))
        expected_ids.extend(locale + "/category_seed_" + str(value) for value in seeds)
    for locale in locales[2:]:
        for parent_name in ("profile", "theme"):
            expected_provider_ids.extend(locale + "/" + parent_name + "/" + mode for mode in modes)
        expected_provider_ids.append(locale + "/theme/eager_unselected")
    expected_ids += expected_provider_ids
    expected_ids.extend(locale + "/existing_record_reader" for locale in locales)
    setup_ok = setup_ok and setup.get("expected_ids") == expected_ids
    expected_counts = dict(default_new_runs=5, known_profile_compositions=10,
        unknown_profiles=15, category_probes=5*len(coverage), provider_probes=39, readers=5)
    setup_ok = setup_ok and setup.get("counts") == expected_counts
if summary_ok:
    summary = summaries[0]
    summary_ok = (summary.get("groups") == len(expected_ids) and summary.get("ids") == expected_ids
        and summary.get("expected_ids") == expected_ids and summary.get("normal_base") is True
        and summary.get("provider_probes") == 39 and summary.get("effective_provider_probes") == 39
        and summary.get("failures") == [] and summary.get("io_errors") == []
        and summary.get("expected_warnings") == expected_warnings)
# Expected rejection warnings are a separate bounded observation, never removed
# from raw streams or from the ERROR/parse/script scan above.
warning_pattern = re.compile(r"(?m)^\s*WARNING: (I18N_UI_FORMAT_REJECT lang=[^\r\n]+)\s*$")
ansi = re.compile(r"\x1b\[[0-9;]*m")
process_warnings = warning_pattern.findall(ansi.sub("", stdout + "\n" + stderr))
engine_warnings = warning_pattern.findall(ansi.sub("", engine))
warning_ok = process_warnings == expected_warnings and engine_warnings == expected_warnings
provider_ok = (len(providers) == 39 and [x.get("id") for x in providers] == expected_provider_ids
    and all(x.get("exact") is True and x.get("object_identity") is True
            and x.get("before_sha256") == x.get("after_sha256") for x in providers))
restore_ok = (len(restores) == 1 and restores[0].get("exact") is True
    and restores[0].get("script_variables_exact") is True and restores[0].get("io_errors") == []
    and setup_ok and restores[0].get("rng", {}).get("following") == setups[0].get("rng_checkpoint", {}).get("following"))
case_ids = [x.get("id") for x in cases if isinstance(x, dict)]
case_ok = (case_ids == expected_ids and len(cases) == len(expected_ids) and len(set(case_ids)) == len(case_ids)
    and all(isinstance(x, dict) and x.get("pass") is True and x.get("state_ok") is True
            and x.get("typed_state_exact") is True and x.get("display_ok") is True and x.get("io_errors") == [] for x in cases))
marker = ("NEW_RUN_LOG_CHECK_OK groups=%d locales=5 provider_probes=39 expected_warnings=6 "
    "isolation=preautoload rendered=0") % len(expected_ids)
markers = re.findall(r"(?m)^NEW_RUN_LOG_CHECK_OK[^\r\n]*$", stdout)
after = pins()
passed = (result["status"] == "completed" and proc.returncode == 0 and not group_error and not errors
    and not error_lines and storage is not None and not storage_error and setup_ok and summary_ok
    and warning_ok and provider_ok and restore_ok and case_ok and markers == [marker] and before == after)
result.update(status="passed" if passed else "failed", source_after=after, inputs_unchanged=before == after,
    errors=errors, error_lines=error_lines, storage_error=storage_error, storage_retained=str(qa_user),
    setup_ok=setup_ok, summary_ok=summary_ok, case_ok=case_ok, restore_ok=restore_ok, provider_ok=provider_ok,
    warning_ok=warning_ok, expected_warnings=expected_warnings, process_warnings=process_warnings,
    engine_warnings=engine_warnings, case_ids=case_ids, expected_ids=expected_ids,
    failed_cases=[x.get("id") for x in cases if isinstance(x, dict) and x.get("pass") is not True], markers=markers,
    streams={p: pin(evidence/p) for p in ("stdout.log", "stderr.log", "godot.log") if (evidence/p).is_file()},
    boundary="Independent seed coverage plus finite normal/provider/reader groups. Full typed serialized game and script variables, settings/file bytes in case triplets. Full cache/registry hashes are not full-state snapshots. Actual save setup, no load_game/legacy migration. No rendered/native/human claim.")
(evidence / "runner_result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
print(json.dumps({"status": result["status"], "engine_exit": proc.returncode, "groups": len(cases),
    "failed_cases": result["failed_cases"], "errors": errors, "error_lines": error_lines,
    "warning_ok": warning_ok, "provider_ok": provider_ok, "restore_ok": restore_ok,
    "inputs_unchanged": before == after, "storage_error": storage_error, "group_error": group_error}, ensure_ascii=False))
print("NEW_RUN_LOG_RUNNER_" + ("OK" if passed else "FAIL") + " evidence=" + str(evidence))
raise SystemExit(0 if passed else 1)
PY
