#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec python3 - "${ROOT}" "$@" <<'PY'
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, secrets
import shutil, subprocess, sys, time

sys.dont_write_bytecode = True
root = Path(sys.argv[1]).resolve()
parser = argparse.ArgumentParser(description="Fresh, pre-autoload-isolated trailer capture")
parser.add_argument("language", choices=("ko", "en"))
parser.add_argument("output", nargs="?", type=Path)
parser.add_argument("--timeout", type=int, default=600)
args = parser.parse_args(sys.argv[2:])
if not 1 <= args.timeout <= 1800:
    parser.error("--timeout must be 1..1800 seconds")
for key in ("STORY_NAMEPLATE_QA_NAMESPACE", "GANGNAM_QA_OUT",
            "STORY_DEMO_QA_BOOTSTRAP_NAME", "STORY_DEMO_ALLOW_ISOLATED_QA"):
    if key in os.environ:
        parser.error("refusing inherited QA override: " + key)
output = (args.output or root / "build/trailer/captures" / args.language).absolute()
if any(p.is_symlink() for p in (output, *output.parents)) or output.exists():
    parser.error("output must be a new, non-symlink path; previous captures are retained")
godot = os.environ.get("GODOT") or shutil.which("godot")
if not godot:
    candidate = Path("/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot")
    godot = str(candidate) if candidate.is_file() else None
if not godot or not os.access(godot, os.X_OK):
    parser.error("Godot not found; set GODOT to an executable")
spec = importlib.util.spec_from_file_location("trailer_storage", root / "tools/run_routine_background_context_check.py")
safe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(safe)
parent = safe.user_data_parent()
if parent is None:
    parser.error("unknown Godot user-data parent")
namespace = safe.PREFIX + secrets.token_hex(16)
user_dir = parent / namespace
if os.path.lexists(user_dir):
    parser.error("refusing pre-existing QA namespace")
output.mkdir(parents=True, exist_ok=False)
env = os.environ.copy()
env.update(STORY_NAMEPLATE_QA_NAMESPACE=namespace, GANGNAM_QA_OUT=str(output))
command = [godot, "--path", str(root), "--rendering-driver", "opengl3",
    "--audio-driver", "Dummy", "--resolution", "1920x1080", "--max-fps", "60",
    "--log-file", str(output / "godot.log"),
    "--script", "res://tools/StoryNameplateBootstrap.gd",
    "--scene", "res://tools/ScreenshotQA.tscn", "--", "--qa=trailer", "--lang=" + args.language]
inputs = ["tools/trailer/capture_frames.sh", "tools/StoryNameplateBootstrap.gd",
          "tools/run_routine_background_context_check.py", "tools/ScreenshotQA.gd",
          "tools/ScreenshotQA.tscn", "tools/trailer/timeline.json", "project.godot"]
def pin(path):
    raw = path.read_bytes()
    return {"path": str(path), "size": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
def pins():
    return [pin(root / name) for name in inputs]
before = pins()
record = {"language": args.language, "command": command, "expected_user_dir": str(user_dir),
          "source_before": before, "native_play": False, "human_observation": False,
          "previous_outputs_deleted": False, "status": "starting"}
start = time.monotonic()
errors = []
with (output / "stdout.log").open("xb") as stdout, (output / "stderr.log").open("xb") as stderr:
    isolation = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True}
    process = None
    try:
        process = subprocess.Popen(command, cwd=root, env=env, stdout=stdout, stderr=stderr, **isolation)
    except OSError as exc:
        errors.append("launch failed: " + repr(exc))
    if process is not None:
        record["pid"] = process.pid
        handlers = safe.install_handlers()
        try:
            process.communicate(timeout=args.timeout)
            safe.set_handlers(handlers, True)
            group_error = safe.kill_remaining_group(process)
            if group_error:
                errors.append(group_error)
        except BaseException as exc:
            safe.set_handlers(handlers, True)
            _, _, group_error = safe.terminate_tree(process)
            errors.append(repr(exc))
            if group_error:
                errors.append(group_error)
        finally:
            safe.set_handlers(handlers, False)
record.update(engine_exit=process.returncode if process else None, seconds=round(time.monotonic()-start, 6))
streams = []
for name in ("stdout.log", "stderr.log", "godot.log"):
    path = output / name
    if not path.is_file():
        errors.append("missing " + name)
        streams.append("")
        continue
    raw = path.read_bytes()
    try:
        streams.append(raw.decode("utf-8"))
    except UnicodeError:
        errors.append("invalid UTF-8 " + name)
        streams.append(raw.decode("utf-8", errors="replace"))
record["streams"] = [pin(output/name) for name in ("stdout.log", "stderr.log", "godot.log") if (output/name).is_file()]
stdout = streams[0]
pre = "STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=" + str(user_dir)
done = "SCREENSHOT_QA_DONE scope=trailer lang=" + args.language + " dir=" + str(output)
if re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=[^\r\n]*$", stdout) != [pre]:
    errors.append("exact pre-autoload namespace marker absent/duplicate")
if re.findall(r"(?m)^SCREENSHOT_QA_DONE[^\r\n]*$", stdout) != [done]:
    errors.append("exact trailer completion marker absent/duplicate")
if pre in stdout and done in stdout and stdout.index(pre) > stdout.index(done):
    errors.append("isolation marker follows completion")
failure = re.compile(r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|\bERROR:|"
                     r"STORY_NAMEPLATE_CHECK_FAIL|ObjectDB instances leaked|resources still in use", re.I)
record["error_lines"] = [line for stream in streams for line in stream.splitlines() if failure.search(line)]
if record["error_lines"] or record["engine_exit"] != 0:
    errors.append("engine exit/error/leak check failed")
timeline = json.loads((root / "tools/trailer/timeline.json").read_bytes())
expected = {cut["frame"] for edit in timeline["edits"].values() for cut in edit["cuts"] if cut["frame"] != "@keyart"}
actual = {p.name for p in output.glob("trailer_*.png")}
if actual != expected or len(actual) != 22:
    errors.append("fresh locale PNG roster differs from exact 22 frames")
frames = sorted(output.glob("trailer_*.png"))
if any(p.is_symlink() or not p.is_file() for p in frames):
    errors.append("capture frames must be regular, non-symlink files")
record["frames"] = [pin(p) for p in frames if p.is_file() and not p.is_symlink()]
record["source_after"] = pins()
if record["source_after"] != before:
    errors.append("capture source changed during process")
if not errors:
    check = subprocess.run([sys.executable, str(root / "tools/trailer/trailer_check.py"), "--captures", str(output)], capture_output=True)
    for name, raw in [("check.stdout.log", check.stdout), ("check.stderr.log", check.stderr)]:
        with (output / name).open("xb") as handle:
            handle.write(raw)
    record["check_exit"] = check.returncode
    if check.returncode != 0:
        errors.append("existing PNG/timeline check failed")
record.update(status="failed" if errors else "passed", errors=errors,
              warning_lines=[line for stream in streams for line in stream.splitlines() if "WARNING:" in line],
              storage_retained=str(user_dir))
with (output / "capture-result.json").open("x") as handle:
    json.dump(record, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
print(("TRAILER_CAPTURE_FAIL" if errors else "TRAILER_CAPTURE_OK") + " lang=" + args.language + " dir=" + str(output))
raise SystemExit(1 if errors else 0)
PY
