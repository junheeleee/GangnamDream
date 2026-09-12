#!/usr/bin/env bash
set -euo pipefail
# Fresh user:// before autoloads; never touch or clean player storage.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 - "${script_dir}/.." "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, tempfile

root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Isolated meta title actual-caller component")
parser.add_argument("--godot", default=os.environ.get("GODOT"))
parser.add_argument("--timeout", type=int, default=180)
args = parser.parse_args(sys.argv[2:])
godot = args.godot or shutil.which("godot") or shutil.which("godot4")
if not godot:
    parser.error("Godot required: set GODOT or --godot")
if not 1 <= args.timeout <= 300:
    parser.error("--timeout must be 1..300 seconds")
scene_path = root / "tools/MetaTitleLocaleCheck.tscn"
scene = scene_path.read_text(encoding="utf-8")
match = re.search(r'^script/source = (".*")$', scene, re.MULTILINE)
if match is None:
    parser.error("embedded test source missing")
script = json.loads(match.group(1))
if not re.search(r"(?m)^const FIXTURE_APPROVED := true$", script):
    parser.error("reviewed fixture not frozen; no engine launched")
if not re.search(r"(?m)^const NEXT_FIXTURE_APPROVED := true$", script):
    parser.error("reviewed next20 fixture not frozen; no engine launched")
if not re.search(r"(?m)^const A11_FIXTURE_APPROVED := true$", script):
    parser.error("reviewed A11 fixture not frozen; no engine launched")
if not re.search(r"(?m)^const MG9_FIXTURE_APPROVED := true$", script):
    parser.error("reviewed MG9 fixture not frozen; no engine launched")
if not re.search(r"(?m)^const PARENT_FIXTURE_APPROVED := true$", script):
    parser.error("reviewed parent20 fixture not frozen; no engine launched")
# Import only existing platform namespace/process/storage helpers; no self-test.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    "meta_title_isolation", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("cannot determine isolated userdata parent")
namespace = safe.PREFIX + secrets.token_hex(16)
qa_user = parent / namespace
if os.path.lexists(qa_user):
    parser.error("refusing pre-existing QA namespace")
evidence = Path(tempfile.mkdtemp(prefix="gangnam-meta-title-"))
command = [godot, "--headless", "--path", str(root), "--max-fps", "60",
           "--resolution", "1280x800", "--audio-driver", "Dummy", "--quit-after", "10800",
           "--log-file", str(evidence / "godot.log"),
           "--script", "res://tools/StoryNameplateBootstrap.gd",
           "--scene", "res://tools/MetaTitleLocaleCheck.tscn"]
env = os.environ.copy()
env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
inputs = [
    "scenes/MainGame.gd",
    "autoloads/MetaProgression.gd",
    "autoloads/GameState.gd",
    "autoloads/LocaleManager.gd",
    "autoloads/SaveManager.gd",
    "autoloads/DataRegistry.gd",
    "systems/BuildFlavor.gd",
    "content/meta/default_meta.json",
    "ui_components/NotificationToast.gd",
    "tools/MetaTitleLocaleCheck.tscn",
    "tools/run_meta_title_locale_qa.sh",
    "tools/StoryNameplateBootstrap.gd",
    "tools/run_routine_background_context_check.py",
    "locale/ui_ja.json",
    "locale/ui_zh-CN.json",
    "locale/ui_zh-TW.json",
    "project.godot",
    "tools/RelationshipPanelLocaleCheck.tscn",
    "tools/run_relationship_panel_locale_qa.sh"
]
def pins():
    return {p: {"bytes": (root / p).stat().st_size,
                "sha256": hashlib.sha256((root / p).read_bytes()).hexdigest()} for p in inputs}
before = pins()
result = {"command": command, "expected_user_dir": str(qa_user), "status": "initializing",
          "source_before": before, "headless_component": True, "rendered_claim": False}
