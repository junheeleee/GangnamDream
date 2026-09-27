#!/usr/bin/env python3
"""Explicit graphical header check with fresh pre-autoload storage and raw evidence.

The audit registry runs only --self-test. Actual render runs require --head,
--output, --language and --size; they never stand in for human or physical QA.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import signal
import struct
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
SIZES = ("1280x800", "1280x720", "960x600")
LANGUAGES = ("ko", "en")
SURFACES = ("home", "language", "home_resized", "story_body", "five_choices",
            "settings", "settings_return", "history", "history_return", "recap")
FATAL = re.compile(r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|resources still in use|STORY_HEADER_.*FAIL|ORDER315_.*FAIL", re.I)
BOOTSTRAP = '''extends SceneTree
func _init() -> void:
	var qa_namespace := OS.get_environment("STORY_DEMO_QA_BOOTSTRAP_NAME")
	var pattern := RegEx.new()
	if pattern.compile("^GangnamDream_StoryDemo_RuntimeQA_[0-9a-f]{32}$") != OK or pattern.search(qa_namespace) == null:
		push_error("ORDER315_BOOTSTRAP_FAIL invalid namespace")
		quit(1)
		return
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting("application/config/custom_user_dir_name", qa_namespace)
	var qa_path := OS.get_user_data_dir()
	if qa_path != OS.get_environment("ORDER315_EXPECTED_USER_PATH") or qa_path.get_file() != qa_namespace or DirAccess.dir_exists_absolute(qa_path) or DirAccess.make_dir_recursive_absolute(qa_path) != OK:
		push_error("ORDER315_BOOTSTRAP_FAIL isolation refused")
		quit(1)
		return
	print("ORDER315_PRE_AUTOLOAD_USER_DIR=%s" % qa_path)
'''
SCENE = '''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://tools/story_header_safe_area_check.gd" id="1"]
[node name="StoryHeaderSafeAreaCheck" type="Node"]
script = ExtResource("1")
'''


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def pin(path: Path) -> dict:
    raw = path.read_bytes()
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def user_base() -> Path:
    if sys.platform == "darwin":
        return Path.home() / "Library/Application Support"
    if sys.platform == "win32":
        return Path(os.environ["APPDATA"])
    return Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))


def users() -> dict:
    result = {}
    for base in (user_base() / "Godot/app_userdata/강남드림", user_base() / "GangnamDream_StoryDemo_v1"):
        if base.is_symlink():
            raise ValueError(f"refusing user directory symlink: {base}")
        files = {}
        if base.exists():
            for path in sorted(base.rglob("*")):
                if path.is_symlink():
                    raise ValueError(f"refusing user file symlink: {path}")
                if path.is_file():
                    files[str(path)] = pin(path)
        result[str(base)] = {"exists": base.exists(), "files": files}
    return result


def exact_marker(stream: str, marker: str) -> bool:
    return stream.splitlines().count(marker) == 1


def png_size(raw: bytes) -> list[int]:
    if len(raw) < 24 or raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise ValueError("invalid PNG header")
    return list(struct.unpack(">II", raw[16:24]))


def self_test() -> int:
    checks = [exact_marker("OK\n", "OK"), not exact_marker("OK\nOK\n", "OK"),
              not exact_marker("prefix OK\n", "OK"), not exact_marker("", "OK")]
    for text in ("SCRIPT ERROR", "ERROR: bad", "ObjectDB instances leaked", "resources still in use",
                 "ORDER315_BOOTSTRAP_FAIL isolation", "STORY_HEADER_SAFE_AREA_CHECK_FAIL geometry"):
        checks.append(bool(FATAL.search(text)))
    checks.append(not FATAL.search("STORY_HEADER_SAFE_AREA_CHECK_OK language=ko size=1280x800"))
    checks.append(png_size(b"\x89PNG\r\n\x1a\n" + b"\0\0\0\rIHDR" + struct.pack(">II", 960, 600)) == [960, 600])
    for raw in (b"", b"not png" * 4):
        try:
            png_size(raw)
            checks.append(False)
        except ValueError:
            checks.append(True)
    checks.append(BOOTSTRAP.index("func _init()") < BOOTSTRAP.index("ProjectSettings.set_setting"))
    checks.append("dir_exists_absolute(qa_path)" in BOOTSTRAP and "EXPECTED_USER_PATH" in BOOTSTRAP)
    print(f"STORY_HEADER_RUNNER_SELF_TEST_{'OK' if all(checks) else 'FAIL'} cases={len(checks)}")
    return 0 if all(checks) else 1


def run(args: argparse.Namespace) -> int:
    expected = git("rev-parse", args.head)
    if git("rev-parse", "HEAD") != expected or git("status", "--porcelain"):
        raise ValueError("render check requires the declared clean HEAD")
    output = Path(args.output).absolute()
    if not output.is_relative_to(ROOT / ".git/full-game-localization") or output.exists():
        raise ValueError("output must be a new directory under .git/full-game-localization")
    # Resolve ancestors before creation; never let output escape via a symlink.
    if output.resolve() != output:
        raise ValueError("output symlink/parent traversal refused")
    godot = args.godot or os.environ.get("GODOT") or shutil.which("godot")
    if not godot or not Path(godot).is_file():
        raise ValueError("provide an existing Godot binary with --godot or GODOT")
    output.mkdir(parents=True)
    for name, content in (("bootstrap.gd", BOOTSTRAP), ("screen.tscn", SCENE)):
        with (output / name).open("x") as handle:
            handle.write(content)
    paths = [p for p in git("ls-files", "-z").split("\0") if p and (
        p.startswith(("autoloads/", "systems/", "scenes/", "playtests/", "content/", "locale/", "tools/"))
        or p in ("project.godot", "docs/human_gates.json"))]
    paths += [str((output / name).relative_to(ROOT)) for name in ("bootstrap.gd", "screen.tscn")]
    source_pins = lambda: {path: pin(ROOT / path) for path in paths}
    namespace = "GangnamDream_StoryDemo_RuntimeQA_" + secrets.token_hex(16)
    storage = user_base() / namespace
    if os.path.lexists(storage):
        raise ValueError("fresh storage collision")
    env = os.environ.copy()
    for key in ("STORY_DEMO_NATIVE_PROBE_PATH", "ORDER124_NATIVE_PROBE_PATH"):
        env.pop(key, None)
    env.update(STORY_DEMO_QA_BOOTSTRAP_NAME=namespace, STORY_DEMO_ALLOW_ISOLATED_QA="1",
               ORDER315_EXPECTED_USER_PATH=str(storage), ORDER315_OUT=str(output),
               ORDER315_LANG=args.language, ORDER315_SIZE=args.size)
    command = [str(godot), "--path", str(ROOT), "--max-fps", "60", "--resolution", args.size,
               "--position", "20,40", "--audio-driver", "Dummy", "--log-file", str(output / "godot.log"),
               "--quit-after", "18000", "--script", str(output / "bootstrap.gd"),
               "--scene", str(output / "screen.tscn"), "--", "--story-demo-language=" + args.language]
    report = {"head": expected, "tree": git("rev-parse", "HEAD^{tree}"), "command": command,
              "storage": str(storage), "language": args.language, "size": args.size,
              "user_before": users(), "sources_before": source_pins(),
              "claim": "native render; synthetic engine keyboard; fixture prehistory; no human/native/physical/package approval"}
    (output / "entry.json").write_text(json.dumps(report, ensure_ascii=False, indent=2))
    started = time.monotonic()
    with (output / "stdout.log").open("xb") as stdout, (output / "stderr.log").open("xb") as stderr:
        proc = subprocess.Popen(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr, start_new_session=True)
        report["pid"] = proc.pid
        try:
            proc.wait(timeout=300)
        except BaseException as error:
            report["exception"] = repr(error)
            try:
                os.killpg(proc.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait(timeout=5)
        finally:
            try:
                os.killpg(proc.pid, signal.SIGTERM)
                report["remaining_group"] = True
            except ProcessLookupError:
                report["remaining_group"] = False
    streams = {name: (output / name).read_text(errors="replace") if (output / name).exists() else ""
               for name in ("stdout.log", "stderr.log", "godot.log")}
    report.update(exit=proc.returncode, seconds=time.monotonic() - started,
                  streams={name: pin(output / name) for name in streams if (output / name).exists()},
                  user_after=users(), sources_after=source_pins(),
                  head_after=git("rev-parse", "HEAD"), status_after=git("status", "--porcelain"))
    report["error_lines"] = [line for stream in streams.values() for line in stream.splitlines() if FATAL.search(line)]
    report["pngs"] = {p.name: {**pin(p), "size": png_size(p.read_bytes())} for p in sorted(output.glob("*.png"))}
    telemetry = output / "telemetry.json"
    report["telemetry"] = pin(telemetry) if telemetry.is_file() else None
    data = json.loads(telemetry.read_text()) if telemetry.is_file() else {}
    report["marker_ok"] = exact_marker(streams["stdout.log"], f"STORY_HEADER_SAFE_AREA_CHECK_OK language={args.language} size={args.size}")
    report["isolation_ok"] = exact_marker(streams["stdout.log"], "ORDER315_PRE_AUTOLOAD_USER_DIR=" + str(storage))
    entries = [line for line in streams["stdout.log"].splitlines() if line.startswith("STORY_DEMO_NATIVE_ENTRY_OK")]
    pattern = re.compile(r"STORY_DEMO_NATIVE_ENTRY_OK profile=story_demo_rc build=2026\.08\.31\.1 scene=res://playtests/order124/StoryChoiceM1M6Playtest\.tscn custom_user_dir=GangnamDream_StoryDemo_v1 language=" + args.language + r" path=" + re.escape(str(storage)))
    report["controller_entries"] = entries
    report["controller_paths_ok"] = bool(entries) and all(pattern.fullmatch(line) for line in entries)
    # Telemetry names and expected physical dimensions are independently matched
    # against PNG IHDR; no logical viewport rectangle is treated as pixel size.
    captures = data.get("captures", [])
    width, height = map(int, args.size.split("x"))
    expected_files = {f"{index:02d}_{surface}.png": [width + (160 if surface == "home_resized" else 0), height]
                      for index, surface in enumerate(SURFACES, 1)}
    report["png_contract_ok"] = (len(captures) == len(SURFACES)
        and [row.get("surface") for row in captures] == list(SURFACES)
        and set(report["pngs"]) == set(expected_files)
        and [row.get("file") for row in captures] == list(expected_files)
        and all(report["pngs"][name]["size"] == size for name, size in expected_files.items())
        and all(row.get("expected_output") == expected_files.get(row.get("file")) for row in captures))
    report["telemetry_identity_ok"] = (data.get("language") == args.language
        and data.get("requested_output") == [width, height] and data.get("user_dir") == str(storage)
        and data.get("complete") is True and data.get("failures") == [])
    report["pass"] = (report["exit"] == 0 and not report.get("exception") and not report["remaining_group"]
        and len(report["streams"]) == 3 and bool(streams["godot.log"]) and not report["error_lines"]
        and report["marker_ok"] and report["isolation_ok"] and report["controller_paths_ok"]
        and report["png_contract_ok"] and report["telemetry_identity_ok"] and data.get("pass") is True
        and report["user_before"] == report["user_after"] and report["sources_before"] == report["sources_after"]
        and report["head_after"] == expected and not report["status_after"])
    (output / "result.json").write_text(json.dumps(report, ensure_ascii=False, indent=2))
    print(json.dumps({"output": str(output), "pass": report["pass"], "exit": report["exit"],
                      "pngs": len(report["pngs"]), "errors": report["error_lines"],
                      "users_unchanged": report["user_before"] == report["user_after"]}, ensure_ascii=False))
    return 0 if report["pass"] else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--head")
    parser.add_argument("--output")
    parser.add_argument("--language", choices=LANGUAGES)
    parser.add_argument("--size", choices=SIZES)
    parser.add_argument("--godot")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    if not all((args.head, args.output, args.language, args.size)):
        parser.error("graphical run requires --head, --output, --language, --size")
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main())
