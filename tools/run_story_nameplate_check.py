#!/usr/bin/env python3
"""Run the L2 nameplate regression with pre-autoload storage isolation.

Keeps both logs for diagnosis. Does not use player saves or certify human play.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SUCCESS = re.compile(r"(?m)^STORY_NAMEPLATE_CHECK_OK(?:\s|$)")
FATAL = re.compile(
    r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|\bERROR:|"
    r"ObjectDB instances leaked|resources still in use|STORY_NAMEPLATE_CHECK_FAIL",
    re.IGNORECASE,
)


def failure_reason(status: int, output: str) -> str | None:
    if status != 0:
        return f"engine exit {status}"
    if FATAL.search(output):
        return "engine/test error in output"
    if not SUCCESS.search(output):
        return "missing success marker"
    before = re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=(.+)$", output)
    after = re.findall(r"(?m)^STORY_NAMEPLATE_QA_USER_DIR=(.+)$", output)
    if not before or not after or set(before) != set(after) or len(set(before)) != 1:
        return "missing or mismatched pre-autoload isolation evidence"
    if not Path(before[0]).name.startswith("GangnamDream_StoryNameplateQA_"):
        return "unexpected QA storage namespace"
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required; set GODOT or --godot")
    evidence = Path(tempfile.mkdtemp(prefix="gangnam-story-nameplate-"))
    engine_log = evidence / "godot.log"
    command = [
        godot, "--headless", "--path", str(ROOT), "--max-fps", "60",
        "--resolution", "1280x800", "--quit-after", "3600",
        "--log-file", str(engine_log),
        "--script", "res://tools/StoryNameplateBootstrap.gd",
        "--scene", "res://tools/StoryNameplateCheck.tscn",
    ]
    print(f"STORY_NAMEPLATE_EVIDENCE={evidence}", flush=True)
    try:
        proc = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                              timeout=120, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        captured = getattr(exc, "stdout", None) or b""
        errors = getattr(exc, "stderr", None) or b""
        captured = captured.decode("utf-8", errors="replace") if isinstance(captured, bytes) else captured
        errors = errors.decode("utf-8", errors="replace") if isinstance(errors, bytes) else errors
        (evidence / "stdout.log").write_text(captured + errors, encoding="utf-8")
        print(f"STORY_NAMEPLATE_RUNNER_FAIL {exc}")
        return 1
    output = proc.stdout + proc.stderr
    (evidence / "stdout.log").write_text(output, encoding="utf-8")
    print(output, end="" if output.endswith("\n") else "\n")
    if not engine_log.is_file():
        print("STORY_NAMEPLATE_RUNNER_FAIL missing engine log")
        return 1
    combined = output + "\n" + engine_log.read_text(encoding="utf-8", errors="replace")
    reason = failure_reason(proc.returncode, combined)
    if reason:
        print(f"STORY_NAMEPLATE_RUNNER_FAIL {reason}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