print("META_TITLE_EVIDENCE=" + str(evidence), flush=True)
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
marker = "META_TITLE_CHECK_OK cases=100 locales=5 selected=9 unselected=41 conditions=20 shared_readers=2 isolation=preautoload rendered=0"
markers = re.findall(r"(?m)^META_TITLE_CHECK_OK[^\r\n]*$", stdout)
next_marker = "META_TITLE_NEXT_CHECK_OK cases=100 locales=5 selected=10 preserved=40 conditions=23 isolation=preautoload rendered=0"
next_markers = re.findall(r"(?m)^META_TITLE_NEXT_CHECK_OK[^\r\n]*$", stdout)
a11_marker = "META_TITLE_A11_CHECK_OK cases=110 locales=5 selected=11 preserved=39 conditions=35 shared_rows=4 isolation=preautoload rendered=0"
a11_markers = re.findall(r"(?m)^META_TITLE_A11_CHECK_OK[^\r\n]*$", stdout)
mg9_marker = 'META_TITLE_MG9_CHECK_OK cases=95 locales=5 selected=9 preserved=41 conditions=36 isolation=preautoload rendered=0'
mg9_markers = re.findall(r"(?m)^META_TITLE_MG9_CHECK_OK[^\r\n]*$", stdout)
parent_marker = "META_TITLE_PARENT_CHECK_OK cases=5 locales=5 keys=20 states=2 core_labels=110 isolation=preautoload rendered=0"
parent_markers = re.findall(r"(?m)^META_TITLE_PARENT_CHECK_OK[^\r\n]*$", stdout)
failure_pattern = re.compile(
    r"META_TITLE_CHECK_FAIL|STORY_NAMEPLATE_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use",
    re.IGNORECASE)
storage, storage_error = safe.validated_storage(stdout, qa_user)
case_lines = re.findall(r"(?m)^META_TITLE_CASE (.+)$", stdout)
cases = []
next_cases = []
a11_cases = []
mg9_cases = []
parent_cases = []
try:
    cases = [json.loads(line) for line in case_lines]
    next_cases = [json.loads(line) for line in re.findall(r"(?m)^META_TITLE_NEXT_CASE (.+)$", stdout)]
    a11_cases = [json.loads(line) for line in re.findall(r"(?m)^META_TITLE_A11_CASE (.+)$", stdout)]
    mg9_cases = [json.loads(line) for line in re.findall(r"(?m)^META_TITLE_MG9_CASE (.+)$", stdout)]
    parent_cases = [json.loads(line) for line in re.findall(r"(?m)^META_TITLE_PARENT_CASE (.+)$", stdout)]
except ValueError as exc:
    result["case_json_error"] = repr(exc)
