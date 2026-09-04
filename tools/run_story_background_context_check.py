#!/usr/bin/env python3
"""Run ORDER-155's real StoryMode background check in isolated storage.

The runner retains failing evidence and removes only its own validated fresh
Godot namespace after a successful run. It is L2 regression evidence, not a
human-play gate.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import signal
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
PREFIX = "GangnamDream_StoryNameplateQA_"
SUCCESS = re.compile(r"(?m)^STORY_BACKGROUND_CONTEXT_CHECK_OK(?:\s|$)")
FAILURE = re.compile(
    r"STORY_BACKGROUND_CONTEXT_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|"
    r"resources still in use",
    re.IGNORECASE,
)


def user_data_parent() -> Path | None:
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support"
    if os.name == "nt":
        value = os.environ.get("APPDATA")
        return Path(value) if value else None
    value = os.environ.get("XDG_DATA_HOME")
    return Path(value) if value else Path.home() / ".local" / "share"


def terminate(proc: subprocess.Popen[str]) -> None:
    if proc.poll() is not None:
        return
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
    else:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    try:
        proc.communicate(timeout=5)
    except subprocess.TimeoutExpired:
        pass


def marker_path(output: str, expected: Path) -> str | None:
    before = re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=(.+)$", output)
    after = re.findall(r"(?m)^STORY_NAMEPLATE_QA_USER_DIR=(.+)$", output)
    if len(before) != 1 or len(after) != 1 or before[0] != after[0]:
        return "missing, duplicate, or mismatched storage markers"
    actual = Path(before[0])
    if (
        not actual.is_absolute()
        or actual.name != expected.name
        or actual.parent.resolve() != expected.parent.resolve()
        or actual.resolve() != expected.resolve()
    ):
        return f"unexpected isolated storage path: {actual}"
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    parser.add_argument("--resolution", default="1280x800", choices=("1280x800", "960x600"))
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required; set GODOT or --godot")
    evidence = Path(tempfile.mkdtemp(prefix="gangnam-story-background-context-"))
    parent = user_data_parent()
    namespace = PREFIX + secrets.token_hex(16)
    qa_path = parent / namespace if parent else None
    engine_log = evidence / "godot.log"
    command = [
        godot,
        "--headless",
        "--path",
        str(ROOT),
        "--max-fps",
        "60",
        "--resolution",
        args.resolution,
        "--quit-after",
        "3600",
        "--log-file",
        str(engine_log),
        "--script",
        "res://tools/StoryNameplateBootstrap.gd",
        "--scene",
        "res://tools/StoryBackgroundContextCheck.tscn",
    ]
    result: dict[str, object] = {
        "command": command,
        "expected_user_dir": str(qa_path) if qa_path else None,
        "resolution": args.resolution,
        "status": "initializing",
    }
    print(f"STORY_BACKGROUND_CONTEXT_EVIDENCE={evidence}", flush=True)
    if qa_path is None or qa_path.exists():
        result.update(status="runner_error", reason="invalid fresh QA namespace")
        (evidence / "runner_result.json").write_text(
            json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        return 1
    env = os.environ.copy()
    env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
    isolation: dict[str, object] = (
        {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
        if os.name == "nt"
        else {"start_new_session": True}
    )
    proc = subprocess.Popen(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
        **isolation,
    )
    try:
        stdout, stderr = proc.communicate(timeout=args.timeout)
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        terminate(proc)
        result.update(status="interrupted", reason="timeout or interrupt")
        stdout = stderr = ""
    (evidence / "stdout.log").write_text(stdout, encoding="utf-8")
    (evidence / "stderr.log").write_text(stderr, encoding="utf-8")
    combined = stdout + "\n" + stderr
    if engine_log.is_file():
        combined += "\n" + engine_log.read_text(encoding="utf-8", errors="replace")
    reason = None
    if result.get("status") == "interrupted":
        reason = str(result["reason"])
    elif proc.returncode != 0:
        reason = f"engine exit {proc.returncode}"
    elif FAILURE.search(combined):
        reason = "engine or contract failure in output"
    elif not SUCCESS.search(combined):
        reason = "missing success marker"
    else:
        reason = marker_path(stdout, qa_path)
    if reason:
        result.update(status="failed", reason=reason, engine_exit=proc.returncode)
        (evidence / "runner_result.json").write_text(
            json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        print(f"STORY_BACKGROUND_CONTEXT_RUNNER_FAIL {reason}; evidence={evidence}")
        return 1
    if not qa_path.is_dir() or qa_path.is_symlink() or qa_path.is_mount():
        result.update(status="cleanup_refused", reason="QA path is not a plain owned directory")
        (evidence / "runner_result.json").write_text(
            json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        return 1
    shutil.rmtree(qa_path)
    result.update(status="passed", reason=None, engine_exit=proc.returncode, storage_cleanup="removed")
    (evidence / "runner_result.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(stdout, end="" if stdout.endswith("\n") else "\n")
    if stderr:
        print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
    print(f"STORY_BACKGROUND_CONTEXT_QA_CLEANED={qa_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