locales = ["ko", "en", "ja", "zh-CN", "zh-TW"]
families = ["selected/gosiwon_survivor","selected/first_move","selected/apartment_life","selected/gangnam_resident","selected/long_gosiwon","selected/first_paycheck","selected/one_year_worker","selected/three_year_worker","selected/long_unemployed","unselected41","unknown_custom","collection_locked","collection_unlocked","condition_boundaries","unlock_return_duplicate","unlock_toast_log","unlock_toast_no_log","ending_cards","language_storage","shared_gosiwon_readers"]
expected_ids = {locale + "/" + family for locale in locales for family in families}
next_families = ["next10/selected/steady_youth","next10/selected/elite_course","next10/selected/outsider_title","next10/selected/dangerous_dreamer","next10/selected/my_own_way","next10/selected/free_spirit","next10/selected/seoul_love","next10/selected/social_king_title","next10/selected/loner_title","next10/selected/stress_survivor","next10/preserved_old9_remaining31","next10/unknown_custom","next10/collection_locked","next10/collection_unlocked","next10/condition_boundaries","next10/unlock_split_duplicate","next10/unlock_toast_log","next10/unlock_toast_no_log","next10/ending_cards","next10/language_storage"]
next_expected_ids = {locale + "/" + family for locale in locales for family in next_families}
a11_families = ["get/first_investment", "get/margin_called", "get/invest_master_title", "get/survived_broke", "get/first_10m_title", "get/first_100m_title", "get/five_runs_title", "get/ten_runs_title", "get/gangnam_dream_title", "get/burnout_survivor", "get/ordinary_end_title", "preserved_old19_remaining20", "unknown_custom", "collection_locked", "collection_unlocked", "condition_boundaries", "unlock_return_duplicate", "unlock_toast_log", "monthly_component_toast_without_game_log", "ending_cached_cards", "language_storage_cached_origin", "shared_gangnam_current_reader"]
a11_expected_ids = {locale + "/a11/" + family for locale in locales for family in a11_families}
mg9_families = ['get/holdem_master_title', 'get/racetrack_master_title', 'get/scalping_master_title', 'get/baccarat_master_title', 'get/blackjack_master_title', 'get/slot_master_title', 'get/roulette_master_title', 'get/bigwheel_master_title', 'get/daisai_master_title', 'preserved_old30_remaining11', 'unknown_custom', 'collection_locked', 'collection_unlocked', 'conditions_and_mastery', 'unlock_return_duplicate', 'unlock_toast_log', 'monthly_component_toast_without_game_log', 'ending_cached_cards', 'language_storage_cached_origin']
mg9_expected_ids = {locale + "/mg9/" + family for locale in locales for family in mg9_families}
parent_expected_ids = {locale + "/title_parent/collection_chrome" for locale in locales}
after = pins()
passed = (result["status"] == "completed" and proc.returncode == 0 and not group_error
          and engine_file.is_file() and not failure_pattern.search(combined)
          and markers == [marker] and storage is not None and not storage_error
          and re.findall(r"(?m)^META_TITLE_STATE_RESTORED=(.*)$", stdout) == ["1"]
          and len(cases) == 100 and {c.get("id") for c in cases} == expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True for c in cases)
          and next_markers == [next_marker]
          and len(next_cases) == 100 and {c.get("id") for c in next_cases} == next_expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True for c in next_cases)
          and a11_markers == [a11_marker]
          and len(a11_cases) == 110 and {c.get("id") for c in a11_cases} == a11_expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True for c in a11_cases)
          and mg9_markers == [mg9_marker]
          and len(mg9_cases) == 95 and {c.get("id") for c in mg9_cases} == mg9_expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True for c in mg9_cases)
          and parent_markers == [parent_marker]
          and len(parent_cases) == 5 and {c.get("id") for c in parent_cases} == parent_expected_ids
          and all(c.get("pass") is True and c.get("state_ok") is True
                  and c.get("details", {}).get("core_label_comparisons") == 22
                  and len(c.get("details", {}).get("states", [])) == 2 for c in parent_cases)
          and before == after)
result.update(status="passed" if passed else "failed", engine_exit=proc.returncode,
              group_error=group_error, storage_error=storage_error, cases=cases,
              markers=markers, next_markers=next_markers, next_cases=next_cases,
              a11_markers=a11_markers, a11_cases=a11_cases,
              mg9_markers=mg9_markers, mg9_cases=mg9_cases,
              parent_markers=parent_markers, parent_cases=parent_cases,
              parent_boundary="Original405 IDs and non-language expectations retained; approved parent20 changes CN/TW40 and JA uncommon12 groups. New5 chrome groups include110 core-label comparisons nested, not110 additional cases. No historical projection of actual parent text.",
              population_boundary="old100 95direct+5history, NEXT100 95direct+5history, A11 105direct+5history; MG9new95 direct. Old310 and new95 distinct; MG9conditions180 nested, not extra cases; priorA11conditions175 unchanged",
              source_after=after, source_files_unchanged=before == after,
              storage_retained=str(qa_user), whole_self_or_audit=False,
              boundary="Fixed actual-caller regression only; no whole-title/UI/render/native/full-game GO.")
(evidence / "runner_result.json").write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(stdout, end="" if stdout.endswith("\n") else "\n")
if stderr:
    print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
print("META_TITLE_RUNNER_" + ("OK" if passed else "FAIL")
      + " evidence=" + str(evidence) + " isolated_storage_retained=" + str(qa_user))
raise SystemExit(0 if passed else 1)
PY
